import 'package:appli2/Provider/favorite_provider.dart';
import 'package:appli2/Provider/quantity.dart';
import 'package:appli2/Widget/my_icon_button.dart';
import 'package:appli2/Widget/quantity_increment_decrement.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Widget/video_player_widget.dart';



class RecipeDetailsScreen extends StatefulWidget {
  final Map<String?, dynamic> snapshot;
  const RecipeDetailsScreen({super.key, required this.snapshot});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late final SupabaseClient supabaseClient;
  @override
  void initState() {
    super.initState();
    // Initialise le client Supabase
    supabaseClient = Supabase.instance.client;

  }
  Future<List<Map<String, dynamic>>> fetchIngredients(int recipeId){
    return supabaseClient.from('ingredient').select('*').eq('recipe_id', recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);
    return  Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: (){},
        label:Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff568A9F),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10)
              ),
              onPressed: (){},
              child:
              Text(
                "Commencez à cuisiner" ,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17
                  ),
                  )),
                  SizedBox(width: 5,),
                  IconButton(
                    style: IconButton.styleFrom(
                      shape: CircleBorder(
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 2,

                          ),),
                    ),
                    onPressed: (){
                      provider.toggleFavorite(widget.snapshot['id']);
                    },
                    icon: Icon(
                      provider.isExisted(widget.snapshot['id']) ? Icons.bookmark : Icons.bookmark_border,
                      color: provider.isExisted(widget.snapshot['id'])  ? Colors.amber : Colors.grey,
                    )
                  )

          ],
        )
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag:widget.snapshot['Image'] ,
                  child: Container(
                    height: MediaQuery.of(context).size.height/2.4,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(widget.snapshot['Image'])
                      )
                    ),
                  ),
                ),
                Positioned(
                  top: 40, left: 10,right: 10,
                    child: Row(
                      children: [
                        MyIconButton(
                            icon: Icons.arrow_back_ios_new,
                            pressed: (){
                              Navigator.pop(context);
                            }
                            ),
                        Spacer(),
                        MyIconButton(
                            icon: Iconsax.notification,
                            pressed: (){

                            }
                        ),
                      ],
                    )
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.of(context).size.width,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)
                      ),
                    )
                ),
              ],
            ),
            SizedBox(height: 5,),
            Center(
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 5,),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.snapshot['name'], style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.flash_1,
                              size: 20,
                              color: Colors.grey,
                            ),
                            Text("${widget.snapshot['calorie']} cal",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            Text(
                              " . ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, color: Colors.grey),
                            ),
                            Icon(
                              Iconsax.clock,
                              size: 20,
                              color: Colors.grey,
                            ),
                            Text("${widget.snapshot['time']} min",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                        Icon(Iconsax.star1 , color: Colors.amber,),
                        SizedBox(width: 5,),
                        Text('', style: TextStyle(fontWeight: FontWeight.bold),),
                        Text('${widget.snapshot['note']}/5'),
                        SizedBox(width: 5,),
                      ],
                    ),
                    SizedBox(height: 15,),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ingredients",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                            SizedBox(height: 15,),
                            Text("pour combien de personnes?" , style: TextStyle(fontSize: 14 , color: Colors.grey),)
                          ],
                        ),
                        Spacer(),
                        QuantityIncrementDecrement(
                            currentNumber: quantityProvider.currentNumber,
                            onAdd: () => quantityProvider.increaseQuantity(),
                            onRemove: ()=>quantityProvider.decreaseQuantity()
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Column(
                      children: [
                        FutureBuilder(
                          future: fetchIngredients(widget.snapshot['id']),
                          builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return const Text(
                                'Erreur lors de la récupération des ingrédients',
                                style: TextStyle(color: Colors.red),
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text(
                                'Aucun ingrédient pour la recette',
                                style: TextStyle(color: Colors.grey),
                              );
                            } else {
                              final ingredients = snapshot.data!;

                              // Construction des colonnes pour les images, noms et quantités
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal, // Pour permettre le défilement horizontal
                                child:  Row(

                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Colonne des images des ingrédients
                                    Column(
                                      children: ingredients.map((ingredient) {
                                        // Construisez une liste de quantités pour tous les ingrédients
                                        List<int> allQuantities = ingredients.map<int>((ingredient) {
                                          return ingredient['quantity']; // Vérifiez que 'quantity' est bien un entier
                                        }).toList();

                                        // Mettez à jour toutes les quantités en une seule fois
                                        Provider.of<QuantityProvider>(context, listen: false).setBaseIngredientAmounts(allQuantities);
                                        return Container(
                                          height: 60,
                                          width: 60,
                                          margin: const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                ingredient['image'], // Chemin de l'image
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(width: 20),
                                    // Colonne des noms des ingrédients
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: ingredients.map((ingredient) {
                                        return SizedBox(
                                          height: 60,
                                          child: Center(
                                            child: Text(
                                              ingredient['name'], // Nom de l'ingrédient
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(width: 30),
                                    // Colonne des quantités des ingrédients
                                    Column(
                                      children: quantityProvider.updateIngredientAmount.map((quantity) {
                                        return SizedBox(
                                          height: 60,
                                          child: Center(
                                            child: Text(
                                              "$quantity gm", // Quantité d'ingrédient
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),


                  ],
                ),
            ),

          ],
        ),
      ),
    );
  }
}