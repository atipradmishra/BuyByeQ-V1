import 'package:buybyeq/menu&cart/cartprovider/cartprovider.dart';
import 'package:buybyeq/menu&cart/database/cartdbhelper.dart';
import 'package:buybyeq/screens/paymentsdb.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../common/drawer/custom_drawer.dart';
import '../database/connections.dart';
import '../menu&cart/screens/cartuifromdb.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;

  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const CustomDrawer(),
        body: Column(children: [
          const SizedBox(
            height: 8,
          ),
          IconButton(onPressed: (){
            setState(() {

            });
          }, icon: Icon(Icons.refresh,color: Colors.green,)),
          const Center(
              child: Text(
            'Running Orders',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          )),
          const SizedBox(
            height: 15,
          ),
          Text(DateFormat.yMd().format(DateTime.now()),
              style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getOrderDetails(),
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Display a progress indicator while waiting for data to load
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  // Display an error message if there was an error fetching data
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  final List<Map<String, dynamic>> results = snapshot.data!;
                  if (results.isEmpty) {
                    // Display a message if there are no orders to display
                    return Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Text('Sorry.You have no pending orders at the moment',style: TextStyle(color: Colors.red,
                            fontSize:15,fontWeight: FontWeight.bold),),
                        Image(
                          height: MediaQuery.of(context).size.height*0.6,
                          width: MediaQuery.of(context).size.width,
                          image: AssetImage(
                              "assets/empty.jpg"),
                        ),


                      ],
                    ));
                  } else {
                    // Display the list of orders
                    return ListView.builder(
                      itemCount: results.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> order = results[index];
                        return Cards(
                          order['OrderId'].toString(),
                          order['CustomerID'].toString(),
                          order['OrderStatus'],
                          order['PhoneNo'],
                          order['OrderTime'],
                          order['TotalPrice'].toString(),
                          order['NumItems'] > 1
                              ? '${order['NumItems']} Items'
                              : '${order['NumItems']} Item',
                          '${order['FirstName']}',
                          context,
                          navigateToNextScreen,
                        );
                      },
                    );
                  }
                }
              },
            ),
          )

        ]));
  }

  Future<List<Map<String, dynamic>>> updatePayble() async {
    final Database db = await _dbService.db;

    // Retrieve the order details
    final List<Map<String, dynamic>> amount = await db.rawQuery('''
  UPDATE CartOrder 
  SET TotalPaybleAmount = (
    SELECT SUM(OrderDetail.Price * OrderDetail.Quantity) 
    FROM OrderDetail 
    WHERE OrderDetail.OrderID = CartOrder.OrderID
  ) 
  WHERE CartOrder.OrderID IN (
    SELECT OrderID 
    FROM OrderDetail)
  ''');
    return amount;
  }

  Future<List<Map<String, dynamic>>> getOrderDetails() async {
    final Database db = await _dbService.db;
    await updatePayble();
    // Retrieve the order details
    final List<Map<String, dynamic>> results = await db.rawQuery('''
  
  SELECT CartOrder.OrderID,CartOrder.CustomerID, CartOrder.OrderStatus, CustomerTable.PhoneNo, CustomerTable.FirstName, CustomerTable.LastName, SUM(OrderDetail.Price * OrderDetail.Quantity) AS TotalPrice, COUNT(OrderDetail.OrderID) AS NumItems, CartOrder.OrderTime
    FROM CartOrder
    INNER JOIN CustomerTable ON CartOrder.CustomerID = CustomerTable.CustomerID
    INNER JOIN OrderDetail ON CartOrder.OrderID = OrderDetail.OrderID
    WHERE CartOrder.OrderStatus = 'Pending'
    GROUP BY CartOrder.OrderID
    ORDER BY CartOrder.OrderTime DESC
''');

    return results;
  }



  void navigateToNextScreen(String orderId,String cusId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayMentsDB(orderId: orderId,cusId: cusId),
      ),
    );
  }

}
typedef SwipeCallback = void Function(String orderId,String cusId);


Widget Cards(String orderid,String cusId,String orderStatus, String phone,  String time,
    String amount, String noItems, String cusName, BuildContext context,SwipeCallback onSwipe) {
  return GestureDetector(
    onHorizontalDragEnd: (details) {
      if (details.primaryVelocity! > 0) {
        // Swiped to the right
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Navigation',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange)),
                content: const Text(
                    'Do you really want to proceed to check-out?',
                    style: TextStyle(fontSize: 16)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onSwipe(orderid,cusId);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  PayMentsDB(orderId:orderid,cusId: cusId,)));
                      print(orderid);

                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              );
            });
      } else if (details.primaryVelocity! < 0) {
        // Swiped to the left

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Navigation',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange)),
                content: const Text('Do you really want to edit order?',
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
                      final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
                      final Database db=await _dbService.db;
                      await cdb.copyTableToCart(db,int.parse(orderid));
                      print(orderid);
                      print(cusId);
                      Navigator.pop(context);
                      onSwipe(orderid,cusId);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CartScreenDB( id: orderid,)));
                      // }
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
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: Card(
            borderOnForeground: false,
            shadowColor: Colors.tealAccent,
            color: Colors.white70,
            elevation: 8.0,
            margin: const EdgeInsets.all(4.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.2,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration:
                                    const BoxDecoration(color: Colors.purple),
                                width: 4,
                                height: double.infinity,
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        orderStatus,
                                        style: const TextStyle(
                                            color: Colors.blue, fontSize: 14),
                                      ),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.2,),
                                      Text(
                                        "Order ID: $orderid",
                                        style: const TextStyle(
                                            fontSize: 14.0, color: Colors.purple),
                                      ),


                                    ],
                                  ),

                                  Text(
                                    phone,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                        fontSize: 14.0, color: Colors.teal),
                                  ),

                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(cusName,
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(r'₹ ' + amount,
                                    style: const TextStyle(
                                        color: Colors.orange, fontSize: 16)),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(noItems,
                                    style: const TextStyle(
                                        color: Colors.teal, fontSize: 16)),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
