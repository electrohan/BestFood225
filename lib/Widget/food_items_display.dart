import 'package:appli2/Provider/favorite_provider.dart';
import 'package:appli2/screens/recipe_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodItemsDisplay extends StatefulWidget {
  final Map<String?, dynamic> snapshot;
  const FoodItemsDisplay({super.key, required this.snapshot});

  @override
  State<FoodItemsDisplay> createState() => _FoodItemsDisplayState();
}

class _FoodItemsDisplayState extends State<FoodItemsDisplay> {
  final supabase = Supabase.instance.client;
  final user = Supabase.instance.client.auth.currentUser;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailsScreen(snapshot:widget.snapshot),),);
      },
      child: Container(
        margin: EdgeInsets.only(right: 10),
        width: 230,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag:widget.snapshot["Image"] ,
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(widget.snapshot["Image"])),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  widget.snapshot["name"],
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.flash_1,
                          size: 16,
                          color: Colors.grey,
                        ),
                        Text("${widget.snapshot['calorie']} cal",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        Text(
                          " . ",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.grey),
                        ),
                        Icon(
                          Iconsax.clock_1,
                          size: 16,
                          color: Colors.grey,
                        ),
                        Text("${widget.snapshot['time']} min",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                      ],
                    ),
                  ],
                )
              ],
            ),
            Positioned(
                top: 5,
                right: 5,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: InkWell(
                    onTap: () {
                      provider.toggleFavorite(widget.snapshot['id']);
                    },
                    child: Icon(
                      provider.isExisted(widget.snapshot['id']) ? Icons.bookmark : Icons.bookmark_border,
                      color: provider.isExisted(widget.snapshot['id'])  ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}
