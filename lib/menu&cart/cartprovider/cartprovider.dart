import 'package:buybyeq/menu&cart/database/menudbhelper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../database/cartdbhelper.dart';
import '../models/cartmodel.dart';
import '../../database/connections.dart';
class CartProvider with ChangeNotifier {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  CartDBHelper dbHelper = CartDBHelper();
  int _counter = 0;
  int _quantity = 1;
  int get counter => _counter;
  int get quantity => _quantity;

  double _totalPrice = 0.0;
  double get totalPrice => _totalPrice;

  List<Cart> cart = [];

  Future<List<Cart>> getData() async {
    cart = await dbHelper.getCartList();
    notifyListeners();
    return cart;
  }


  double _totalPrice2 = 0.0;
  double get totalPrice2 => _totalPrice2;

  // This method calculates the total price with discount included
  Future<void> calculateTotalPrice2(String name, double productPrice) async {
  DatabaseHelper dbh=DatabaseHelper();
    double? discountPercentage = await getItemDisPer(name);
  if (discountPercentage != null && discountPercentage > 0) {
  _totalPrice2 = (productPrice * (100 - discountPercentage)) / 100;
  } else {
  _totalPrice2 = productPrice;
  }
  notifyListeners();
  }




  void _setPrefsItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('cart_items', _counter);
    prefs.setInt('item_quantity', _quantity);
    prefs.setDouble('total_price', _totalPrice);
    notifyListeners();
  }

  void _getPrefsItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('cart_items') ?? 0;
    _quantity = prefs.getInt('item_quantity') ?? 1;
    _totalPrice = prefs.getDouble('total_price') ?? 0;
  }

  void addCounter() {
    _counter++;
    _setPrefsItems();
    notifyListeners();
  }

  void removeCounter() {
    _counter--;
    _setPrefsItems();
    notifyListeners();
  }

  int getCounter() {
    _getPrefsItems();
    return _counter;
  }

  void addQuantity(int id) {
    final index = cart.indexWhere((element) => element.productId == id);
    cart[index].quantity!.value = cart[index].quantity!.value + 1;
    _setPrefsItems();
    notifyListeners();
  }

  void deleteQuantity(int id) {
    final index = cart.indexWhere((element) => element.productId == id);
    final currentQuantity = cart[index].quantity!.value;
    if (currentQuantity <= 1) {
      currentQuantity == 1;
    } else {
      cart[index].quantity!.value = currentQuantity - 1;
    }
    _setPrefsItems();
    notifyListeners();
  }

  void removeItem(int id) {
    final index = cart.indexWhere((element) => element.productId == id);
    cart.removeAt(index);
    _setPrefsItems();
    notifyListeners();
  }

  int getQuantity(int quantity) {
    _getPrefsItems();
    return _quantity;
  }

  void addTotalPrice(double productPrice) {
    _totalPrice = _totalPrice + productPrice;
    _setPrefsItems();
    notifyListeners();
  }

  void removeTotalPrice(double productPrice) {
    _totalPrice = _totalPrice - productPrice;
    _setPrefsItems();
    notifyListeners();
  }

  double getTotalPrice() {
    _getPrefsItems();
    return _totalPrice;
  }
  void clearCart() {
    cart.clear();
    _counter = 0;
    _quantity = 1;
    _totalPrice = 0.0;
    _setPrefsItems();
    notifyListeners();
  }
  Future<double?> getItemDisPer(String? nem) async {
    final Database db = await _dbService.db;
    final disco = await db.query('MenuItem', where: 'MenuItemName = ?', whereArgs: [nem]);
    if (disco.isNotEmpty) {
      return disco.first['DiscountPercentage'] as double?;
    } else {
      print('MenuItem not found');
      return 0.0;
    }
  }
}

