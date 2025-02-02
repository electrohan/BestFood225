import 'package:appli2/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final authservice = AuthService();

  //première étape on ajoute créer la variable de type TextEditingController et on instancie le constructeur de meme non
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //Methode pour afficher la boite de diagramme
  void SignUp() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final nom = _nomController.text.trim();
  final prenom = _prenomController.text.trim();
  final mail = _mailController.text.trim();
  final password = _passwordController.text.trim();

  try {
    // Étape 1 : Inscription via Supabase Auth
    await authservice.signUpWithEmailPassword(mail, password);

    // Récupérer l'ID utilisateur après l'inscription
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Étape 2 : Ajouter les informations dans la table CLIENT
      final supabase = Supabase.instance.client;

      // Insertion des données sans essayer de récupérer une réponse
      final response = await supabase.from('client').insert({
        'user_id': user.id, // Associer l'utilisateur à son ID unique
        'nom': nom,
        'prenom': prenom,
      });

      // Vérifier si l'insertion s'est bien déroulée
      if (response == null || response.error != null) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie et client ajouté !')),
        );
        // Réinitialiser les champs et rediriger
        _formKey.currentState!.reset();
        Navigator.pop(context);
      } else {
        // Gérer une erreur d'insertion dans la table CLIENT
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'insertion dans la table client : ${response.error!.message}')),
        );
      }
    } else {
      // Si l'utilisateur est null, une erreur s'est produite
      throw 'Erreur lors de la récupération de l’utilisateur.';
    }
  } catch (e) {
    // Gérer les exceptions
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inattendue : $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: constraints.maxHeight * 0.1),
                Image.network(
                  "https://i.postimg.cc/nz0YBQcH/Logo-light.png",
                  height: 100,
                ),
                Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "Connexion",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 35),
                      ),
                    )),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                              controller: _nomController,
                              decoration: InputDecoration(
                                hintText: "Nom",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0 * 1.5, vertical: 16.0),
                                filled: true,
                                fillColor: Color(0xFFF5FCF9),
                              ),
                            )),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: TextFormField(
                            controller: _prenomController,
                            decoration: InputDecoration(
                                hintText: "Prénom",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0 * 1.5, vertical: 16.0),
                                filled: true,
                                fillColor: Color(0xFFF5FCF9)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: TextFormField(
                            controller: _mailController,
                            decoration: InputDecoration(
                                hintText: "Email",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0 * 1.5, vertical: 16.0),
                                filled: true,
                                fillColor: Color(0xFFF5FCF9)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: "Mot de passe",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0 * 1.5, vertical: 16.0),
                                filled: true,
                                fillColor: Color(0xFFF5FCF9)),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: SignUp,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF00BF6D),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              "Mot de passe oublié ?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(0.64),
                                  ),
                            )),
                        TextButton(
                            onPressed: () {},
                            child: Text.rich(
                              const TextSpan(
                                text: "Don’t have an account? ",
                                children: [
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(color: Color(0xFF00BF6D)),
                                  ),
                                ],
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(0.64),
                                  ),
                            ))
                      ],
                    ))
              ],
            ),
          );
        }),
      ),
    );
  }
}
