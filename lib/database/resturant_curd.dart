import 'package:buybyeq/database/connections.dart';
import 'package:buybyeq/database/resturantdetail.dart';
import 'package:buybyeq/database/table_creation.dart';
import 'package:sqflite/sqflite.dart';


class Resturantcurdmap {
  ConnectionSQLiteService _connection = ConnectionSQLiteService.instance;

  Future<Database> _getDatabase() async {
    return await _connection.db;
  }

  Future<Resturant> add(Resturant x) async {
    try {
      Database db = await _getDatabase();
      int RestaurantID = await db.rawInsert(RestaurantTableCreate.addresturant(x));
      x.RestaurantID = RestaurantID;
      return x;
    } catch (x) {
      throw Exception();
    }
  }

  Future<bool> update(Resturant x) async {
    try {
      Database db = await _getDatabase();
      int affectedlines = await db.rawUpdate(RestaurantTableCreate.updateresturant(x));
      if (affectedlines > 0) {
        return true;
      }
      return false;
    } catch (error) {
      throw Exception();
    }
  }

  Future<List<Resturant>> selectall() async {
    try {
      Database db = await _getDatabase();
      List<Map> data = await db.rawQuery(RestaurantTableCreate.selectallresturants());
      List<Resturant> x = Resturant.fromSQLiteList(data);
      return x;
    } catch (error) {
      throw Exception();
    }
  }

}