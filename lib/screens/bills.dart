import 'package:flutter/material.dart';

class BillsScreen extends StatefulWidget {
  final int total;
  const BillsScreen({super.key , required this.total});
  @override
  State<StatefulWidget> createState() {
    
    return BillsScreenState();
  }
}

class BillsScreenState extends State<BillsScreen> {


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("vous avez payer votre facture de ${widget.total} Fcfa"),
      ),
    );
  }
}