import 'package:sqflite/sqflite.dart';
import '../database/connections.dart';

class CustomerDB{
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  Future<Map<String, dynamic>?> getCustomerDetails(String email, String phoneNumber) async {
    final Database db = await _dbService.db;
      // Execute the query to fetch customer data based on email and phone number
    final List<Map<String, dynamic>> customers = await db.rawQuery(
      'SELECT * FROM CustomerTable WHERE Email = ? AND PhoneNo = ?',
      [email, phoneNumber],
    );

    // Return the first customer found
    if (customers.isNotEmpty) {
      return customers.first;
    } else {
      return null;
    }
  }

}