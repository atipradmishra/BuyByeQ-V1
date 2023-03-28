import 'package:buybyeq/common/prodcateg/categs.dart';
import 'package:buybyeq/menu&cart/database/menudbhelper.dart';
import 'package:buybyeq/menu&cart/screens/menufoodfromdb.dart';
import 'package:buybyeq/screens/orders.dart';
import 'package:buybyeq/screens/pagesnav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../common/appBar/appbarnocart.dart';
import '../../common/drawer/custom_drawer.dart';
import '../../customerdetails/customerdetinputpayment.dart';
import '../../database/connections.dart';
import '../cartprovider/cartprovider.dart';
import '../database/cartdbhelper.dart';
import '../models/cartmodel.dart';
import 'cartui.dart';

class CartScreenDB extends StatefulWidget {
  CartScreenDB( {
    Key? key,required this.id,
  }) : super(key: key);
  String id;
  @override
  State<CartScreenDB> createState() => _CartScreenDBState();
}

class _CartScreenDBState extends State<CartScreenDB> {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  CartDBHelper? dbHelper = CartDBHelper();
  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().getData();
  }

  @override
  Widget build(BuildContext context) {
    String orderid=widget.id;
    final cart = Provider.of<CartProvider>(context);

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: appbar2,
          drawer: const CustomDrawer(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
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
                height: 10,
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Editing Order Details ',
                style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              const SizedBox(height: 10),
              Text(
                'Order No : $orderid',
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),

              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShoppingMenuDB(id: orderid,)));
                  },
                  child: const Text('Add Food From Menu')),
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
                                      // Image(
                                      //   height: 10,
                                      //   width: 10,
                                      //   image: AssetImage(
                                      //       provider.cart[index].image!),
                                      // ),
                                      // SizedBox(
                                      //   width: 10,
                                      // ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                                                FontWeight
                                                                    .bold)),
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
                                                            '${provider.cart[index].unitTag!}\n',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
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
                                                                FontWeight
                                                                    .bold)),
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
                                                            provider
                                                                .cart[index]
                                                                .quantity!
                                                                .value),
                                                        unitTag: provider
                                                            .cart[index]
                                                            .unitTag,
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
                                                        .cart[index]
                                                        .productPrice
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
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            (provider
                                                                    .cart[index]
                                                                    .productName!)
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .orange)),
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
                                                            onPressed:
                                                                () async {
                                                              dbHelper!.deleteCartItem(
                                                                  provider
                                                                      .cart[
                                                                          index]
                                                                      .productId!);
                                                              provider.removeItem(
                                                                  provider
                                                                      .cart[
                                                                          index]
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
                                                    CartScreenDB(id: orderid,));
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
              const Calculation(),
            ],
          ),
          bottomNavigationBar: Consumer<CartProvider>(
              builder: (BuildContext context, provider, widget) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Ignore Changes',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                              content: const Text(
                                  'Do you really want to cancel changes?',
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
                                    final cartDbHelper = CartDBHelper();
                                    CartDBHelper cdb=CartDBHelper();
                                    await cartDbHelper.clearCart();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Center(
                                          child: Text(
                                            'Undoing order changes...',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        backgroundColor:
                                            Colors.lightGreenAccent,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LetsNavi()));
                                  },
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    child: const Text(
                      'Ignore Changes',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {

                      if (provider.cart.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable To Save. No Items in cart.',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } else {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Save Changes',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                                content: const Text(
                                    'Do you really want to save changes?',
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
                                      CartDBHelper cdb=CartDBHelper();
                                      final Database db=await _dbService.db;
                                      await cdb.UpdateTableToOrder(db,);
                                      final cartDbHelper = CartDBHelper();
                                      await cartDbHelper.clearCart();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Center(
                                            child: Text(
                                              'Saving order changes...',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          backgroundColor:
                                              Colors.lightGreenAccent,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LetsNavi()));
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ));
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;
  final Function toDB;
  const ReusableWidget(
      {super.key,
      required this.title,
      required this.value,
      required this.toDB});

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
