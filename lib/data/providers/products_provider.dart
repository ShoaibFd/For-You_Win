import 'package:flutter/material.dart';

class QuantityProvider extends ChangeNotifier {
  List<int> _quantities = [];

  List<int> get quantities => _quantities;

  void initialize(int length) {
    _quantities = List.generate(length, (_) => 1);
    notifyListeners();
  }

  void increase(int index) {
    if (index < _quantities.length && _quantities[index] < 15) {
      _quantities[index]++;
      notifyListeners();
    }
  }

  void decrease(int index) {
    if (index < _quantities.length && _quantities[index] > 1) {
      _quantities[index]--;
      notifyListeners();
    }
  }

  void resetAll(int length) {
    _quantities = List.filled(length, 1);
    notifyListeners();
  }

  void clear() {
    _quantities.clear();
    notifyListeners();
  }

  int getQuantity(int index) {
    if (index < _quantities.length) {
      return _quantities[index];
    }
    return 1;
  }

  void setQuantity(int index, int quantity) {
    if (index < _quantities.length && quantity >= 1 && quantity <= 15) {
      _quantities[index] = quantity;
      notifyListeners();
    }
  }
}
