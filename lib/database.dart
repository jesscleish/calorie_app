import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FoodDatabase {
  static Database? _database;
  static final FoodDatabase instance = FoodDatabase._privateConstructor();

  FoodDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    //create limits table
    await db.execute('''
      CREATE TABLE limits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        max_calories INTEGER
      )
    ''');

    //create food entry table
    await db.execute('''
      CREATE TABLE food_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        foodName TEXT,
        portion TEXT,
        date TEXT,
        calories INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE foods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        calories INTEGER
      )
    ''');

    // Insert 20 records of food and their calorie values
    Batch batch = db.batch();
    List<Map<String, dynamic>> foods = [
      {'name': 'Apple', 'calories': 37},
      {'name': 'Apricot', 'calories': 34},
      {'name': 'Avocado', 'calories': 134},
      {'name': 'Banana', 'calories': 51},
      {'name': 'Blackberries', 'calories': 21},
      {'name': 'Blackcurrant', 'calories': 24},
      {'name': 'Cherries', 'calories': 36},
      {'name': 'Clementine', 'calories': 39},
      {'name': 'Coconut (Fresh)', 'calories': 351},
      {'name': 'Cranberries', 'calories': 15},
      {'name': 'Cucumber', 'calories': 15},
      {'name': 'Dates (Dried)', 'calories': 227},
      {'name': 'Figs (Fresh)', 'calories': 209},
      {'name': 'Grapefruit', 'calories': 25},
      {'name': 'Kiwi', 'calories': 42},
      {'name': 'Lemon', 'calories': 15},
      {'name': 'Lime', 'calories': 9},
      {'name': 'Lychee', 'calories': 36},
      {'name': 'Mango', 'calories': 39},
      {'name': 'Acorn squash', 'calories': 40},
      {'name': 'Artichoke', 'calories': 41},
      {'name': 'Asparagus', 'calories': 29},
      {'name': 'Beetroot', 'calories': 42},
      {'name': 'Broccoli', 'calories': 35},
      {'name': 'Brussels Sprout', 'calories': 51},
      {'name': 'Butternut squash', 'calories': 36},
      {'name': 'Cabbage', 'calories': 27},
      {'name': 'Carrot', 'calories': 10},
      {'name': 'Cauliflower', 'calories': 30},
      {'name': 'Celery', 'calories': 8},
      {'name': 'Chicory', 'calories': 11},
      {'name': 'Corn', 'calories': 54},
      {'name': 'Edamame', 'calories': 140},
      {'name': 'Green beans', 'calories': 25},
      {'name': 'Iceberg lettuce', 'calories': 10},
      {'name': 'Kale', 'calories': 30},
      {'name': 'Leek', 'calories': 20},
      {'name': 'Mushroom', 'calories': 8},
      {'name': 'Onion', 'calories': 43},
      {'name': 'Peas', 'calories': 70},
      {'name': 'Peppers (Red)', 'calories': 21},
      {'name': 'Potato', 'calories': 97},
      {'name': 'Pumpkin', 'calories': 13},
      {'name': 'Radish', 'calories': 33},
      {'name': 'Romaine Lettuce', 'calories': 15},
      {'name': 'Spinach', 'calories': 24},
      {'name': 'Bean Sprouts', 'calories': 30},
      {'name': 'Turnips', 'calories': 23},
      {'name': 'Yam', 'calories': 153},
      {'name': 'Zucchini', 'calories': 10},
      {'name': 'Bacon (pork)', 'calories': 240},
      {'name': 'Chicken Breast', 'calories': 148},
      {'name': 'Chicken Wings', 'calories': 110},
      {'name': 'Chicken Thighs', 'calories': 133},
      {'name': 'Chicken Eggs', 'calories': 155},
      {'name': 'Duck (no skin)', 'calories': 195},
      {'name': 'Escargots', 'calories': 90},
      {'name': 'Lamb', 'calories': 122},
      {'name': 'Liver', 'calories': 119},
      {'name': 'Sausage (chicken)', 'calories': 172},
      {'name': 'Sausage (turkey)', 'calories': 196},
      {'name': 'Sausage (pork)', 'calories': 318},
      {'name': 'Quail Eggs', 'calories': 158},
      {'name': 'Turkey (dark meat)', 'calories': 184},
      {'name': 'Tukey (white meat)', 'calories': 104},
      {'name': 'Venison', 'calories': 157},
      {'name': 'Butter', 'calories': 716},
      {'name': 'Buttermilk (1%)', 'calories': 41},
      {'name': 'Cheddar Cheese', 'calories': 403},
      {'name': 'Cottage Cheese (1%)', 'calories': 72},
      {'name': 'Cream (heavy)', 'calories': 347},
      {'name': 'Cream Cheese', 'calories': 231},
      {'name': 'Evaporated milk', 'calories': 142},
      {'name': 'Ghee', 'calories': 899},
      {'name': 'Goats Milk', 'calories': 71},
      {'name': 'Ice Cream (vanilla)', 'calories': 207},
      {'name': 'Kefir', 'calories': 67},
      {'name': 'Ricotta Cheese', 'calories': 174},
      {'name': 'Skim Milk', 'calories': 38},
      {'name': 'Sour cream', 'calories': 214},
      {'name': 'Soy milk', 'calories': 46},
      {'name': 'Swiss Cheese', 'calories': 380},
      {'name': 'Yogurt (whole milk)', 'calories': 61},
      {'name': 'Yogurt (no fat)', 'calories': 55},
      {'name': 'Whole Milk', 'calories': 62},
    ];


    foods.forEach((food) {
      batch.insert('foods', food);
    });

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getFoods() async {
    Database db = await instance.database;
    return await db.query('foods');
  }

  Future<List<Map<String, dynamic>>> getFoodEntriesForDate(String date) async {
    Database db = await instance.database;
    return await db.query(
      'food_entries',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<int?> getTargetCaloriesForDate(String date) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'limits',
      columns: ['max_calories'],
      where: 'date = ?',
      whereArgs: [date],
    );

    if (result.isNotEmpty) {
      return result.first['max_calories'] as int?;
    } else {
      return null;
    }
  }

  Future<void> insertLimit(String date, int calories) async {
    Database db = await database;
    await db.insert(
      'limits',
      {'date': date, 'max_calories': calories},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<void> insertFoodEntry(String foodName, String date, int portions, int calories) async {
    Database db = await database;
    await db.insert(
      'food_entries',
      {
        'foodName': foodName,
        'date': date,
        'portion': portions,
        'calories': calories,
      },
    );
  }

  Future<void> deleteFoodEntry(int? id) async {
    Database db = await database;
    await db.delete('food_entries', where: 'id = ?', whereArgs: [id]);
  }

}
