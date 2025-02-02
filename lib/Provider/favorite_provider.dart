import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteProvider extends ChangeNotifier{
  final SupabaseClient supabase = Supabase.instance.client;
  List<int> _favoriteIds = [];
  List<int> get favoriteIds => _favoriteIds;

  FavoriteProvider(){
    _loadFavorites();
  }
    //charger les favoris depuis supabase
  Future<void>_loadFavorites() async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('recipe_favorites')
        .select('*')
        .eq('client_uid', user?.id ?? '');
    _favoriteIds = response.map<int>((item) => item['recipe_id'] as int).toList();
    notifyListeners();
  }
  //toggle favorite state
  void toggleFavorite(int productId)async{
    if (_favoriteIds.contains(productId)) {
      // Si l'ID est déjà dans les favoris, on le supprime
      await removeFavorite(productId);
    } else {
      // Sinon, on l'ajoute aux favoris
      await addFavorite(productId);
    }
  }
  //Ajouter un favoris
  Future<void>addFavorite (int productId) async {
    final user = supabase.auth.currentUser;
    await supabase.from('recipe_favorites').insert({
      'recipe_id': productId,
      'client_uid': user?.id ?? '',
    });
    _favoriteIds.add(productId);
    notifyListeners();
  }
  //Supprimer un favorie
  Future<void>removeFavorite (int productId) async {
    final user = supabase.auth.currentUser;
    await supabase.from('recipe_favorites').delete()
        .eq('recipe_id', productId)
        .eq('client_uid', user?.id ?? '');
    _favoriteIds.remove(productId);
    notifyListeners();
  }

  bool isExisted (int productId){
    return _favoriteIds.contains(productId);
  }

  // Méthode statique pour accéder au provider depuis n'importe quel contexte
  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}