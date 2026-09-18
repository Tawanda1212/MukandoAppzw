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
    var r = await Connectivity().checkConnectivity();
    return r!= ConnectivityResult.none;
  }
  static Future<void> saveOffline(String table, Map data) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    data['local_id'] = id;
    data['synced'] = false;
    data['created_at'] = DateTime.now().toIso8601String();
    if(table == 'members') await membersBox.put(id, data);
    else await groupsBox.put(id, data);
    await offlineBox.add({'table': table, 'data': data, 'local_id': id});
    if(await isOnline()) await syncAll();
  }
  static Future<void> syncAll() async {
    if(!await isOnline()) return;
    for(int i = offlineBox.length -1; i >=0; i--){
      var item = offlineBox.getAt(i);
      if(item == null) continue;
      try{
        Map<String,dynamic> toSync = Map<String,dynamic>.from(item['data']);
        toSync.remove('local_id');
        toSync.remove('synced');
        await Supabase.instance.client.from(item['table']).insert(toSync);
        await offlineBox.deleteAt(i);
      }catch(e){ print("Sync error $e"); }
    }
  }
}
