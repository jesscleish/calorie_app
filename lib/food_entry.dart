import 'package:intl/intl.dart';

class FoodEntry {
  int? id;
  String foodName;
  String portion;
  DateTime date;
  int calories; // Added calories attribute

  FoodEntry({
    this.id,
    required this.foodName,
    required this.portion,
    required this.date,
    required this.calories, // Updated constructor to include calories
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodName': foodName,
      'portion': portion,
      'date': DateFormat('yyyy-MM-dd').format(date.toUtc()), // Convert DateTime to string format in UTC
      'calories': calories, // Include calories in the map
    };
  }

  static FoodEntry fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      id: map['id'],
      foodName: map['foodName'],
      portion: map['portion'],
      date: DateFormat('yyyy-MM-dd').parse(map['date']).toLocal(), // Parse string back to DateTime in local time
      calories: map['calories'], // Assign value to calories attribute
    );
  }

  DateTime toEasternTime() {
    return date.toLocal(); // Convert stored date to local time (EST)
  }
}
