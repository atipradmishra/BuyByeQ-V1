import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../database/connections.dart';
import '../models/item_model.dart';

class DatabaseHelper {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;

  Future<List<Item>> getFoodItems(String query) async {
    final Database db = await _dbService.db;
    final List<Map<String, dynamic>> maps = await db.query('MenuItem');

    return List.generate(maps.length, (i) {
      return Item(
        id: maps[i]['MenuItemId'],
        name: maps[i]['MenuItemName'],
        price: maps[i]['Price'],
        unit: maps[i]['Type'],
        image: maps[i]['ImagePath'],
      );
    })
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<String>> getCategories() async {
    final Database db = await _dbService.db;
    final List<Map<String, dynamic>> maps =
    await db.query('MenuCategory', columns: ['MenuCategoryName'], distinct: true);

    return List.generate(maps.length, (i) {
      return maps[i]['MenuCategoryName'];
    });
  }

  Future<int?> getMenuItemId(String menuItemName) async {
    final Database db = await _dbService.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'MenuItem',
      columns: ['MenuItemId'],
      where: 'MenuItemName = ?',
      whereArgs: [menuItemName],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['MenuItemId'];
    } else {
      return null;
    }
  }



}
