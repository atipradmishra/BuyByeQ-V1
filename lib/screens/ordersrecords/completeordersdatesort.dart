import 'package:buybyeq/invoice/Screens/UI/prev.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../common/appBar/apbar.dart';
import '../../common/drawer/custom_drawer.dart';
import '../../database/connections.dart';

class OrdersComplete extends StatefulWidget {
  const OrdersComplete({Key? key}) : super(key: key);

  @override
  State<OrdersComplete> createState() => _OrdersCompleteState();
}
class _OrdersCompleteState extends State<OrdersComplete> {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const Center(
              child: Text(
                'View Complete Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _selectStartDate(context),
                  child: const Text('Choose Start Date'),
                ),
                ElevatedButton(
                  onPressed: () => _selectEndDate(context),
                  child: const Text('Choose End Date'),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [

                Row(
                  children: [
                    Text(
                        selectedStartDate != null
                            ? 'Start Date: ${DateFormat.yMd().format(
                            selectedStartDate!)}'
                            : 'No start date selected',
                        style: const TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                        selectedEndDate != null
                            ? 'End Date: ${DateFormat.yMd().format(
                            selectedEndDate!)}'
                            : 'No end date selected',
                        style: const TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8,),
                Text(
                    'Tap and hold a card to generate or share invoice',
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(),
          Expanded(
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
                        navigateToNextScreen
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
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        selectedStartDate = selectedDate;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        selectedEndDate = selectedDate;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getOrderDetails() async {
    try {
      final Database db = await _dbService.db;

      // Retrieve the order details
      String query = '''
      SELECT CartOrder.OrderID, CartOrder.OrderStatus, CartOrder.CustomerID,CartOrder.OrderDate, CustomerTable.PhoneNo,
      CustomerTable.FirstName, CustomerTable.LastName, 
      SUM(OrderDetail.Price * OrderDetail.Quantity) AS TotalPrice, 
      COUNT(OrderDetail.OrderID) AS NumItems, CartOrder.OrderTime
      FROM CartOrder
      INNER JOIN CustomerTable ON CartOrder.CustomerID = CustomerTable.CustomerID
      INNER JOIN OrderDetail ON CartOrder.OrderID = OrderDetail.OrderID
      WHERE CartOrder.OrderStatus = 'Complete'
    ''';

      if (selectedStartDate != null && selectedEndDate != null) {
        final start = DateFormat('MM-dd-yyyy').format(selectedStartDate!);
        final end = DateFormat('MM-dd-yyyy').format(selectedEndDate!);
        query += 'AND CartOrder.OrderDate BETWEEN "$start" AND "$end" ';
      }

      query += '''
      GROUP BY CartOrder.OrderID
      ORDER BY CartOrder.OrderTime DESC
    ''';

      final List<Map<String, dynamic>> results = await db.rawQuery(query);

      return results;
    } catch (e) {
      print('Error fetching order details: $e');
      return [];
    }
  }

  void navigateToNextScreen(String orderId,String cusId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrevDB(id: orderId,cusId: cusId, title: '',),
      ),
    );
  }

}

typedef TapCallback = void Function(String orderId,String cusId);
  Widget Cards(String orderid,String cusId,String orderStatus, String phone,  String time,
      String amount, String noItems, String cusName, BuildContext context,TapCallback dt,) {
  return GestureDetector(
    onLongPress: (){

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Complete Order Invoices',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.orange)),
              content: const Text(
                  'PRINT/SAVE/SHARE INVOICE?',
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
            dt(orderid,cusId);
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(
            builder: (context) =>  PrevDB(id:orderid,cusId: cusId,title: '',)));
            print(orderid);

                  },
                  child: const Text(
                    'Share/Print',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            );
          });
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
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    ),
  );
}
