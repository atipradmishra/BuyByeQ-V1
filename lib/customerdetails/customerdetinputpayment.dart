import 'dart:async';
import 'package:buybyeq/screens/pagesnav.dart';
import 'package:buybyeq/screens/payments.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../common/appBar/apbar.dart';
import '../database/connections.dart';
import '../menu&cart/cartprovider/cartprovider.dart';
import '../menu&cart/database/cartdbhelper.dart';
import '../menu&cart/screens/cartui.dart';

class MyForm extends StatefulWidget {
  MyForm({
    Key? key,
  }) : super(key: key);
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  double _totalPrice = 0;
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;

  Future<Database> get database async {
    final db = await ConnectionSQLiteService.instance.db;

    return db;
  }

  TextEditingController _namec = TextEditingController();
  TextEditingController _namec2 = TextEditingController();
  TextEditingController _locatc = TextEditingController();
  TextEditingController _emailc = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _name2 = '';
  String _email = '';
  String _phone = '';
  String _location = '';
  bool _detailsFound = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  final StreamController<List<Map<String, dynamic>>> _resultsStream =
      StreamController();

  void _search() async {
    final Database db = await _dbService.db;
    final List<Map<String, dynamic>> customers = await db.rawQuery(
      'SELECT * FROM CustomerTable WHERE PhoneNo LIKE ?',
      ['%$_phone%'],
    );
    _resultsStream.add(customers);
    if (_phone == '') _resultsStream.add([]);
  }

  Future<Map<String, dynamic>?> getCustomerDetails(
      String email, String phoneNumber) async {
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

  // Define a function to insert user details into the database
  Future<void> insertUserDetails() async {
    final db = await database;

    // Check if a customer with the same phone number already exists
    final result = await db.rawQuery(
        'SELECT COUNT(*) FROM CustomerTable WHERE PhoneNo = ?', [_phone]);

    final count = Sqflite.firstIntValue(result);

    if (count != null && count > 0) {
      return;
    }

    // Get the current timestamp
    final currentTime = DateTime.now();

    // Insert the customer details into the database
    await db.insert(
      'CustomerTable',
      {
        'FirstName': _name,
        //'LastName': _name2,
        'Email': _email,
        'PhoneNo': _phone,
        'Address': _location,
        'IsActive': true,
        'UpdatedBy': 1,
        'UpdatedOn': currentTime.toIso8601String(),
      },
    );
  }

  void _calculatePriceWithDiscountPA() {
    setState(() {
      _totalPrice = 0;
    });

    for (var element
        in Provider.of<CartProvider>(context, listen: false).cart) {
      double itemPrice = element.productPrice!;
      int itemQuantity = element.quantity!.value;

      Provider.of<CartProvider>(context, listen: false)
          .getItemDisPer(element.productName)
          .then((double? discount) {
        double itemTotal = itemPrice * itemQuantity;
        double discountedTotal =
            itemTotal - (discount != null ? (itemTotal * discount / 100) : 0);

        setState(() {
          _totalPrice += discountedTotal;
        });
      });
    }
  }

  void _calculatePriceWithDiscountPercent(int id) {
    setState(() {
      _totalPrice = 0;
    });

    for (var element
        in Provider.of<CartProvider>(context, listen: false).cart) {
      double itemPrice = element.productPrice!;
      int itemQuantity = element.quantity!.value;

      Provider.of<CartProvider>(context, listen: false)
          .getItemDisPer(element.productName)
          .then((double? discount) async {
        double itemTotal = itemPrice * itemQuantity;
        double discountedTotal =
            itemTotal - (discount != null ? (itemTotal * discount / 100) : 0);

        setState(() {
          _totalPrice += discountedTotal;
        });
        await insertTotalPriceWithDP(_totalPrice, id);
      });
    }
  }

  Future<int> insertTotalPriceWithDP(double ttp, int orderId) async {
    final Database db = await _dbService.db;
    return await db.rawUpdate(
      'UPDATE CartOrder SET OrderAmount = ? WHERE OrderId = ?;',
      [ttp, orderId],
    );
  }



  @override
  Widget build(BuildContext context) {
        return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appbar,
      body: Container(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                      hintText: 'Phone Number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Customer\'s Phone Number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _phone = value;
                      });

                      // Call the search method to update the results
                      _search();
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),

                  // Display search results using a StreamBuilder and ListView.builder
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _resultsStream.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final results = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];

                          return ListTile(
                            selectedTileColor: Colors.orange,
                            textColor: Colors.orange,
                            horizontalTitleGap: 24,
                            leading: Text(
                                result['FirstName'], /*+ " " + result['LastName']*/
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            title: Text(result['Email'],
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            subtitle: Text(result['PhoneNo'],
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            trailing: Text(result['Address'],
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            onTap: () {
                              setState(() {
                                _phoneController.text = result['PhoneNo'];
                                _namec.text = result['FirstName'];
                                //_namec2.text = result['LastName'];
                                _emailc.text = result['Email'];
                                _locatc.text = result['Address'];
                              });

                              // Also clear the search results
                              _resultsStream.add([]);
                            },
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: _namec,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                      hintText: 'Customer  Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Customer\'s  Name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _name = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  // TextFormField(
                  //   keyboardType: TextInputType.name,
                  //   controller: _namec2,
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(
                  //         borderSide: BorderSide(color: Colors.orange)),
                  //     hintText: 'Customer Last Name',
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please Enter Customer Last Name';
                  //     }
                  //     return null;
                  //   },
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _name2 = value;
                  //     });
                  //   },
                  // ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailc,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                      hintText: 'Customer Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        _email = 'No Email Address';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _locatc,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey)),
                      hintText: 'Location',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        _location = "No Location";
                      }

                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _location = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Review your order below before checking out',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: const [
                          Text(
                            'Price BreakDown',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),


                      const SizedBox(height: 8),
                      //const Calculation(),
                      CalculationDB(),


                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          CartDBHelper cdb = CartDBHelper();
                          Calculation clc = Calculation();
                          CartProvider cart = CartProvider();
                          final Database db = await _dbService.db;
                          // Insert user details into database
                          await insertUserDetails();
                          await cdb.copyTableToOrder(db);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PayMents(cusId: _phone),
                              ));
                        }
                      },
                      child: const Text('Checkout'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        CartDBHelper cdb = CartDBHelper();
                        Calculation clc = Calculation();
                        final Database db = await _dbService.db;
                        if (_formKey.currentState!.validate()) {
                          await insertUserDetails();
                          CartProvider cart = CartProvider();
                          await cdb.copyTableToOrder(db);
                          PayMents pm = PayMents(cusId: '');
                          int? id;
                          try {
                            CartDBHelper cdb = CartDBHelper();
                            id = await cdb.markOrderAsPending(_phone);
                            print(id);
                          } catch (e) {
                            print(e);
                          }
                          if (id != null) {
                            _calculatePriceWithDiscountPercent(
                                id); //calculate and insert price to Cart order
                          }
                          //clear cart
                          cart.clearCart();
                          print('cart cleared');

                          final cartDbHelper = CartDBHelper();
                          await cartDbHelper.clearCart();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                'Order Placed Successfully. Check Running Orders Section',
                              ),
                            ),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LetsNavi()),
                          );
                        }
                      },
                      child: const Text('Place Order'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderSummary extends StatefulWidget {
  const OrderSummary({Key? key}) : super(key: key);

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Review your order below before checking out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: const [
            Text(
              'Price BreakDown',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Calculation(),

      ],
    );
  }
}
