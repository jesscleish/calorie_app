import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database.dart'; //importing my db

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TodaysMealPlanScreen()),
                );
              },
              child: Text('Today\'s Meal Plan'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateCalorieTargetScreen()),
                );
              },
              child: Text('Create Calorie Target'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PastMealPlansScreen()),
                );
              },
              child: Text('Past Meal Plans'),
            ),
          ],
        ),
      ),
    );
  }
}

class TodaysMealPlanScreen extends StatefulWidget {
  @override
  _TodaysMealPlanScreenState createState() => _TodaysMealPlanScreenState();
}

class _TodaysMealPlanScreenState extends State<TodaysMealPlanScreen> {
  List<Map<String, dynamic>> foodEntries = [];
  int? calorieTarget;
  int totalCalories = 0;

  FoodDatabase foodDatabase = FoodDatabase.instance;

  @override
  void initState() {
    super.initState();
    getCurrentDateEntries();
  }

  Future<void> getCurrentDateEntries() async {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int? calories = await foodDatabase.getTargetCaloriesForDate(currentDate);
    List<Map<String, dynamic>> entries =
    await foodDatabase.getFoodEntriesForDate(currentDate);

    setState(() {
      calorieTarget = calories;
      foodEntries = entries;
      totalCalories = _calculateTotalCalories(entries);
    });
  }

