/// [basePrice] per ticket, [vatPercentage] 
double calculateTotalPrice(double basePrice, double vatPercentage, int numberOfField, int quantity) {
  double total = 0;

  for (int i = 0; i < quantity; i++) {
    int multiplier = numberOfField == 6 ? 1 : 2; 
    double price = basePrice * multiplier;
    double vat = price * (vatPercentage / 100);
    total += price + vat;
  }
  return total;
}

double calculateTotalVAT(double basePrice, double vatPercentage, int numberOfField, int quantity) {
  double totalVAT = 0;
  for (int i = 0; i < quantity; i++) {
    int multiplier = numberOfField == 6 ? 1 : 2;
    double vat = basePrice * multiplier * vatPercentage / 100;
    totalVAT += vat;
  }
  return totalVAT;
}

bool isDuplicate(List<int> current, List<List<int>> others) {
  current.sort();
  for (var list in others) {
    var sorted = [...list]..sort();
    if (sorted.length == current.length &&
        List.generate(sorted.length, (i) => sorted[i] == current[i]).every((v) => v)) {
      return true;
    }
  }
  return false;
}
