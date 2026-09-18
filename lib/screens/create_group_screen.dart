import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
class CreateGroupScreen extends StatefulWidget{ @override _CreateGroupScreenState createState()=> _CreateGroupScreenState();}
class _CreateGroupScreenState extends State<CreateGroupScreen>{
  final _name = TextEditingController();
  String _type = 'Mukando';
  final _amount = TextEditingController(text: '50');
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Create Group"), backgroundColor: Color(0xFF1B5E20)),
      body: Padding(padding: EdgeInsets.all(20), child: Column(children:[
        TextField(controller: _name, decoration: InputDecoration(labelText: "Group Name (e.g. Bindura Group)", border: OutlineInputBorder())),
        SizedBox(height:15),
        DropdownButtonFormField<String>(value: _type, decoration: InputDecoration(labelText: "Type", border: OutlineInputBorder()), items: ['Mukando','Internal Lending','Savings Circle'].map((e)=> DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v)=> setState(()=> _type = v!)),
        SizedBox(height:15),
        TextField(controller: _amount, decoration: InputDecoration(labelText: "Monthly Amount", border: OutlineInputBorder()), keyboardType: TextInputType.number),
        SizedBox(height:25),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1B5E20)), onPressed: () async { if(_name.text.isEmpty) return; await SupabaseService.createGroup(_name.text.trim(), _type, int.tryParse(_amount.text)??50); if(mounted) Navigator.pop(context); }, child: Text("CREATE GROUP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
      ]))
    );
  }
}
