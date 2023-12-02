import 'package:intl/intl.dart';

class MaxCalories {
  int? id;
  DateTime date; // Changed the date type to DateTime
  int maxCalories;

  MaxCalories({this.id, required this.date, required this.maxCalories});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateFormat('yyyy-MM-dd').format(date.toUtc()), // Convert DateTime to string format in UTC
      'maxCalories': maxCalories,
    };
  }

  static MaxCalories fromMap(Map<String, dynamic> map) {
    return MaxCalories(
      id: map['id'],
      date: DateFormat('yyyy-MM-dd').parse(map['date']).toLocal(), // Parse string back to DateTime in local time
      maxCalories: map['maxCalories'],
    );
  }

  DateTime toEasternTime() {
    return date.toLocal(); // Convert stored date to local time (EST)
  }
}
