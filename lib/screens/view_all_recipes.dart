import 'package:appli2/Widget/food_items_display.dart';
import 'package:appli2/Widget/my_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewAllRecipes extends StatefulWidget {
  const ViewAllRecipes({super.key});

  @override
  State<ViewAllRecipes> createState() => _ViewAllRecipesState();
}

class _ViewAllRecipesState extends State<ViewAllRecipes> {
    late final SupabaseClient supabaseClient;
    @override
  void initState() {
    super.initState();
    // Initialise le client Supabase
    supabaseClient = Supabase.instance.client;
  }
  Stream<List<Map<String, dynamic>>> getAllRecipes() {
    return supabaseClient.from('recipe').stream(primaryKey: ['id']).map((maps) => List<Map<String, dynamic>>.from(maps));
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xffeff1f7),
      appBar: AppBar(
        backgroundColor:Color(0xffeff1f7) ,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          SizedBox(width: 15  ,),
          MyIconButton(icon: Icons.arrow_back_ios_new, pressed: (){
            Navigator.pop(context);
          },
          ),
          Spacer(),
          Text("Rapide et facile" , style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          Spacer(), 
          MyIconButton(icon: Iconsax.notification, pressed: (){

          }),
          SizedBox(width: 15,),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left:15,right: 5),
        child: Column(
          children: [
            SizedBox(height: 10,),
            StreamBuilder<List<Map<String, dynamic>>>(
        stream: getAllRecipes(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("error lors de la recuépration des catégorie");
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text("Aucune catégorie disponible.");
          } else {
            final Recipes = snapshot.data!;
            return GridView.builder(
              itemCount:Recipes.length ,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 0.78), 
              itemBuilder: (context,index){
              final Map<String, dynamic> documentSnapshot = Recipes[index];
              return Column(
                children: [
                    FoodItemsDisplay(snapshot:documentSnapshot ),
                    Row(
                      children: [
                        Icon(Iconsax.star1 , color: Colors.amber,),
                        SizedBox(width: 5,),
                        Text('4', style: TextStyle(fontWeight: FontWeight.bold),),
                        Text('/5'),
                        SizedBox(width: 5,),
                      ],
                    )
                ]
                
              );
            });
          }
        }
        ),
          ],
        ),
      ),
    );
  }
}