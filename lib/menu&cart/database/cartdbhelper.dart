import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../database/connections.dart';
import '../models/cartmodel.dart';

class CartDBHelper {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;

  Future<Database> get database async {
    final db = await ConnectionSQLiteService.instance.db;

    return db;
  }

  Future<void> createTable(Database db) async {
    final List<Map<String, dynamic>> tables = await db.query("sqlite_master",
        where: "type = 'table' AND name = 'cart'");
    if (tables.isEmpty) {
      await db.execute(
          'CREATE TABLE cart(MenuItemId INTEGER PRIMARY KEY AUTOINCREMENT, '
              'MenuItemName TEXT,MenuId INTEGER, OrderId INTEGER, productPrice REAL,'
              ' quantity INTEGER, unitTag TEXT, image TEXT)');
    }
  }

  // inserting data into the table
  Future<Cart> insert(Cart cart) async {
    final Database db = await _dbService.db;
    var dbClient = db;
    dbClient = await database;
    await createTable(dbClient);
    await dbClient.insert('cart', cart.toMap());
    return cart;
  }

  // getting all the items in the list from the database
  Future<List<Cart>> getCartList() async {
    final Database db = await _dbService.db;
    var dbClient = db;
    dbClient = await database;
    final List<Map<String, Object?>> queryResult = await dbClient.query('cart');
    return queryResult.map((result) => Cart.fromMap(result)).toList();
  }

  Future<int> updateQuantity(Cart cart) async {
    final Database db = await _dbService.db;
    var dbClient = db;
    dbClient = await database;
    return await dbClient.update('cart', cart.toMap(),
        where: "MenuItemId = ?", whereArgs: [cart.productId]);
  }

  // deleting an item from the cart screen
  Future<int> deleteCartItem(int id) async {
    final Database db = await _dbService.db;
    var dbClient = db;
    dbClient = await database;
    return await dbClient
        .delete('cart', where: 'MenuItemId = ?', whereArgs: [id]);
  }

  Future<void> clearCart() async {
    final Database db = await _dbService.db;
    var dbClient = db;
    dbClient = await database;
    await dbClient.delete('cart');
  }

  Future<void> copyTableToOrder(Database db) async {
    // Query the "cart" table to get the data
    final List<Map<String, dynamic>> data = await db.query("cart");

    // Insert the data into a new table with similar fields

    for (final row in data) {
      await db.rawInsert(
          'INSERT INTO OrderDetail'
              '(MenuItemId, Quantity, Price, UpdatedOn) '
              'VALUES (?, ?, ?, ?)',
          [
            row['MenuId'],
            row['quantity'],
            row['productPrice'],
            DateFormat('MM/dd/yyyy').format(DateTime.now())
          ]);
    }
  }

  Future<void> copyTableToCart(Database db, int orderId) async {
    // Query the "OrderDetail" table to get the data for the given orderId
    final List<Map<String, dynamic>> data = await db.query(
      "OrderDetail",
      where: "OrderId = ?",
      whereArgs: [orderId],
    );

    // Insert the data into the "cart" table
    for (final row in data) {
      // Retrieve the MenuItemName from the "MenuItem" table
      final int menuItemId = row['MenuItemId'];
      final List<Map<String, dynamic>> menuItemData = await db.query(
        "MenuItem",
        where: "MenuItemId = ?",
        whereArgs: [menuItemId],
        limit: 1,
      );
      final String menuItemName = menuItemData[0]['MenuItemName'];
      final String menuItemCat = menuItemData[0]['Type'];

      // Insert the data into the "cart" table
      await db.rawInsert(
        'INSERT INTO cart'
            '(OrderId, MenuId, MenuItemName, Quantity, unitTag, productPrice) '
            'VALUES (?, ?, ?, ?, ?, ?)',
        [
          row['OrderId'],
          menuItemId,
          menuItemName,
          row['Quantity'],
          menuItemCat,
          row['Price'],
        ],
      );
    }
  }

  Future<void> UpdateTableToOrder(Database db) async {
    // Query the "cart" table to get the data
    final List<Map<String, dynamic>> data = await db.query("cart");

    // Begin transaction
    await db.transaction((txn) async {
      // Delete all rows in OrderDetail with the same OrderId as in cart table
      await txn.rawDelete('DELETE FROM OrderDetail WHERE OrderId = ?', [data[0]['OrderId']]);

      // Insert new data into OrderDetail table
      for (final row in data) {
        await txn.insert('OrderDetail', {
          'OrderId': row['OrderId'],
          'MenuItemId': row['MenuId'],
          'Quantity': row['quantity'],
          'Price': row['productPrice'],
          'UpdatedOn': DateFormat('MM/dd/yyyy').format(DateTime.now()),
        });
      }
    });
  }

  Future<int> markOrderAsPending(String phoneNumber) async {
    final db = await database;
    final String time=DateFormat('hh:mm a').format(DateTime.now());
    final orderId = await db.transaction<int>((txn) async {
      final orderData = <String, dynamic>{
        'OrderStatus': 'Pending',
        'PaymentStatus': 'Not Paid',
        'OrderDate':DateFormat('MM/dd/yyyy').format(DateTime.now()),
      'OrderTime':time,

      };

      // Get the customer ID based on the phone number
      final customer = await txn.query('CustomerTable', where: 'PhoneNo = ?', whereArgs: [phoneNumber]);
      print(customer);
      if (customer.isNotEmpty) {
        orderData['CustomerID'] = customer.first['CustomerID'];
      } else {
        print('Customer not found');
      }


      final orderId = await txn.insert('CartOrder', orderData);

      final updateData = <String, dynamic>{
        'OrderId': orderId,
      };
      await txn.update('OrderDetail', updateData, where: 'OrderId IS NULL OR OrderId = 0');

      return orderId;
    });

    return orderId;
  }

  Future<int> markOrderAsComplete(String cusid) async {
    final db = await database;
    final String time = DateFormat('hh:mm a').format(DateTime.now());
    final orderId = await db.transaction<int>((txn) async {
        final orderData = <String, dynamic>{
          'CustomerID': cusid,
          'OrderStatus': 'Complete',
          'PaymentStatus': 'Paid',
          'OrderDate': DateFormat('MM/dd/yyyy').format(DateTime.now()),
          'OrderTime': time,
        };

        final orderId = await txn.insert('CartOrder', orderData);

        final updateData = <String, dynamic>{
          'OrderId': orderId,
        };
        await txn.update('OrderDetail', updateData, where: 'OrderId IS NULL OR OrderId = 0');

        return orderId;

    });

    return orderId;
  }



  Future<void> updateCartOrderStatus(int orderId) async {
    final Database db = await _dbService.db;
    // Update the fields in the  CartOrder table
    await db.update(
      "CartOrder",
      {
        "OrderStatus": "Complete",
        "PaymentStatus": "Paid",
      },
      where: "OrderId = ?",
      whereArgs: [orderId],
    );
  }

}