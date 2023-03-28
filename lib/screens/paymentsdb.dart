import 'package:buybyeq/common/appBar/apbar.dart';
import 'package:buybyeq/menu&cart/database/cartdbhelper.dart';
import 'package:buybyeq/screens/loginpage.dart';
import 'package:buybyeq/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../common/drawer/custom_drawer.dart';
import '../customerdetails/customerdetinputpayment.dart';
import '../database/connections.dart';
import '../invoice/Screens/UI/previewdb.dart';
import '../invoice/Screens/UI/printpreview.dart';
import '../menu&cart/screens/cartui.dart';
import '../payment/upi/upi.dart';

class PayMentsDB extends StatefulWidget {
  PayMentsDB({Key? key, required this.orderId, required this.cusId})
      : super(key: key);
  String orderId;
  String cusId;
  @override
  State<PayMentsDB> createState() => _PayMentsDBState();
}

class _PayMentsDBState extends State<PayMentsDB> {
  Map<String, bool> paymentMethods = {
    'Debit/Credit Card': false,
    'Pay via UPI': false,
    'Cash': false
  };
  Set<String> selectedPaymentMethods =
  {}; //i used a set to ensure each item occurs only once

  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  Future<dynamic> getOrderAmount(int orderId) async {
    final Database db = await _dbService.db;

    // Query the "CartOrder" table to get the TotalPayble amount
    final int id = orderId;
    final List<Map<String, dynamic>> res = await db.query(
      "CartOrder",
      columns: ["TotalPaybleAmount", "CustomerId"],
      where: "OrderId = ?",
      whereArgs: [id],
      limit: 1,
    );

    if (res.isNotEmpty) {
      final dynamic totalPayable = res[0]['TotalPaybleAmount'];
      print(res);
      return totalPayable;
    } else {
      // Return a default value of 0 if the query doesn't return any results
      return 0;
    }
  }

  Future<String?> retrieveOrderAmount(int orderId) async {
    final Database db = await _dbService.db;
    final List<Map<String, dynamic>> cu = await db.query(
      "CartOrder",
      columns: ["OrderAmount"],
      where: "OrderID = ?",
      whereArgs: [orderId],
      orderBy: "OrderID DESC",
      limit: 1,
    );
    if (cu.isEmpty) {
      return null; // order not found
    }
    return cu[0]['OrderAmount'].toString();
  }

  Future<String?> retrieveTotalPayble(int orderId) async {
    final Database db = await _dbService.db;
    final List<Map<String, dynamic>> cu = await db.query(
      "CartOrder",
      columns: [
        "TotalPaybleAmount",
      ],
      where: "OrderID = ?",
      whereArgs: [orderId],
      orderBy: "OrderID DESC",
      limit: 1,
    );
    if (cu.isEmpty) {
      return null; // order not found
    }
    return cu[0]['TotalPaybleAmount'].toString();
  }

