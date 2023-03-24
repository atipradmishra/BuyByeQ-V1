import 'package:buybyeq/database/connections.dart';
import 'package:buybyeq/database/table_creation.dart';
import 'package:sqflite/sqflite.dart';
import 'item_category_mapping.dart';


class MenuCategoryMappingcurdmap {
  ConnectionSQLiteService _connection = ConnectionSQLiteService.instance;

  Future<Database> _getDatabase() async {
    return await _connection.db;
  }

  Future<Menu_Category_Mapping> add(Menu_Category_Mapping x) async {
    try {
      Database db = await _getDatabase();
      int ItemCategoryMappingId = await db.rawInsert(ItemCategoryMappingTableCreate.addmaping(x));
      x.ItemCategoryMappingId = ItemCategoryMappingId;
      return x;
    } catch (x) {
      throw Exception();
    }
  }


  Future<void> Update(int menu_id, String category_id) async {
    final Database db = await _getDatabase();

    await db.update(
      "ItemCategoryMapping",
      {
        "MenuCategoryId": category_id,
      },
      where: "MenuItemId = ?",
      whereArgs: [menu_id],
    );
  }

}
