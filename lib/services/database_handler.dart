// imports
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../entities/user.dart';

class DatabaseHandler {
  static Database? _database;

  // Singleton pattern to ensure only one instance of the database
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initializeDB();
    return _database!;
  }

  Future<Database> initializeDB() async {
    // Use the ffi web factory on the web platform
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    String path;
    if (kIsWeb) {
      // Web-specific database path
      path = 'news_app.db';
    } else {
      // Mobile/desktop path
      path = await getDatabasesPath();
      path = join(path, 'news_app.db');
    }

    // Open the database and create table if it does not exist
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, pass TEXT NOT NULL)",
        );
        print("Database and table 'user' created.");
      },
    );

    print("Database path: $path");
    print("Database opened successfully");
    return db;
  }

  // method to add users to db
  Future<int> addUser(List<User> users) async {
    final Database db = await database;
    int result = 0;
    // this can go through multiple user objects and add them all to db
    await db.transaction((txn) async {
      for (var user in users) {
        int rowId = await txn.insert('user', user.toMap());
        print("Inserted user with ID: $rowId");
        result += rowId;
      }
    });
    return result;
  }

  // method to get all users
  Future<List<User>> retriveUsers() async {
    final db = await database;
    final List<Map<String, Object?>> queryResult = await db.query('user');
    print("Retrieved users from database: ${queryResult.length}");
    // return results as a list (started as a map -> output as a list)
    return queryResult.map((e) => User.fromMap(e)).toList();
  }

  // method to delete user from db
  Future<void> deleteUser(int id) async {
    final db = await database;
    // done using id
    await db.delete('user', where: "id = ?", whereArgs: [id]);
    print("Deleted user with ID: $id");
  }

  // method to close connection to db
  Future<void> closeDB() async {
    final db = await database;
    await db.close();
    _database = null; // Reset the database instance
    print("Database closed");
  }
}
