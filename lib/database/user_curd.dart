import 'package:buybyeq/database/connections.dart';
import 'package:buybyeq/database/table_creation.dart';
import 'package:buybyeq/database/usemodel.dart';
import 'package:sqflite/sqflite.dart';



class Usercurdmap {
  ConnectionSQLiteService _connection = ConnectionSQLiteService.instance;

  Future<Database> _getDatabase() async {
    return await _connection.db;
  }

  Future<User> add(User x) async {
    try {
      Database db = await _getDatabase();
      int UserId = await db.rawInsert(UserTableCreate.adduser(x));
      x.UserId = UserId;
      return x;
    } catch (x) {
      throw Exception();
    }
  }

  Future<bool> update(User x) async {
    try {
      Database db = await _getDatabase();
      int affectedlines = await db.rawUpdate(UserTableCreate.updateuser(x));
      if (affectedlines > 0) {
        return true;
      }
      return false;
    } catch (error) {
      throw Exception();
    }
  }

  Future<List<User>> selectall() async {
    try {
      Database db = await _getDatabase();
      List<Map> data = await db.rawQuery(UserTableCreate.selectallusers());
      List<User> menus = User.fromSQLiteList(data);
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