import 'package:appli2/Widget/banner.dart';
import 'package:appli2/Widget/food_items_display.dart';
import 'package:appli2/Widget/my_icon_button.dart';
import 'package:appli2/auth/auth_service.dart';
import 'package:appli2/screens/view_all_recipes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppHomeScreen extends StatefulWidget {
  // Autorise une valeur nullable
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  final authService = AuthService();
  User? _user;
  bool _isLoading = true;
  String? _nom;
  String? _prenom;
  late final SupabaseClient supabaseClient;
  @override
  void initState() {
    super.initState();
    // Initialise le client Supabase
    supabaseClient = Supabase.instance.client;
    _fetchUserInfo();
  }

  // Fonction pour récupérer les informations de l'utilisateur
  Future<void> _fetchUserInfo() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        // Récupérer les informations de l'utilisateur dans la table "client"

        final response = await Supabase.instance.client
            .from('client')
            .select('nom, prenom')
            .eq('user_id',
                user.id); // Utilise .single() pour récupérer un seul enregistrement
        print(response);
        if (response != null && response.isNotEmpty) {
          setState(() {
            _user = user;
            _nom = response[0]['nom'];
            _prenom = response[0]['prenom'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Client non trouvé')),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non trouvé')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur lors de la récupération des informations : $e')),
      );
    }
  }

  //For category
  String category = "Tous";
  int category_id = 1;
  Stream<List<Map<String, dynamic>>> getCategorieStream() {
    return supabaseClient
        .from('categorie')
        .stream(primaryKey: ['id']); // Écoute les mises à jour en temps réel
  }

  //For all item display
  Stream<List<Map<String, dynamic>>> getFilteredRecipeStream(int categoryId) {
    return supabaseClient
        .from('recipe')
        .stream(primaryKey: ['id'])
        .eq('categorie_id', categoryId)
        .map((maps) => List<Map<String, dynamic>>.from(maps));
  }

  Future<List<Map<String, dynamic>>> getAllRecipes() {
    return supabaseClient.from('recipe').select('*');
  }

  Stream<List<Map<String, dynamic>>> selectedRecipe(int category_id) {
    if (category_id == 1) {
      return getAllRecipes()
          .asStream(); // Utilisation de asStream() pour convertir Future en Stream
    } else {
      return getFilteredRecipeStream(category_id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffeff1f7),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RichText(
                        // Optionnel : pour centrer le texte
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 24,
                              height: 1,
                              color: Colors.black), // Style global
                          children: [
                            TextSpan(
                              text: "Bienvenue,\n",
                              // Style pour la première ligne
                            ),
                            TextSpan(
                              text: _prenom,
                              // Style pour la deuxième ligne
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      MyIconButton(icon: Iconsax.notification, pressed: () {}),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        prefixIcon: Icon(Icons.search),
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        hintText: "trouve ta recette",
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  //for banner
                  BannerToExplore(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    child: Text(
                      "categories",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  //For categorie
                  selectedCategory(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rapide et facile",
                        style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 0.1,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewAllRecipes() ),);
                          },
                          child: Text(
                            "Voir tous",
                            style: TextStyle(
                                color: Color(0xff568A9F),
                                fontWeight: FontWeight.w600),
                          ))
                    ],
                  ),
                ],
              ),
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
                stream: selectedRecipe(category_id),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text("error lors de la recuépration des catégorie");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("Aucune catégorie disponible.");
                  } else {
                    final recipes = snapshot.data!;
                    return Padding(
                      padding: EdgeInsets.only(top: 5, left: 15),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: recipes
                              .map((e) => FoodItemsDisplay(snapshot: e))
                              .toList(),
                        ),
                      ),
                    );
                  }
                })
          ],
        ),
      )),
    );
  }

  StreamBuilder<List<Map<String, dynamic>>> selectedCategory() {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: getCategorieStream(),
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
            final categories = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                    categories.length,
                    (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              category = categories[index]["name"];
                              category_id = categories[index]["id"];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: category == categories[index]["name"]
                                    ? Color(0xff568A9F)
                                    : Colors.white),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            margin: EdgeInsets.only(right: 20),
                            child: Text(
                              categories[index]["name"],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: category == categories[index]["name"]
                                      ? Colors.white
                                      : Colors.grey.shade600),
                            ),
                          ),
                        )),
              ),
            );
          }
        });
  }
}
