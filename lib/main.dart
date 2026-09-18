import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/create_group_screen.dart';
import 'screens/group_detail.dart';
import 'services/offline_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineService.init();
  await Supabase.initialize(
    url: 'https://dmlqxgsmsrhccukoegtw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtbHF4Z3Ntc3JoY2N1a29lZ3R3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk3MzQwNjksImV4cCI6MjEwNTMxMDA2OX0.8pXf-PtnEKsZvXbpxXAxehJqGcCniaALYMUNZZr-zzc',
  );
  runApp(MukandoApp());
}

class MukandoApp extends StatelessWidget {
  @override Widget build(BuildContext context){
    return MaterialApp(
      title: 'MukandoZW',
      theme: ThemeData(
        primaryColor: Color(0xFF1B5E20),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(secondary: Colors.amber),
        scaffoldBackgroundColor: Color(0xFFF1F8E9),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF1B5E20), foregroundColor: Colors.white),
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Color(0xFF1B5E20)),
      ),
      home: HomeScreen(), debugShowCheckedModeBanner: false);
  }
}

class HomeScreen extends StatefulWidget{ @override _HomeScreenState createState()=> _HomeScreenState();}
class _HomeScreenState extends State<HomeScreen>{
  List groups = []; bool loading = true; bool isOffline = false;
  @override void initState(){ super.initState(); loadGroups(); }
  loadGroups() async {
    setState(()=> loading = true);
    var online = await OfflineService.isOnline();
    setState(()=> isOffline =!online);
    var data = await SupabaseService.getGroups();
    setState(()=> {groups = data, loading = false});
    if(online) await OfflineService.syncAll();
  }
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("MukandoZW - My Groups"), if(isOffline) Text("OFFLINE MODE", style: TextStyle(fontSize: 10, color: Colors.yellow))]), actions: [IconButton(icon: Icon(Icons.sync), onPressed: () async { await OfflineService.syncAll(); loadGroups(); })]),
      body: loading? Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))) : groups.isEmpty? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.groups, size: 80, color: Color(0xFF1B5E20)), SizedBox(height:10), Text("No groups yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text("Tap + to create"), Text("Works offline in Bindura!", style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold))])) : ListView.builder(itemCount: groups.length, itemBuilder: (_,i){ var g = groups[i]; return Card(margin: EdgeInsets.all(8), child: ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF1B5E20), child: Text(g['name'][0].toUpperCase(), style: TextStyle(color: Colors.white))), title: Text(g['name'], style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${g['type']} - \$${g['monthly_amount']}"), trailing: Icon(Icons.arrow_forward, color: Color(0xFF1B5E20)), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> GroupDetailScreen(groupName: g['name'], groupType: g['type'])))));}),
      floatingActionButton: FloatingActionButton.extended(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_)=> CreateGroupScreen())); loadGroups(); }, label: Text("NEW GROUP", style: TextStyle(color: Colors.white)), icon: Icon(Icons.add, color: Colors.white), backgroundColor: Color(0xFF1B5E20)),
    );
  }
}
