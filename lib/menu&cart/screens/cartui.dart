import 'package:buybyeq/common/prodcateg/categs.dart';
import 'package:buybyeq/menu&cart/database/menudbhelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/appBar/apbar.dart';
import '../../common/drawer/custom_drawer.dart';
import '../../customerdetails/customerdetinputpayment.dart';
import '../cartprovider/cartprovider.dart';
import '../database/cartdbhelper.dart';
import '../models/cartmodel.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  CartDBHelper? dbHelper = CartDBHelper();
  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().getData();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: appbar,
        drawer: const CustomDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 15,
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: const Icon(Icons.menu, color: Colors.orangeAccent),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Categories(
              onCategorySelected: (String) {},
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Cart Details',
              style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<CartProvider>(
                builder: (BuildContext context, provider, widget) {
                  if (provider.cart.isEmpty) {
                    provider.getData();
                    return const Center(
                        child: Text(
                      'Your Cart is Empty',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ));
                  } else {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.cart.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            child: Card(
                              color: Colors.white,
                              elevation: 5.0,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.30,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 5.0,
                                          ),
                                          RichText(
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            text: TextSpan(
                                                text: 'Name: ',
                                                style: TextStyle(
                                                    color: Colors
                                                        .blueGrey.shade800,
                                                    fontSize: 11.0),
                                                children: [
                                                  TextSpan(
                                                      text:
                                                          '${provider.cart[index].productName}\n',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ]),
                                          ),
                                          RichText(
                                            maxLines: 1,
                                            text: TextSpan(
                                                text: 'Category: ',
                                                style: TextStyle(
                                                    color: Colors
                                                        .blueGrey.shade800,
                                                    fontSize: 11.0),
                                                children: [
                                                  TextSpan(
                                                      text:
                                                          '${provider.cart[index].unitTag}\n',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ]),
                                          ),
                                          RichText(
                                            maxLines: 1,
                                            text: TextSpan(
                                                text: 'Price: ' r"₹ ",
                                                style: const TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 12.0),
                                                children: [
                                                  TextSpan(
                                                      text:
                                                          '${provider.cart[index].productPrice}\n',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ValueListenableBuilder<int>(
                                        valueListenable:
                                            provider.cart[index].quantity!,
                                        builder: (context, val, child) {
                                          return PlusMinusButtons(
                                            addQuantity: () async {
                                              DatabaseHelper db =
                                                  DatabaseHelper();
                                              cart.addQuantity(provider
                                                  .cart[index].productId!);
                                              dbHelper!
                                                  .updateQuantity(Cart(
                                                      productId: index,
                                                      menuId: await db
                                                          .getMenuItemId(provider
                                                              .cart[index]
                                                              .productName!),
                                                      productName: provider
                                                          .cart[index]
                                                          .productName,
                                                      productPrice: provider
                                                          .cart[index]
                                                          .productPrice,
                                                      quantity: ValueNotifier(
                                                          provider.cart[index]
                                                              .quantity!.value),
                                                      unitTag: provider
                                                          .cart[index].unitTag,
                                                      image: provider
                                                          .cart[index].image))
                                                  .then((value) {
                                                setState(() {
                                                  cart.addTotalPrice(
                                                      double.parse(provider
                                                          .cart[index]
                                                          .productPrice
                                                          .toString()));
                                                });
                                              });
                                            },
                                            deleteQuantity: () {
                                              cart.deleteQuantity(provider
                                                  .cart[index].productId!);
                                              cart.removeTotalPrice(
                                                  double.parse(provider
                                                      .cart[index].productPrice
                                                      .toString()));
                                            },
                                            text: val.toString(),
                                          );
                                        }),
                                    IconButton(
                                        onPressed: () {
                                          showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          (provider.cart[index].productName!).toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.orange)),
                                                      content: Text(
                                                          'Do you really want to remove ${provider.cart[index].productName!} from cart?',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      20)),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),

                                                        TextButton(
                                                          onPressed: () async {
                                                            dbHelper!.deleteCartItem(
                                                                provider
                                                                    .cart[index]
                                                                    .productId!);
                                                            provider.removeItem(
                                                                provider
                                                                    .cart[index]
                                                                    .productId!);
                                                            provider
                                                                .removeCounter();
                                                            Navigator.pop(
                                                                context);
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Removed from cart...',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .lightGreenAccent,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                              ),
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Remove',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .redAccent),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  })
                                              .then((value) =>
                                                  const CartScreen());
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red.shade800,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  }
                },
              ),
            ),
           // const Calculation(),
        Consumer<CartProvider>(
          builder: (BuildContext context, value, Widget? child) {
            final ValueNotifier<double> totalPrice2 = ValueNotifier(0);

            for (var element in value.cart) {
              double itemPrice = element.productPrice!;
              int itemQuantity = element.quantity!.value;
              Future<double?> discountFuture =
              Provider.of<CartProvider>(context, listen: false)
                  .getItemDisPer(element.productName);
              discountFuture.then((double? discount) {
                double itemTotal = itemPrice * itemQuantity;
                double discountedTotal = itemTotal -
                    (discount != null ? (itemTotal * discount / 100) : 0);
                totalPrice2.value += discountedTotal;
              });
            }

            return ValueListenableBuilder<double>(
              valueListenable: totalPrice2,
              builder: (context, val, child) {
                return Column(
                  children: [
                    ReusableWidget(
                        title: 'Sub Total:',
                        value: r'₹ ' + val.toStringAsFixed(2)),

                  ],
                );
              },
            );
          },
        ),
            Text('    '),
            Text('    '),
          ],
        ),
        bottomNavigationBar: Consumer<CartProvider>(
            builder: (BuildContext context, provider, widget) {
          return InkWell(
            onTap: () {
              if (provider.cart.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No Items in cart.',
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Saving items in cart...',
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.lightGreenAccent,
                    duration: Duration(seconds: 3),
                  ),
                );
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyForm()));
              }
            },
            child: Container(
              color: Colors.green,
              alignment: Alignment.center,
              height: 40.0,
              child: const Text(
                'Initiate Order & Customer Details',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }));
  }
}

