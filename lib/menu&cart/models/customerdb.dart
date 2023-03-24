import 'package:sqflite/sqflite.dart';

import '../../database/connections.dart';

class CustomerDBHelper {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  Future<Database> get database async {
    final db = await ConnectionSQLiteService.instance.db;
    return db;
  }

  Future<List<Map<String, dynamic>>> getOrderDetails() async {
    final Database db = await _dbService.db;
    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT CartOrder.*, CustomerTable.* FROM CartOrder INNER JOIN CustomerTable ON CartOrder.CustomerID = CustomerTable.CustomerID');
    return result;
  }

}
