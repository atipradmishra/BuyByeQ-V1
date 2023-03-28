import 'package:buybyeq/database/catagorymodel.dart';
import 'package:buybyeq/database/connections.dart';
import 'package:buybyeq/database/table_creation.dart';
import 'package:sqflite/sqflite.dart';



class Categorycurdmap {
  ConnectionSQLiteService _connection = ConnectionSQLiteService.instance;

  Future<Database> _getDatabase() async {
    return await _connection.db;
  }

  Future<MenuCategory> add(MenuCategory x) async {
    try {
      Database db = await _getDatabase();
      int MenuCategoryId = await db.rawInsert(MenuCategoryTableCreate.addcategory(x));
      x.MenuCategoryId = MenuCategoryId;
      return x;
    } catch (x) {
      throw Exception();
    }
  }

  Future<bool> update(MenuCategory x) async {
    try {
      Database db = await _getDatabase();
      int affectedlines =
      await db.rawUpdate(MenuCategoryTableCreate.updatecategory(x));
      if (affectedlines > 0) {
        return true;
      }
      return false;
    } catch (error) {
      throw Exception();
    }
  }

  Future<List<MenuCategory>> selectall() async {
    try {
      Database db = await _getDatabase();
      List<Map> data = await db.rawQuery(MenuCategoryTableCreate.selectallcatagorys());
      List<MenuCategory> x = MenuCategory.fromSQLiteList(data);
      return x;
    } catch (error) {
      throw Exception();
    }
  }

  Future<void> deleteItem(int id) async {
    final db = await _getDatabase(); // Get a reference to the database.
    await db.delete(
      'MenuCategory',
      where: 'MenuCategoryId = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateItem(int id, String MenuCategoryName, String Description) async {
    final db = await _getDatabase();
    await db.update(
      'MenuCategory',
      {
        'MenuCategoryName': MenuCategoryName,
        'Description': Description
      },
      where: 'MenuCategoryId = ?',
      whereArgs: [id],
    );
  }
}