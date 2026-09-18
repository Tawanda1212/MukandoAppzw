import 'package:supabase_flutter/supabase_flutter.dart';
import 'offline_service.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // Get all groups
  static Future<List> getGroups() async {
    try {
      if (await OfflineService.isOnline()) {
        final data = await client
            .from('groups')
            .select()
            .order('created_at', ascending: false);

        for (final group in data) {
          await OfflineService.groupsBox.put(
            group['name'].toString(),
            Map<String, dynamic>.from(group),
          );
        }

        return List.from(data);
      } else {
        return OfflineService.groupsBox.values.toList();
      }
    } catch (e) {
      print('Get groups error: $e');
      return OfflineService.groupsBox.values.toList();
    }
  }

  // Get members for a group
  static Future<List> getMembers(String groupName) async {
    try {
      if (await OfflineService.isOnline()) {
        final data = await client
            .from('members')
            .select()
            .eq('group_name', groupName);

        for (final member in data) {
          final map = Map<String, dynamic>.from(member);

          final key = map['id']?.toString() ??
              '${groupName}_${map['phone'] ?? map['name']}';

          await OfflineService.membersBox.put(key, map);
        }

        return List.from(data);
      } else {
        return OfflineService.membersBox.values
            .where((member) =>
                member['group_name']?.toString() == groupName)
            .toList();
      }
    } catch (e) {
      print('Get members error: $e');

      return OfflineService.membersBox.values
          .where((member) =>
              member['group_name']?.toString() == groupName)
          .toList();
    }
  }

  // Create a new group
  static Future<void> createGroup(
    String name,
    String type,
    int amount,
  ) async {
    final data = <String, dynamic>{
      'name': name,
      'type': type,
      'monthly_amount': amount,
      'total_members': 0,
    };

    try {
      if (await OfflineService.isOnline()) {
        final result = await client
            .from('groups')
            .insert(data)
            .select()
            .single();

        await OfflineService.groupsBox.put(
          name,
          Map<String, dynamic>.from(result),
        );
      } else {
        await OfflineService.saveOffline('groups', data);
      }
    } catch (e) {
      print('Create group error: $e');

      // Save locally if Supabase fails
      await OfflineService.saveOffline('groups', data);
    }
  }

  // Add a member to a group
  static Future<void> addMember(
    String groupName,
    String name,
    String phone,
    String type,
  ) async {
    final data = <String, dynamic>{
      'group_name': groupName,
      'name': name,
      'phone': phone,
      'type': type,
      'amount': 50,
      'savings': 0,
    };

    try {
      if (await OfflineService.isOnline()) {
        final result = await client
            .from('members')
            .insert(data)
            .select()
            .single();

        final map = Map<String, dynamic>.from(result);

        final key = map['id']?.toString() ??
            '${groupName}_${phone.isNotEmpty ? phone : name}';

        await OfflineService.membersBox.put(key, map);
      } else {
        await OfflineService.saveOffline('members', data);
      }
    } catch (e) {
      print('Add member error: $e');

      // Save locally if Supabase fails
      await OfflineService.saveOffline('members', data);
    }
  }
}
