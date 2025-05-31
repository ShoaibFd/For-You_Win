import 'package:flutter/material.dart';

class QuantityProvider extends ChangeNotifier {
  List<int> _quantities = [];

  List<int> get quantities => _quantities;

  void initialize(int length) {
    _quantities = List.generate(length, (_) => 1);
    notifyListeners();
  }

  void increase(int index) {
    _quantities[index]++;
    notifyListeners();
  }

  void decrease(int index) {
    if (_quantities[index] > 1) {
      _quantities[index]--;
      notifyListeners();
    }
  }
}
