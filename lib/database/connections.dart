import 'dart:async';
import 'package:buybyeq/database/table_creation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ConnectionSQLiteService {
  ConnectionSQLiteService._();

  static ConnectionSQLiteService? _instance;

  static ConnectionSQLiteService get instance {
    _instance ??= ConnectionSQLiteService._();
    return _instance!;
  }


  static const DATABASE_NAME = 'buybyeq.db';
  static const DATABASE_VERSION = 1;
  Database? _db;

  Future<Database> get db => _openDatabase();

  Future<Database> _openDatabase() async {
    sqfliteFfiInit();
    String databasePath = await getDatabasesPath();
    String path = join(await databasePath, DATABASE_NAME);


    if (_db == null) {
      var _db = await  openDatabase(path,version: 1, onCreate: (Database database, int version) async {
        await createUserTable(database);
      },);
      return _db;
    }
    return _db!;
  }


  static Future<void> createUserTable(Database database) async {
    await database.execute(UserTableCreate.CREATE_TABLE);
    await database.execute(QRTableCreate.CREATE_TABLE);
    await database.execute(MenuCategoryTableCreate.CREATE_TABLE);
    await database.execute(MenuItemTableCreate.CREATE_TABLE);
    await database.execute(OrderTableCreate.CREATE_TABLE);
    await database.execute(OrderDetailTableCreate.CREATE_TABLE);
    await database.execute(PaymentTableCreate.CREATE_TABLE);
    await database.execute(RoleTableCreate.CREATE_TABLE);
    await database.execute(UserRoleMappingTableCreate.CREATE_TABLE);
    await database.execute(RestaurantTableCreate.CREATE_TABLE);
    await database.execute(ItemCategoryMappingTableCreate.CREATE_TABLE);
    await database.execute(CustomerTableCreate.CREATE_TABLE);
  }
}
