import 'package:appli2/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final authService = AuthService();
    void logout()async{
    await authService.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(onPressed: logout, icon: Icon(Iconsax.logout)),
      ),
    );
  }
}