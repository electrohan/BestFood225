import 'package:appli2/Widget/food_items_display.dart';
import 'package:appli2/Widget/my_icon_button.dart';
import 'package:appli2/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Provider/favorite_provider.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final authService = AuthService();
  late final SupabaseClient supabaseClient;
  final user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    // Initialise le client Supabase
    supabaseClient = Supabase.instance.client;
  }
  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final favoriteItems = provider.favoriteIds;
    return Scaffold(
        backgroundColor: Color(0xffeff1f7),
        appBar: AppBar(
          backgroundColor: Color(0xffeff1f7),
          centerTitle: true,
          title: Text("Favoris",style: TextStyle(
            fontWeight: FontWeight.bold,
          ),),
        ),
      body: favoriteItems.isEmpty?
      Center(child:
      Text("Pas de favoris",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
      )
          :ListView.builder(
        itemCount: favoriteItems.length,
          itemBuilder: (context,index){
            return FutureBuilder <List<Map<String, dynamic>>>(
                future:supabaseClient.from("recipe").select("*").eq('id', favoriteItems[index]),
                builder: (context,snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                  }if(!snapshot.hasData || snapshot.data!.isEmpty){
                    return Center(child: Text("Erreur de chargement"),);
                  }
                  var favoriteItem = snapshot.data![0];
                  print(favoriteItem);
                  return Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius:BorderRadius.circular(20),
                              color: Colors.white,
                          ),
                          child:Row(
                            children: [
                              Container(
                                width: 100,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                        image: NetworkImage(favoriteItem['Image']))
                                ),
                              ),
                              SizedBox(width: 5,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(favoriteItem['name'], style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16),),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.flash_1,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      Text("${favoriteItem['calorie']} cal",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)),
                                      Text(
                                        " . ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900, color: Colors.grey),
                                      ),
                                      Icon(
                                        Iconsax.clock_1,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      Text("${favoriteItem['time']} min",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ) ,
                        ),
                      ),
                      Positioned(
                        top: 50,
                          right: 35,
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                provider.toggleFavorite(favoriteItem['id']);
                              });
                            },
                            child: Icon(Icons.delete , color: Colors.red,size: 25,),
                      )
                      )
                    ],
                  );
                },
            );
          },
      )
    );
  }
}