  @override
  Widget build(BuildContext context) {
    String orderid = widget.orderId;
    String cusid = widget.cusId;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: appbar,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              children: const [
                SizedBox(
                  width: 100,
                ),
                Text(
                  'Settle Orders',
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.pop(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen())); //const CartDetailsViewEdit()));
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                const Center(
                    child: Text(
                      'Checkout',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            Row(
              children: const [
                SizedBox(
                  width: 60,
                ),
                Text(
                    'Fill in the information below to \nplace your order\n\nSelect ONE or MORE\n',
                    style:
                    TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
              ],
            ),
            const Divider(color: Colors.blueGrey),
            const SizedBox(
              height: 20,
            ),
            //payments
            Center(
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white70),
                child: ListView(
                  children: paymentMethods.keys.map((String key) {
                    return CheckboxListTile(
                      title: Text(key),
                      value: paymentMethods[key],
                      onChanged: (bool? value) {
                        setState(() {
                          paymentMethods[key] = value!;
                          if (value) {
                            selectedPaymentMethods.add(key);
                          } else {
                            selectedPaymentMethods.remove(key);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            Column(
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
                Column(
                  children: [
                    Text(
                      'Price BreakDown',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    FutureBuilder<String?>(
                      future: retrieveTotalPayble(int.parse(orderid)),
                      builder: (BuildContext context,
                          AsyncSnapshot<String?> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator(); // or some other loading indicator
                        }
                        final ttpa = snapshot.data;
                        return ReusableWidget(
                          title: 'Sub Total',
                          value: '₹ $ttpa',
                        );
                      },
                    ),
                    // FutureBuilder<String?>(
                    //   future: retrieveOrderAmount(int.parse(orderid)),
                    //   builder: (BuildContext context,
                    //       AsyncSnapshot<String?> snapshot) {
                    //     if (!snapshot.hasData) {
                    //       return CircularProgressIndicator(); // or some other loading indicator
                    //     }
                    //     final oa = snapshot.data;
                    //     return ReusableWidget(
                    //       title: 'Sub Total(Discount Percentages)',
                    //       value: '₹ $oa',
                    //     );
                    //   },
                    // )
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: ElevatedButton(
                  onPressed: () async {
                    if (selectedPaymentMethods.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text(
                              'Select at least one payment method to proceed!!')));
                    }
                    //UPI only

                    if (selectedPaymentMethods.contains('Pay via UPI') &&
                        !selectedPaymentMethods.contains('Debit/Credit Card') &&
                        !selectedPaymentMethods.contains('Cash')) {
                      final List<String> imagePaths = await getAllImages();
                      final List<Widget> imageWidgets =
                      await Future.wait(imagePaths.map(loadImage));
                      try {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: imageWidgets.isNotEmpty
                                  ? Column(
                                children: [
                                  imageWidgets[0],
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await getOrderAmount(
                                          int.parse(orderid));
                                      Navigator.pop(context);
                                      await Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                          builder: (context) =>
                                              PreviewPageDB(
                                                  title:
                                                  "Print And Share",
                                                  id: orderid,
                                                  cusId: cusid)));
                                      CartDBHelper cdb = CartDBHelper();
                                      await cdb.updateCartOrderStatus(
                                          int.parse(orderid));
                                    },
                                    child: const Text('Confirm Payment.'),
                                  ),
                                ],
                              )
                                  : Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Center(
                                      child: Text(
                                        'Sorry.We found no UPI QR Code.\nAdd QR then retry checkout',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      )),
                                  Image(
                                    height: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.2,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.3,
                                    image: AssetImage("assets/err.png"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      Navigator.of(context)
                                          .pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Settings()));
                                    },
                                    child: const Text('Add QR Code'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        AlertDialog(
                          title: const Text('No QR Code Found!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                          content: const Text(
                              'Do you want to add QR to Proceed?',
                              style: TextStyle(fontSize: 16)),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const Settings()));
                              },
                              child: const Text(
                                'Yes',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        );
                      }
                    }
                    //cash only
                    if (selectedPaymentMethods.contains('Cash') &&
                        !selectedPaymentMethods.contains('Pay via UPI') &&
                        !selectedPaymentMethods.contains('Debit/Credit Card')) {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.5,
                              child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text('Cash Payment'),
                                      SizedBox(
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.3,
                                        child: Image.asset(
                                            fit: BoxFit.cover,
                                            'assets/money.png'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await getOrderAmount(
                                              int.parse(orderid));
                                          Navigator.pop(context);
                                          await Navigator.of(context)
                                              .pushReplacement(MaterialPageRoute(
                                              builder: (context) =>
                                                  PreviewPageDB(
                                                      title:
                                                      "Print And Share",
                                                      id: orderid,
                                                      cusId: cusid)));
                                          CartDBHelper cdb = CartDBHelper();
                                          await cdb.updateCartOrderStatus(
                                              int.parse(orderid));
                                        },
                                        child:
                                        const Text('Confirm Cash Payment'),
                                      ),
                                    ],
                                  )),
                            ),
                          ));
                    }

                    //card only
                    if (!selectedPaymentMethods.contains('Cash') &&
                        !selectedPaymentMethods.contains('Pay via UPI') &&
                        selectedPaymentMethods.contains('Debit/Credit Card')) {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.5,
                              child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Debit/Credit Card',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.01),
                                      SizedBox(
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.3,
                                        child: Image.asset(
                                            fit: BoxFit.cover,
                                            'assets/card.png'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await getOrderAmount(
                                              int.parse(orderid));
                                          Navigator.pop(context);
                                          await Navigator.of(context)
                                              .pushReplacement(MaterialPageRoute(
                                              builder: (context) =>
                                                  PreviewPageDB(
                                                      title:
                                                      "Print And Share",
                                                      id: orderid,
                                                      cusId: cusid)));
                                          CartDBHelper cdb = CartDBHelper();
                                          await cdb.updateCartOrderStatus(
                                              int.parse(orderid));
                                        },
                                        child:
                                        const Text('Confirm Card Payment'),
                                      ),
                                    ],
                                  )),
                            ),
                          ));
                    }

                    //strictly cash and card
                    if (selectedPaymentMethods.contains('Debit/Credit Card') &&
                        !selectedPaymentMethods.contains('Pay via UPI') &&
                        selectedPaymentMethods.contains('Cash')) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => AlertDialog(
                          content: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(
                                      'Debit/Credit Card',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                        height: MediaQuery.of(context).size.height *
                                            0.01),
                                    SizedBox(
                                      height:
                                      MediaQuery.of(context).size.height * 0.3,
                                      child: Image.asset(
                                          fit: BoxFit.cover, 'assets/card.png'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Confirm Card Payment'),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      );
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.5,
                              child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text('Cash Payment'),
                                      SizedBox(
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.3,
                                        child: Image.asset(
                                            fit: BoxFit.cover,
                                            'assets/money.png'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child:
                                        const Text('Confirm Cash Payment'),
                                      ),
                                    ],
                                  )),
                            ),
                          ));
                    }
                    ;
                    //cash and UPI
                    if (selectedPaymentMethods.contains('Cash') &&
                        selectedPaymentMethods.contains('Pay via UPI') &&
                        !selectedPaymentMethods.contains('Debit/Credit Card')) {
                      try {
                        final List<String> imagePaths = await getAllImages();
                        final List<Widget> imageWidgets =
                        await Future.wait(imagePaths.map(loadImage));
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: imageWidgets.isNotEmpty
                                  ? Column(
                                children: [
                                  imageWidgets[0],
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await getOrderAmount(
                                          int.parse(orderid));
                                      Navigator.pop(context);
                                      await Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                          builder: (context) =>
                                              PreviewPageDB(
                                                  title:
                                                  "Print And Share",
                                                  id: orderid,
                                                  cusId: cusid)));
                                      CartDBHelper cdb = CartDBHelper();
                                      await cdb.updateCartOrderStatus(
                                          int.parse(orderid));
                                    },
                                    child: const Text('Confirm Payment.'),
                                  ),
                                ],
                              )
                                  : Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Center(
                                      child: Text(
                                        'Sorry.We found no UPI QR Code.\nAdd QR then retry checkout',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      )),
                                  Image(
                                    height: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.2,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.3,
                                    image: AssetImage("assets/err.png"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      Navigator.of(context)
                                          .pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Settings()));
                                    },
                                    child: const Text('Add QR Code'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        AlertDialog(
                          title: const Text('No QR Code Found!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                          content: const Text(
                              'Do you want to add QR to Proceed?',
                              style: TextStyle(fontSize: 16)),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const Settings()));
                              },
                              child: const Text(
                                'Yes',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        );
                      }
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.5,
                              child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text('Cash Payment'),
                                      SizedBox(
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.3,
                                        child: Image.asset(
                                            fit: BoxFit.cover,
                                            'assets/money.png'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child:
                                        const Text('Confirm Cash Payment'),
                                      ),
                                    ],
                                  )),
                            ),
                          ));
                    }
                    //card and UPI
                    if (!selectedPaymentMethods.contains('Cash') &&
                        selectedPaymentMethods.contains('Pay via UPI') &&
                        selectedPaymentMethods.contains('Debit/Credit Card')) {
                      try {
                        final List<String> imagePaths = await getAllImages();
                        final List<Widget> imageWidgets =
                        await Future.wait(imagePaths.map(loadImage));
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: imageWidgets.isNotEmpty
                                  ? Column(
                                children: [
                                  imageWidgets[0],
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await getOrderAmount(
                                          int.parse(orderid));
                                      Navigator.pop(context);
                                      await Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                          builder: (context) =>
                                              PreviewPageDB(
                                                  title:
                                                  "Print And Share",
                                                  id: orderid,
                                                  cusId: cusid)));
                                      CartDBHelper cdb = CartDBHelper();
                                      await cdb.updateCartOrderStatus(
                                          int.parse(orderid));
                                    },
                                    child: const Text('Confirm Payment.'),
                                  ),
                                ],
                              )
                                  : Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Center(
                                      child: Text(
                                        'Sorry.We found no UPI QR Code.\nAdd QR then retry checkout',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      )),
                                  Image(
                                    height: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.2,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.3,
                                    image: AssetImage("assets/err.png"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      Navigator.of(context)
                                          .pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Settings()));
                                    },
                                    child: const Text('Add QR Code'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        AlertDialog(
                          title: const Text('No QR Code Found!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                          content: const Text(
                              'Do you want to add QR to Proceed?',
                              style: TextStyle(fontSize: 16)),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const Settings()));
                              },
                              child: const Text(
                                'Yes',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        );
                      }

                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.5,
                              child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Debit/Credit Card',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.01),
                                      SizedBox(
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.3,
                                        child: Image.asset(
                                            fit: BoxFit.cover,
                                            'assets/card.png'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child:
                                        const Text('Confirm Card Payment'),
                                      ),
                                    ],
                                  )),
                            ),
                          ));
                    }
                  },
                  child: Row(
                    children: const [
                      Text('Proceed'),
                      SizedBox(width: 50),
                      Icon(
                        Icons.shopping_cart_checkout,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}