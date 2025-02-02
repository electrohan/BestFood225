import 'package:appli2/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  User? _user;
  bool _isLoading = true;
  String? _nom;
  String? _prenom;
  @override
  void initState() {
    super.initState();
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
            .eq('user_id', user.id); // Utilise .single() pour récupérer un seul enregistrement
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
        SnackBar(content: Text('Erreur lors de la récupération des informations : $e')),
      );
    }
  }

  void logout()async{
    await authService.signOut();
  }

  

  @override
  Widget build(BuildContext context) {
    final currentEmail =  authService.getCurrentUserEmail();
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout))
        ],
      ),
      body:  _isLoading
          ? Center(child: CircularProgressIndicator()) // Affiche un indicateur de chargement
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Email : $currentEmail'),
                  SizedBox(height: 16),
                  Text('Nom : $_nom'),
                  SizedBox(height: 8),
                  Text('Prénom : $_prenom'),
                ],
              ),
            ),
    );
  }
}