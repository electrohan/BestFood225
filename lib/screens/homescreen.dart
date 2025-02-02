
import 'package:appli2/screens/app_home_screen.dart';
import 'package:appli2/screens/favoritescreen.dart';
import 'package:appli2/screens/recipes.dart';
import 'package:appli2/screens/settingscreen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}


class HomeScreenState extends State<HomeScreen> {
  
  int selectedIndex = 0;
  late final List<Widget> page;
  @override
  void initState() {
    super.initState();
    
    
    page = [AppHomeScreen(), Recipes(), FavoriteScreen(), SettingScreen()];
  }

   
  
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconSize: 28,
        selectedItemColor: Color(0xff568A9F),
        currentIndex: selectedIndex,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            selectedIndex = value ;
          });
        },
        items: [
        BottomNavigationBarItem(icon: Icon( selectedIndex == 0? Iconsax.home5 : Iconsax.home_1) , label: "Home"),
        BottomNavigationBarItem(icon: Icon( selectedIndex == 1? Iconsax.add_circle5 : Iconsax.add_circle) , label: "Recipes"),
        BottomNavigationBarItem(icon: Icon( selectedIndex == 2? Icons.favorite : Icons.favorite_border) , label: "favorite"),
        BottomNavigationBarItem(icon: Icon( selectedIndex == 3? Icons.settings : Icons.settings_outlined) , label: "setting"),
      ]),
      body: page[selectedIndex],
    );
  }

  navBarPage(iconName){
    return Center(
      child: Icon(iconName,size: 100,color:Color(0xFF00BF6D))
    );
  }
}