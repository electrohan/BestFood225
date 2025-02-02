import 'dart:io';
import 'package:appli2/Widget/my_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  final _formKey = GlobalKey<FormState>();
  String dropdownValue = "";
  File? _image;
  File? _video;
  String? _imageUrl;
  String? _videoUrl;
  final picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _nbPersonneController = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> _ingredients = [];
  late final SupabaseClient supabaseClient;

  @override
  void initState() {
    super.initState();
    // Initialise le client Supabase
    supabaseClient = Supabase.instance.client;
    fetchCategorie();
  }

  void _addIngredient(){
    setState(() {
      _ingredients.add({
        'name': TextEditingController(),
        'quantity': TextEditingController(),
        'image': null, // Pour stocker l'image
      });
    });
  }
  Future<void> _pickIngredientImage(int index) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _ingredients[index]['image'] = File(pickedFile.path);
      });
    }
  }
  Future<void> registerRecipe() async {
    //récupération des données du formulaire
    final name = _nameController.text.trim();
    final calorie = _calorieController.text.trim();
    final time  = _timeController.text.trim();
    final personne = _nbPersonneController.text.trim();
    final categorieid = dropdownValue;
    final client_uid = supabaseClient.auth.currentUser?.id;
    final user = Supabase.instance.client.auth.currentUser;
    

    //verifier si l'image est retournée
    if (_image == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Choissez une image')),
        );
      }
      return;
    }

    try {
      final fileName = DateTime.now()
          .microsecondsSinceEpoch
          .toString();
           //nom unique pour l'image
      final storageResponse = await supabaseClient.storage
          .from("recipes-images")
          .upload("images/$fileName.jpg", _image!);
      if (storageResponse == null) {
        throw Exception(
            'Erreur lors du téléchargement de l\'image : $storageResponse');
      }

      final storageVideoResponse = await supabaseClient.storage.from("recipes-images").upload("videos/$fileName.mp4", _video!);
      if (storageVideoResponse == null) {
        throw Exception(
            'Erreur lors du téléchargement de la video : $storageVideoResponse');
      }
      //Générer l'url de l'image
      _imageUrl = supabaseClient.storage
          .from("recipes-images")
          .getPublicUrl("images/$fileName.jpg");
      //Générer l'url de la video
      _videoUrl = supabaseClient.storage.from("recipes-images").getPublicUrl("videos/$fileName.mp4");
      final response = await supabaseClient.from('recipe').insert({
        'name': name,
        'Image': _imageUrl,
        'calorie': calorie,
        'time': time,
        'nb_personne':personne,
        'categorie_id': categorieid,
        'client_uid': client_uid,
        'video':_videoUrl,
      }).select('id').single();

      final recipeId = response['id'];

      for (var ingredient in _ingredients) {
        if (ingredient['image'] != null) {
          // Upload de l'image dans le bucket
          final path = 'ingredients/${DateTime.now().toIso8601String()}_${ingredient['name'].text}.jpg';
          final response = await Supabase.instance.client.storage
              .from('recipes-images')
              .upload(path, ingredient['image']);
          print(response);
          if (response != null ) {
            final publicUrl = Supabase.instance.client.storage
                .from('recipes-images')
                .getPublicUrl(path);

            // Enregistrement des données dans la table `ingredient`
            await Supabase.instance.client
                .from('ingredient')
                .insert({
              'name': ingredient['name'].text,
              'quantity': ingredient['quantity'].text,
              'image': publicUrl,
              'recipe_id':recipeId,
            });
          }
        }
      }
      // Succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Recette enregistrée avec succès !")),
      );
      // Réinitialise le formulaire
      _formKey.currentState?.reset();
      setState(() {
        _image = null;
        _imageUrl = null;
        _video = null;
        _videoUrl = null;
        _nameController.clear();
        _calorieController.clear();
        _nbPersonneController.clear();
        _timeController.clear();
        _ingredients.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur inattendue : $e')),
        );
        print('Erreur inattendue : $e');
      }
    }
  }

  Future<void> _pickerImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  Future<void> _pickerVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if(pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
      });
    }
  }

  //recuperation des categorie
  Future<void> fetchCategorie() async {
    final response = await supabaseClient.from('categorie').select('id,name');

    if (response != null && response.isNotEmpty) {
      final List<dynamic> data = response;
      if(mounted){
setState(() {
        categories = List.generate(data.length, (index) {
          return {
            'id': data[index]['id'],
            'name': data[index]['name'],
          };
        });
      });
      }
      
    } else {
      print("erreur lors de la recupération");
    }
  }

  // Crée les éléments du menu déroulant
  List<DropdownMenuItem<String>> getDropdownItems() {
    return categories.map((category) {
      return DropdownMenuItem<String>(
        value: category['id'].toString(),
        child: Text(category['name']),
      );
    }).toList();
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Vos recettes",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1),
                      ),
                      const Spacer(),
                      MyIconButton(icon: Iconsax.notification, pressed: () {}),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            DropdownButtonFormField(
                              items: getDropdownItems(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue ?? "";
                                });
                              },
                              value:
                                  dropdownValue.isEmpty ? null : dropdownValue,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: InputBorder.none,
                                hintText: "choisi la categorie",
                                hintStyle: TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                              ),
                              dropdownColor: Colors.white,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: "nom de la recette",
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: TextFormField(
                                      controller: _timeController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Veuillez entrer le nom de la recette';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: "temps",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none),
                                      ),
                                    ),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _nbPersonneController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer le nom de la recette';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "personne",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _calorieController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer le nom de la recette';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "calories",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    onPressed: _pickerImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xff568A9F),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: Text("choisir une image")),
                                ElevatedButton(
                                    onPressed: _pickerVideo,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xff568A9F),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                    ),
                                    child: Text("choisir une video")),
                              ],
                            ),

                            SizedBox(
                              height: 4,
                            ),

                            Column(
                              children: [
                                for (int i = 0; i < _ingredients.length; i++)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _ingredients[i]['name'],
                                          decoration: InputDecoration(
                                            hintText: "Nom de l'ingrédient",
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _ingredients[i]['quantity'],
                                          decoration: InputDecoration(
                                            hintText: "Quantité",
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _pickIngredientImage(i),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xff568A9F),
                                        ),
                                        child: Text("Image"),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            ElevatedButton(
                                onPressed: _addIngredient,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff568A9F),
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(400, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text("Ajouter les ingredients")
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            ElevatedButton(
                                onPressed: registerRecipe,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff568A9F),
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(400, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text("Enregistrer")
                            ),
                            // Affichage de l'image sélectionnée
                            if (_image != null)
                              Image.file(
                                _image!,
                                width: 200,
                                height: 200,
                              ),
                          ],
                        )),
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