  int _calculateTotalCalories(List<Map<String, dynamic>> entries) {
    int total = 0;
    for (var entry in entries) {
      total += entry['calories'] as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    bool exceededCalories = totalCalories > (calorieTarget ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Meal Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (calorieTarget != null)
              Text(
                'Calorie Target: $calorieTarget',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 10),
            Text(
              'Total Calories: $totalCalories',
              style: TextStyle(
                fontSize: 18,
                color: exceededCalories ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: foodEntries.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text('Food: ${foodEntries[index]['foodName']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Portion: ${foodEntries[index]['portion']}'),
                          Text('Calories: ${foodEntries[index]['calories']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _deleteEntry(foodEntries[index]['id']);
                          await getCurrentDateEntries(); // Refresh the list after deletion
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFoodScreen(),
            ),
          );
          if (result == true) {
            await getCurrentDateEntries(); // Refresh the list after adding new food
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteEntry(int? id) async {
    await foodDatabase.deleteFoodEntry(id);
  }
}



class AddFoodScreenPast extends StatefulWidget {
  final String searchedDate;

  AddFoodScreenPast({required this.searchedDate});

  @override
  _AddFoodScreenPastState createState() => _AddFoodScreenPastState();
}

class _AddFoodScreenPastState extends State<AddFoodScreenPast> {
  List<Map<String, dynamic>> foods = [];
  String? selectedFood;
  int portions = 1;

  FoodDatabase foodDatabase = FoodDatabase.instance;

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    List<Map<String, dynamic>> foodList = await foodDatabase.getFoods();
    setState(() {
      foods = foodList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Date: ${widget.searchedDate}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Select Food:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedFood,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFood = newValue;
                });
              },
              items: foods.map<DropdownMenuItem<String>>((Map<String, dynamic> food) {
                return DropdownMenuItem<String>(
                  value: food['name'].toString(),
                  child: Text(food['name'].toString()),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Number of Portions:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                portions = int.tryParse(value) ?? 1;
              },
              decoration: InputDecoration(
                hintText: 'Enter Number of Portions',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (selectedFood != null && portions > 0) {
                  Map<String, dynamic> foodData = foods.firstWhere(
                        (food) => food['name'] == selectedFood,
                    orElse: () => {},
                  );
                  int calories = (foodData['calories'] ?? 0) * portions;

                  await foodDatabase.insertFoodEntry(
                    selectedFood!,
                    widget.searchedDate,
                    portions,
                    calories,
                  );
                  Navigator.of(context).pop(); // Go back to the previous screen
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}



class AddFoodScreen extends StatefulWidget {
  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  List<Map<String, dynamic>> foods = [];
  String? selectedFood;
  int portions = 1;

  FoodDatabase foodDatabase = FoodDatabase.instance;

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    List<Map<String, dynamic>> foodList = await foodDatabase.getFoods();
    setState(() {
      foods = foodList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select Food:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedFood,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFood = newValue;
                });
              },
              items: foods.map<DropdownMenuItem<String>>((Map<String, dynamic> food) {
                return DropdownMenuItem<String>(
                  value: food['name'].toString(),
                  child: Text(food['name'].toString()),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Number of Portions:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                portions = int.tryParse(value) ?? 1;
              },
              decoration: InputDecoration(
                hintText: 'Enter Number of Portions',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (selectedFood != null && portions > 0) {
                  Map<String, dynamic> foodData = foods.firstWhere(
                        (food) => food['name'] == selectedFood,
                    orElse: () => {},
                  );
                  int calories = (foodData['calories'] ?? 0) * portions;
                  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

                  await foodDatabase.insertFoodEntry(selectedFood!, currentDate, portions, calories);
                  Navigator.pop(context, true); // Go back to the previous screen with a success flag
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}


class CreateCalorieTargetScreen extends StatelessWidget {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();

  final FoodDatabase foodDatabase = FoodDatabase.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Calorie Target'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Target Date:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                hintText: 'Enter Target Date! (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Target Calories:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Target Calories',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String targetDate = dateController.text;
                int targetCalories = int.tryParse(caloriesController.text) ?? 0;

                if (_isDateValid(targetDate)) {
                  await _saveCalorieTarget(targetDate, targetCalories);
                  Navigator.of(context).pop();
                } else {
                  print('Please enter a valid date format (YYYY-MM-DD)');
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCalorieTarget(String date, int calories) async {
    await foodDatabase.insertLimit(date, calories);
    print('Target Date: $date');
    print('Target Calories: $calories');
  }

  bool _isDateValid(String input) {
    final RegExp regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return regex.hasMatch(input);
  }
}
class PastMealPlansScreen extends StatefulWidget {
  @override
  _PastMealPlansScreenState createState() => _PastMealPlansScreenState();
}

class _PastMealPlansScreenState extends State<PastMealPlansScreen> {
  final TextEditingController dateController = TextEditingController();
  List<Map<String, dynamic>> entries = [];
  String errorMessage = '';
  int? targetCalories = 0;
  int totalCaloriesConsumed = 0;
  bool hasSearchedDay = false;
  String searchedDate = '';

  FoodDatabase foodDatabase = FoodDatabase.instance;

  Future<void> getFoodEntriesForDate(String date) async {
    List<Map<String, dynamic>> queriedEntries = await foodDatabase.getFoodEntriesForDate(date);

    int? calories = await foodDatabase.getTargetCaloriesForDate(date);

    setState(() {
      entries = queriedEntries;
      errorMessage = ''; // Clear previous error message
      totalCaloriesConsumed = _calculateTotalCalories(queriedEntries);
      hasSearchedDay = true;
      searchedDate = date;
      targetCalories = calories;
    });
  }

  int _calculateTotalCalories(List<Map<String, dynamic>> entries) {
    int total = 0;
    for (var entry in entries) {
      total += entry['calories'] as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    bool exceededCalories = totalCaloriesConsumed > (targetCalories ?? 0);
    Color caloriesTextColor = exceededCalories ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text('Other Meal Plans'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Enter Date (YYYY-MM-DD):',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                hintText: 'Enter Date',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String enteredDate = dateController.text.trim();
                if (_isDateValid(enteredDate)) {
                  await getFoodEntriesForDate(enteredDate);
                  setState(() {
                    if (entries.isEmpty) {
                      errorMessage = 'No entries found for the entered date';
                    } else {
                      errorMessage = '';
                    }
                  });
                } else {
                  setState(() {
                    errorMessage = 'Please enter a valid date format (YYYY-MM-DD)';
                    entries.clear();
                    hasSearchedDay = false;
                  });
                }
              },
              child: Text('Search'),
            ),
            SizedBox(height: 10),
            if (hasSearchedDay)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calorie Target: $targetCalories',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Total Calories: $totalCaloriesConsumed',
                    style: TextStyle(
                      fontSize: 18,
                      color: caloriesTextColor,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            Expanded(
              child: entries.isNotEmpty
                  ? ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text('Food: ${entries[index]['foodName']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Portion: ${entries[index]['portion']}'),
                          Text('Calories: ${entries[index]['calories']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteEntry(entries[index]['id']);
                        },
                      ),
                    ),
                  );
                },
              )
                  : errorMessage.isNotEmpty
                  ? Center(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              )
                  : SizedBox(),
            ),
          ],
        ),
      ),
      floatingActionButton: hasSearchedDay
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddFoodScreenPast(searchedDate: searchedDate),
            ),
          );
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }

  bool _isDateValid(String input) {
    final RegExp regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return regex.hasMatch(input);
  }

  Future<void> _deleteEntry(int? id) async {
    await foodDatabase.deleteFoodEntry(id);
    await getFoodEntriesForDate(dateController.text.trim());
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }
}
