import 'package:flutter/foundation.dart';

class Customer {
  final String name;
  final String name2;
  final String email;
  final String phoneNumber;
  final String location;

  Customer({
    required this.name,
    required this.name2,
    required this.email,
    required this.phoneNumber,
    required this.location,
  });
}

class CustomerProvider with ChangeNotifier {
  late Customer _customer;

  Customer  get user=>_customer;

  void setCustomer(Customer customer) {
    _customer = customer;
    notifyListeners();
  }
}
