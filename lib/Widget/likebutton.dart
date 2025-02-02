import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Likebutton extends StatefulWidget {
  const Likebutton({super.key});

  @override
  State<Likebutton> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Likebutton> {
  Future<void> toggleLike(String recipeId, String clientUid) async {
    final supabase = Supabase.instance.client;

    final response = await supabase.from('recipe_likes').select('*').eq('recipe_id', recipeId).eq('client_uid', clientUid);
    if(response.isNotEmpty){
      await supabase.from('recipe_likes').delete().eq('recipe_id', recipeId).eq('client_uid', clientUid);
    }else{
      // Ajouter un like
    await supabase.from('recipe_likes').insert({
      'recipe_id': recipeId,
      'client_uid': clientUid
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}