import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Favoritebutton extends StatefulWidget {
  final int recipeId;
  final String clientUid;
  const Favoritebutton({super.key, required this.recipeId, required this.clientUid});

  @override
  State<Favoritebutton> createState() => _FavoritebuttonState();
}

class _FavoritebuttonState extends State<Favoritebutton> {
  Future<void> toggleFavorites(int recipeId, String clientUid) async {
    final supabase = Supabase.instance.client;

    final response = await supabase.from('recipe_favorites').select('*').eq('recipe_id', recipeId).eq('client_uid', clientUid);
    if(response.isNotEmpty){
      await supabase.from('recipe_favorites').delete().eq('recipe_id', recipeId).eq('client_uid', clientUid);
    }else{
      // Ajouter un like
    await supabase.from('recipe_favorites').insert({
      'recipe_id': recipeId,
      'client_uid': clientUid
    });
    }
  }

  bool isFavorited = false;
  Future<void> favorite() async{
    await toggleFavorites(widget.recipeId,widget.clientUid);
    setState(() {
      isFavorited = !isFavorited;
    });
  }
  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),),
        backgroundColor: Colors.white,
        fixedSize: const Size(50, 50)
      ),
      onPressed:favorite ,
      icon: Icon(
        isFavorited? Iconsax.bookmark:Iconsax.bookmark5,
        color: isFavorited? Colors.amber:Colors.grey,
        ),
    );
  }
}