import 'package:buybyeq/common/appBar/apbar.dart';
import 'package:buybyeq/screens/loginpage.dart';
import 'package:buybyeq/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../common/drawer/custom_drawer.dart';
import '../customerdetails/customerdetinputpayment.dart';
import '../database/connections.dart';
import '../invoice/Screens/UI/printpreview.dart';
import '../menu&cart/cartprovider/cartprovider.dart';
import '../menu&cart/database/cartdbhelper.dart';
import '../payment/upi/upi.dart';

class PayMents extends StatefulWidget {
  PayMents({Key? key, required this.cusId}) : super(key: key);
  String cusId; //phone
  @override
  State<PayMents> createState() => _PayMentsState();
}

class _PayMentsState extends State<PayMents> {
  Map<String, bool> paymentMethods = {
    'Debit/Credit Card': false,
    'Pay via UPI': false,
    'Cash': false
  };
  Set<String> selectedPaymentMethods =
      {}; //i used a set to ensure each item occurs only once

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Initiate Pay Using :'),
          content: Text(selectedPaymentMethods.join(' and ')),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  double _totalPrice = 0;
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  Future<int?> getCustomerIdByPhoneNumber(String phoneNumber) async {
    final Database db = await _dbService.db;
    final List<Map<String, dynamic>> customer = await db.query(
      "CustomerTable",
      columns: ["CustomerID"],
      where: "PhoneNo = ?",
      whereArgs: [phoneNumber],
      limit: 1,
    );
    if (customer.isEmpty) {
      return null; // customer not found
    }
    return customer[0]['CustomerID'];
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

            Container(padding: EdgeInsets.all(10), child: OrderSummary()),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: ElevatedButton(
                  onPressed: () async {
                    print(cusid);
                    final int? customerId =
                        await getCustomerIdByPhoneNumber(cusid);
                    if (customerId == null) {
                      print('nullllllllll'); // handle customer not found
                    } else {
                      cusid = customerId.toString();
                      print("Customer: $cusid");
                    }
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

                      try {
                        final List<String> imagePaths = await getAllImages();
                        final List<Widget> imageWidgets =
                            await Future.wait(imagePaths.map(loadImage));
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height:MediaQuery.of(context).size.height *
                                  0.5,
                              child: imageWidgets.isNotEmpty
                                  ? Column(
                                      children: [
                                        imageWidgets[0],
                                        const Spacer(),
                                        ElevatedButton(
                                          onPressed: () async {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                duration: Duration(seconds: 2),
                                                backgroundColor: Colors.green,
                                                content: Text(
                                                  'Order Completed Successfully.Check Complete Orders section',
                                                ),
                                              ),
                                            );
                                            int? id;
                                            try {
                                              CartDBHelper cdb = CartDBHelper();
                                              id = await cdb
                                                  .markOrderAsComplete(cusid);
                                            } catch (e) {
                                              print(e);
                                            }
                                            if (id != null) {
                                              _calculatePriceWithDiscountPercent(
                                                  id); //calculate and insert price to Cart order
                                            }
                                            //clear cart
                                            CartProvider cart = CartProvider();
                                            cart.clearCart();
                                            print('cart cleared');

                                            final cartDbHelper = CartDBHelper();
                                            await cartDbHelper.clearCart();

                                            Navigator.pop(context);
                                            await Navigator.of(context)
                                                .pushReplacement(MaterialPageRoute(
                                                    builder: (context) =>
                                                        PreviewPage(
                                                            title:
                                                                "Print via Bluetooth ",
                                                            id: '',
                                                            cusId: cusid)));
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
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 2),
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                'Order Completed Successfully.Check Complete Orders section',
                                              ),
                                            ),
                                          );
                                          int? id;
                                          try {
                                            CartDBHelper cdb = CartDBHelper();
                                            id = await cdb
                                                .markOrderAsComplete(cusid);
                                          } catch (e) {
                                            print(e);
                                          }
                                          if (id != null) {
                                            _calculatePriceWithDiscountPercent(
                                                id); //calculate and insert price to Cart order
                                          }
                                          //clear cart
                                          CartProvider cart = CartProvider();
                                          cart.clearCart();
                                          print('cart cleared');

                                          final cartDbHelper = CartDBHelper();
                                          await cartDbHelper.clearCart();

                                          Navigator.pop(context);
                                          await Navigator.of(context)
                                              .pushReplacement(MaterialPageRoute(
                                              builder: (context) =>
                                                  PreviewPage(
                                                      title:
                                                      "Print via Bluetooth ",
                                                      id: '',
                                                      cusId: cusid)));
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
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 2),
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                'Order Completed Successfully.Check Complete Orders section',
                                              ),
                                            ),
                                          );
                                          int? id;
                                          try {
                                            CartDBHelper cdb = CartDBHelper();
                                            id = await cdb
                                                .markOrderAsComplete(cusid);
                                          } catch (e) {
                                            print(e);
                                          }
                                          if (id != null) {
                                            _calculatePriceWithDiscountPercent(
                                                id); //calculate and insert price to Cart order
                                          }
                                          //clear cart
                                          CartProvider cart = CartProvider();
                                          cart.clearCart();
                                          print('cart cleared');

                                          final cartDbHelper = CartDBHelper();
                                          await cartDbHelper.clearCart();

                                          Navigator.pop(context);
                                          await Navigator.of(context)
                                              .pushReplacement(MaterialPageRoute(
                                              builder: (context) =>
                                                  PreviewPage(
                                                      title:
                                                      "Print via Bluetooth ",
                                                      id: '',
                                                      cusId: cusid)));
                                        },
                                        child:
                                            const Text('Confirm Card Payment'),
                                      ),
                                    ],
                                  )),
                                ),
                              ));
                    }
                    ;
                    //strictly cash and card
                    if (selectedPaymentMethods.contains('Debit/Credit Card') &&
                        !selectedPaymentMethods.contains('Pay via UPI')&&selectedPaymentMethods.contains('Cash')) {

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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
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
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SizedBox(
                                height:
                                MediaQuery.of(context).size.height *
                                    0.5,
                                child: imageWidgets.isNotEmpty
                                    ? Column(
                                        children: [
                                          imageWidgets[0],
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () async {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  duration:
                                                      Duration(seconds: 2),
                                                  backgroundColor: Colors.green,
                                                  content: Text(
                                                    'Order Completed Successfully.Check Complete Orders section',
                                                  ),
                                                ),
                                              );
                                              int? id;
                                              try {
                                                CartDBHelper cdb =
                                                    CartDBHelper();
                                                id = await cdb
                                                    .markOrderAsComplete(cusid);
                                              } catch (e) {
                                                print(e);
                                              }
                                              if (id != null) {
                                                _calculatePriceWithDiscountPercent(
                                                    id); //calculate and insert price to Cart order
                                              }
                                              //clear cart
                                              CartProvider cart =
                                                  CartProvider();
                                              cart.clearCart();
                                              print('cart cleared');

                                              final cartDbHelper =
                                                  CartDBHelper();
                                              await cartDbHelper.clearCart();

                                              Navigator.pop(context);
                                              await Navigator.of(context)
                                                  .pushReplacement(MaterialPageRoute(
                                                      builder: (context) =>
                                                          PreviewPage(
                                                              title:
                                                                  "Print via Bluetooth ",
                                                              id: '',
                                                              cusId: cusid)));
                                            },
                                            child:
                                                const Text('Confirm Payment.'),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.5,
                                    child: SingleChildScrollView(
                                        child: Column(
                                      children: [
                                        Text('Cash Payment'),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          child: Image.asset(
                                              fit: BoxFit.cover,
                                              'assets/money.png'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                              'Confirm Cash Payment'),
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
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SizedBox(
                                height:MediaQuery.of(context).size.height *
                                    0.5,
                                child: imageWidgets.isNotEmpty
                                    ? Column(
                                        children: [
                                          imageWidgets[0],
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () async {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  duration:
                                                      Duration(seconds: 2),
                                                  backgroundColor: Colors.green,
                                                  content: Text(
                                                    'Order Completed Successfully.Check Complete Orders section',
                                                  ),
                                                ),
                                              );
                                              int? id;
                                              try {
                                                CartDBHelper cdb =
                                                    CartDBHelper();
                                                id = await cdb
                                                    .markOrderAsComplete(cusid);
                                              } catch (e) {
                                                print(e);
                                              }
                                              if (id != null) {
                                                _calculatePriceWithDiscountPercent(
                                                    id); //calculate and insert price to Cart order
                                              }
                                              //clear cart
                                              CartProvider cart =
                                                  CartProvider();
                                              cart.clearCart();
                                              print('cart cleared');

                                              final cartDbHelper =
                                                  CartDBHelper();
                                              await cartDbHelper.clearCart();

                                              Navigator.pop(context);
                                              await Navigator.of(context)
                                                  .pushReplacement(MaterialPageRoute(
                                                      builder: (context) =>
                                                          PreviewPage(
                                                              title:
                                                                  "Print via Bluetooth ",
                                                              id: '',
                                                              cusId: cusid)));
                                            },
                                            child:
                                                const Text('Confirm Payment.'),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.5,
                                    child: SingleChildScrollView(
                                        child:Column(
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
