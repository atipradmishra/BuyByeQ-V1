import 'package:flutter/material.dart';

class Cart {
  late final int? productId;
  late final int? menuId;
  final String? productName;
  final double? productPrice;
  final ValueNotifier<int>? quantity;
  final String? unitTag;
  final String? image;

  Cart(
      {required this.menuId,
      required this.productId,
      required this.productName,
      required this.productPrice,
      required this.quantity,
      required this.unitTag,
      required this.image});

//fromMap: A constructor that creates a Cart object from a Map object.
// The method maps the keys in the Map object to the fields in the Cart object.

  Cart.fromMap(Map<dynamic, dynamic> data)
      : productId = data['MenuItemId'],
        menuId = data['MenuId'],
        productName = data['MenuItemName'],
        productPrice = data['productPrice'],
        quantity = ValueNotifier(data['quantity']),
        unitTag = data['unitTag'],
        image = data['image'];

// toMap: A method that returns a Map object that represents the Cart object.
// The method maps the fields in the Cart object to the keys in the Map object.
  Map<String, dynamic> toMap() {
    return {
      'MenuItemId': productId,
      'MenuId': menuId,
      'MenuItemName': productName,
      'productPrice': productPrice,
      'quantity': quantity?.value,
      'unitTag': unitTag,
      'image': image,
    };
  }
}
