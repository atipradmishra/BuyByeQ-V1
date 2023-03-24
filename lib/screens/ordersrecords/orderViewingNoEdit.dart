import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../common/appBar/apbar.dart';
import '../../common/drawer/custom_drawer.dart';
import '../../database/connections.dart';


class OrdersNoEdit extends StatefulWidget {
  const  OrdersNoEdit({Key? key}) : super(key: key);

  @override
  State<OrdersNoEdit> createState() => _OrdersNoEditState();
}

class _OrdersNoEditState extends State<OrdersNoEdit> {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
        drawer: const CustomDrawer(),
        body: Column(children: [
          const SizedBox(
            height: 15,
          ),
          const Center(
              child: Text(
                'View Running Orders',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              )),
          const SizedBox(
            height: 15,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
                child: Text(
                  'Note that this is only a view page. To edit running orders'
                      ' go to \'Running Orders\' Section.'
                      '\nSwipe right to Complete Payment. Swipe Left to edit order',
                  style: TextStyle(color:Colors.green,fontSize: 12, fontWeight: FontWeight.bold),
                )),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(DateFormat.yMd().format(DateTime.now()),style: const TextStyle(color:Colors.orange,fontSize: 15, fontWeight: FontWeight.bold)),

          const SizedBox(
            height: 5,
          ),Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getOrderDetails(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  final List<Map<String, dynamic>> results = snapshot.data!;
                  return ListView.builder(
                    itemCount: results.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> order = results[index];
                      return Cards(
                        order['OrderStatus'],
                        order['PhoneNo'],
                        order['OrderTime'],
                        order['TotalPrice'].toString(),
                        '${order['NumItems']} Items',
                        '${order['FirstName']} ${order['LastName']}',
                        context,
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Center(
                      child: Text('No Active Or Pending Orders'));
                }
              },
            ),
          )
        ]));
  }

  Future<List<Map<String, dynamic>>> getOrderDetails() async {
    final Database db = await _dbService.db;

    // Retrieve the order details
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    
    SELECT CartOrder.OrderID, CartOrder.OrderStatus, CustomerTable.PhoneNo, CustomerTable.FirstName, CustomerTable.LastName, SUM(OrderDetail.Price * OrderDetail.Quantity) AS TotalPrice, COUNT(OrderDetail.OrderID) AS NumItems, CartOrder.OrderTime
    FROM CartOrder
    INNER JOIN CustomerTable ON CartOrder.CustomerID = CustomerTable.CustomerID
    INNER JOIN OrderDetail ON CartOrder.OrderID = OrderDetail.OrderID
    WHERE CartOrder.OrderStatus = 'Pending'
    GROUP BY CartOrder.OrderID
    ORDER BY CartOrder.OrderTime DESC
    
  ''');
    return results;
  }
}

Widget Cards(String orderStatus, String phone, String time, String amount,
    String noItems, String cusName, BuildContext context) {
  return  Column(
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
                                  Text(
                                    orderStatus,
                                    style: const TextStyle(
                                        color: Colors.blue, fontSize: 14),
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
  );
}
