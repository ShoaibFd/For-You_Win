
import 'dart:math';

List<int> generateQuickPickNumbers(int count, int maxNumber, {int maxTries = 100}) {
  final rand = Random();
  List<int> available = List.generate(maxNumber, (i) => i + 1);

  for (int attempt = 0; attempt < maxTries; attempt++) {
    available.shuffle();
    final selected = available.take(count).toList();
    if (selected.toSet().length == count) {
      return selected;
    }
  }
  return []; // fallback if unable to generate
}

bool validateTwoDigitNumbers(List<String> values) {
  if (values.length != 6) return false;
  final seen = <String>{};
  for (final v in values) {
    if (v.length != 2 || !RegExp(r'^\d{2}\$').hasMatch(v)) return false;
    if (!seen.add(v)) return false;
    final intVal = int.parse(v);
    if (intVal < 1 || intVal > 25) return false;
  }
  return true;
}
