import 'package:flutter/material.dart';

class QuantityProvider extends ChangeNotifier{
  int _currentNumber = 1;
  List<int> _baseIngredientAmounts = [];
  int get currentNumber => _currentNumber;

  void setBaseIngredientAmounts(List<int> amounts) {
    _baseIngredientAmounts = amounts;
    notifyListeners();
  }

  List<int>  get updateIngredientAmount{
    return _baseIngredientAmounts.map<int>((amount) =>  (amount * _currentNumber)).toList();
  }
  void increaseQuantity(){
    _currentNumber++;
    notifyListeners();
  }
  void decreaseQuantity(){
    if(_currentNumber>1){
      _currentNumber--;
      notifyListeners();
    }
  }
}