import 'package:buybyeq/database/connections.dart';
import 'package:buybyeq/database/table_creation.dart';
import 'package:sqflite/sqflite.dart';

import 'menumodel.dart';



class Menucurdmap {
  ConnectionSQLiteService _connection = ConnectionSQLiteService.instance;

  Future<Database> _getDatabase() async {
    return await _connection.db;
  }

  Future<Menu> add(Menu x) async {
    try {
      Database db = await _getDatabase();
      int MenuItemId = await db.rawInsert(MenuItemTableCreate.addmenu(x));
      x.MenuItemId = MenuItemId;
      return x;
    } catch (x) {
      throw Exception();
    }
  }

  Future<bool> update(Menu x) async {
    try {
      Database db = await _getDatabase();
      int affectedlines = await db.rawUpdate(MenuItemTableCreate.updatemenu(x));
      if (affectedlines > 0) {
        return true;
      }
      return false;
    } catch (error) {
      throw Exception();
    }
  }

  Future<List<Menu>> selectall() async {
    try {
      Database db = await _getDatabase();
      List<Map> data = await db.rawQuery(MenuItemTableCreate.selectallmenus());
      List<Menu> menus = Menu.fromSQLiteList(data);
      return menus;
    } catch (error) {
      throw Exception();
    }
  }

  Future<void> deleteItem(int id) async {
    final db = await _getDatabase(); // Get a reference to the database.
    await db.delete(
      'MenuItem',
      where: 'MenuItemId = ?',
      whereArgs: [id],
    );
  }

}