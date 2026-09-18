import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
class GroupDetailScreen extends StatefulWidget{
  final String groupName; final String groupType;
  GroupDetailScreen({required this.groupName, required this.groupType});
  @override _GroupDetailScreenState createState()=> _GroupDetailScreenState();
}
class _GroupDetailScreenState extends State<GroupDetailScreen>{
  List members = []; bool loading = true;
  @override void initState(){ super.initState(); load(); }
  load() async { setState(()=> loading = true); var d = await SupabaseService.getMembers(widget.groupName); setState(()=> {members = d, loading = false}); }
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName), backgroundColor: Color(0xFF1B5E20)),
      body: loading? Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))) : members.isEmpty? Center(child: Text("No members yet")) : ListView.builder(itemCount: members.length, itemBuilder: (_,i){ var m = members[i]; return Card(child: ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF1B5E20), child: Text(m['name'][0].toUpperCase(), style: TextStyle(color: Colors.white))), title: Text(m['name']), subtitle: Text(m['phone']??'')));}),
      floatingActionButton: FloatingActionButton(backgroundColor: Color(0xFF1B5E20), onPressed: () async {
        final nameC = TextEditingController(); final phoneC = TextEditingController();
        await showDialog(context: context, builder: (_)=> AlertDialog(title: Text("Add Member"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameC, decoration: InputDecoration(labelText: "Name")), TextField(controller: phoneC, decoration: InputDecoration(labelText: "Phone"))]), actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1B5E20)), onPressed: () async { await SupabaseService.addMember(widget.groupName, nameC.text, phoneC.text, "member"); Navigator.pop(context); load(); }, child: Text("Add", style: TextStyle(color: Colors.white))) ]));
      }, child: Icon(Icons.person_add, color: Colors.white))
    );
  }
}
