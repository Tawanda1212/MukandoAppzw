import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfflineService {
  static late Box offlineBox;
  static late Box membersBox;
  static late Box groupsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    offlineBox = await Hive.openBox('offline_queue');
    membersBox = await Hive.openBox('members_local');
    groupsBox = await Hive.openBox('groups_local');
  }

  static Future<bool> isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();

      // Newer connectivity_plus versions return a List.
      if (result is List<ConnectivityResult>) {
        return result.any(
          (connection) => connection != ConnectivityResult.none,
        );
      }

      // Compatibility with older versions.
      return result != ConnectivityResult.none;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveOffline(
    String table,
    Map<String, dynamic> data,
  ) async {
    final String id =
        DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, dynamic> localData =
        Map<String, dynamic>.from(data);

    localData['local_id'] = id;
    localData['synced'] = false;
    localData['created_at'] =
        DateTime.now().toIso8601String();

    if (table == 'members') {
      await membersBox.put(id, localData);
    } else if (table == 'groups') {
      await groupsBox.put(id, localData);
    }

    await offlineBox.add({
      'table': table,
      'data': localData,
      'local_id': id,
    });

    if (await isOnline()) {
      await syncAll();
    }
  }

  static Future<void> syncAll() async {
    if (!await isOnline()) {
      return;
    }

    for (int i = offlineBox.length - 1; i >= 0; i--) {
      final item = offlineBox.getAt(i);

      if (item == null) {
        continue;
      }

      try {
        final Map<String, dynamic> itemMap =
            Map<String, dynamic>.from(item);

        final String table = itemMap['table'];

        final Map<String, dynamic> toSync =
            Map<String, dynamic>.from(itemMap['data']);

        toSync.remove('local_id');
        toSync.remove('synced');

        await Supabase.instance.client
            .from(table)
            .insert(toSync);

        await offlineBox.deleteAt(i);

        if (table == 'members') {
          final localId = itemMap['local_id'];
          await membersBox.delete(localId);
        } else if (table == 'groups') {
          final localId = itemMap['local_id'];
          await groupsBox.delete(localId);
        }
      } catch (e) {
        print('Sync error: $e');
      }
    }
  }
}