class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final String text;
  const PlusMinusButtons(
      {Key? key,
      required this.addQuantity,
      required this.deleteQuantity,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(
              onPressed: deleteQuantity,
              icon: const Icon(Icons.remove),
              color: Colors.orange),
          Text(text,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          IconButton(
              onPressed: addQuantity,
              icon: const Icon(Icons.add),
              color: Colors.orange),
        ],
      ),
    );
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;
  const ReusableWidget(
      {super.key,
      required this.title,
      required this.value,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class Calculation extends StatelessWidget {
  const Calculation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _discountController = TextEditingController();
    final ValueNotifier<double> totalPrice2 = ValueNotifier(0);

    return Consumer<CartProvider>(
      builder: (BuildContext context, value, Widget? child) {
        totalPrice2.value = 0;

        for (var element in value.cart) {
          double itemPrice = element.productPrice!;
          int itemQuantity = element.quantity!.value;
          Future<double?> discountFuture =
          Provider.of<CartProvider>(context, listen: false)
              .getItemDisPer(element.productName);
          discountFuture.then((double? discount) {
            double itemTotal = itemPrice * itemQuantity;
            double discountedTotal = itemTotal -
                (discount != null ? (itemTotal * discount / 100) : 0);
            totalPrice2.value += discountedTotal;
          });
        }

        return ValueListenableBuilder<double>(
          valueListenable: totalPrice2,
          builder: (context, val, child) {
            double discountAmount = 0.0;
            if (_discountController.text.isNotEmpty &&
                double.tryParse(_discountController.text) != null) {
              discountAmount = double.parse(_discountController.text);
            }
            double grandTotal = val - discountAmount;

            return Column(
              children: [

                ReusableWidget(
                    title: 'Sub Total:', value: r'₹ ' + val.toStringAsFixed(2)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      children: [
                        Text('GrandTotal:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Spacer(),
                        Text('₹ ' + grandTotal.toStringAsFixed(2),
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))
                      ]),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class CalculationDB extends StatelessWidget {
  CalculationDB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _discountController = TextEditingController();
    final ValueNotifier<double> totalPrice2 = ValueNotifier(0);

    return Consumer<CartProvider>(
      builder: (BuildContext context, value, Widget? child) {
        final ValueNotifier<double> totalPrice2 = ValueNotifier(0);
        totalPrice2.value = 0;

        for (var element in value.cart) {
          double itemPrice = element.productPrice!;
          int itemQuantity = element.quantity!.value;
          Future<double?> discountFuture =
          Provider.of<CartProvider>(context, listen: false)
              .getItemDisPer(element.productName);
          discountFuture.then((double? discount) {
            double itemTotal = itemPrice * itemQuantity;
            double discountedTotal = itemTotal -
                (discount != null ? (itemTotal * discount / 100) : 0);
            totalPrice2.value += discountedTotal;
          });
        }

        return ValueListenableBuilder<double>(
          valueListenable: totalPrice2,
          builder: (context, val, child) {
            double discountAmount = 0.0;
            if (_discountController.text.isNotEmpty &&
                double.tryParse(_discountController.text) != null) {
              discountAmount = double.parse(_discountController.text);
            }
            double grandTotal = val - discountAmount;

            return Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _discountController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange)),
                    label: Text('Discount'),
                    hintText: 'To offer discount, enter amount',
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && double.tryParse(value) != null) {
                      double newDiscountAmount = double.parse(value);
                      totalPrice2.value = totalPrice2.value +
                          discountAmount -
                          newDiscountAmount;
                      discountAmount = newDiscountAmount;
                    }
                  },
                ),
                ReusableWidget(
                    title: 'Sub Total:', value: r'₹ ' + val.toStringAsFixed(2)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      children: [
                        Text('GrandTotal:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Spacer(),
                        Text('₹ ' + grandTotal.toStringAsFixed(2),
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))
                      ]),
                ),
              ],
            );
          },
        );
      },
    );
  }
}