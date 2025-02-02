//import 'package:appli2/screens/splashscreen.dart';
import 'package:appli2/Provider/favorite_provider.dart';
import 'package:appli2/Provider/quantity.dart';
import 'package:appli2/auth/auth_gate.dart';
import 'package:appli2/screens/bills.dart';
//import 'package:appli2/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
 //supabase setup
  WidgetsFlutterBinding.ensureInitialized();
  Supabase.initialize(url:'https://tpkciqtsszoiguuqdgmx.supabase.co' , anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwa2NpcXRzc3pvaWd1dXFkZ214Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczMDM5NDEsImV4cCI6MjA1Mjg3OTk0MX0.S2fyJ9qUn35RdJuRGMlnGipdsL9TW1x6Y_rbejf-Azg' );

 //run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>FavoriteProvider()),
        ChangeNotifierProvider(create: (_)=>QuantityProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner:false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthGate(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int counter = 0;
  int total =0;
  List<Map<String, Object>> menu = [
    {"plat": "foutou banane", "prix": 1500},
    {"plat": "Tchep", "prix": 1000},
    {"plat": "alloco", "prix": 2000},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "application demo",
            selectionColor: Color(0xFFFFFFFF),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 10,
          backgroundColor: Color(0xFFFF981E),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("pour une fois j'utilise la doc")));
                },
                icon: Icon(Icons.add_alert))
          ],
        ),
        body: Column(
          children: [
            Expanded(child: ListView.builder(
              itemCount: menu.length,
              itemBuilder: (context, index) {
                final item = menu[index];
                final plat = item["plat"] as String;
                final prix = item["prix"] as int;

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.fastfood,
                      color: Color(0xFFFF981E),
                    ),
                    title: Text(
                      plat,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("$prix Fcfa"),
                    trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            total = total + prix;
                          });
                        },
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        )),
                  ),
                );
              },
            ),),
            
            Padding(
            padding: EdgeInsets.all(10),
            child:ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){return  BillsScreen(total : total); }));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF981E),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              foregroundColor: Colors.white,
              minimumSize: const Size(400, 50)
              ),
            child: Text("$total Fcfa"),
            )
            ,)
            
          ],
        ));
  }
}
