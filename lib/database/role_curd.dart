import 'package:buybyeq/database/connections.dart';
import 'package:buybyeq/database/rolemodel.dart';
import 'package:buybyeq/database/table_creation.dart';
import 'package:sqflite/sqflite.dart';

class Rolecurdmap {
  ConnectionSQLiteService _connection = ConnectionSQLiteService.instance;

  Future<Database> _getDatabase() async {
    return await _connection.db;
  }

  Future<Role> add(Role x) async {
    try {
      Database db = await _getDatabase();
      int RoleId = await db.rawInsert(RoleTableCreate.addrole(x));
      x.RoleId = RoleId;
      return x;
    } catch (x) {
      throw Exception();
    }
  }

  Future<bool> update(Role x) async {
    try {
      Database db = await _getDatabase();
      int affectedlines = await db.rawUpdate(RoleTableCreate.updaterole(x));
      if (affectedlines > 0) {
        return true;
      }
      return false;
    } catch (error) {
      throw Exception();
    }
  }

  Future<List<Role>> selectall() async {
    try {
      Database db = await _getDatabase();
      List<Map> data = await db.rawQuery(RoleTableCreate.selectallroles());
      List<Role> x = Role.fromSQLiteList(data);
      return x;
    } catch (error) {
      throw Exception();
    }
  }

  Future<void> deleteItem(int id) async {
    final db = await _getDatabase(); // Get a reference to the database.
    await db.delete(
      'Role',
      where: 'RoleId = ?',
      whereArgs: [id],
    );
  }

// Future<void> updateItem(int id,String RoleName) async {
//   final db = await _getDatabase();
//   await db.update(
//     'Role',
//     {
//       'RoleName': RoleName
//     },
//     where: 'RoleId = ?',
//     whereArgs: [id],
//   );
// }
}