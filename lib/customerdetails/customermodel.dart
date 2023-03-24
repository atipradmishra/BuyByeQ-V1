class Customer {
  final String name;
  final String phone;
  final String orderStatus;
  final String time;
  final String noItems;
  final String amount;

  Customer({
    required this.name,
    required this.phone,
    required this.orderStatus,
    required this.time,
    required this.noItems,
    required this.amount,
  });


  Customer.fromMap(Map<dynamic, dynamic> data)
      :
        name= data['MenuItemId'],
        phone = data['MenuItemName'],
        orderStatus = data['productPrice'],
        time = data['quantity'],
        noItems = data['unitTag'],
        amount = data['image'];

// toMap: A method that returns a Map object that represents the Cart object.
// The method maps the fields in the Cart object to the keys in the Map object.
  Map<String, dynamic> toMap() {
    return {
      'MenuItemId': name,
      'MenuItemName': phone,
      'productPrice':  orderStatus,
      'quantity': time,
      'unitTag': noItems,
      'image': amount,
    };
  }

}
