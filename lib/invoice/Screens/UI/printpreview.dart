import 'package:pdf/widgets.dart' as pw;
import 'package:buybyeq/common/appBar/apbar.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart ';
import 'package:printing/printing.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../bluetoothprinting/bt_print.dart';
import '../../../common/drawer/custom_drawer.dart';
import '../../../database/connections.dart';
import '../Widgets/invoice_table.dart';
import '../Widgets/printable_data.dart';

class PreviewPage extends StatefulWidget {
  PreviewPage(
      {Key? key, required this.title, required this.id, required this.cusId})
      : super(key: key);
  final String title;
  final String id;
  final String cusId;
  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  @override
  Widget build(BuildContext context) {
    String orderid = widget.id;
    String cusid = widget.cusId;
    Future<List<Map<String, dynamic>>> getCustomerInfo(int cusid) async {
      final Database db = await _dbService.db;
      final List<Map<String, dynamic>> customer = await db.query(
        "CustomerTable",
        columns: ["FirstName", "LastName"],
        where: "CustomerID = ?",
        whereArgs: [cusid],
        limit: 1,
      );
      return customer;
    }

    Future<int?> getLatestOrderIdByCustomerId(int customerId) async {
      final Database db = await _dbService.db;
      final List<Map<String, dynamic>> order = await db.query(
        "CartOrder",
        columns: ["OrderId"],
        where: "CustomerID = ?",
        whereArgs: [customerId],
        orderBy: "OrderId DESC",
        limit: 1,
      );
      if (order.isEmpty) {
        return null; // order not found
      }
      return order[0]['OrderId'];
    }
    Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
      final Database db = await _dbService.db;
      final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT OrderDetail.MenuItemId, MenuItem.MenuItemName as ItemName, OrderDetail.Price, OrderDetail.Quantity,MenuItem.DiscountPercentage as Discount
    FROM OrderDetail
    INNER JOIN MenuItem ON OrderDetail.MenuItemId = MenuItem.MenuItemId
    WHERE OrderDetail.OrderId = ?
  ''', [orderId]);

      return results;
    }
    Future<String?> getPhone(int customerId) async {
      final Database db = await _dbService.db;
      final List<Map<String, dynamic>> cu = await db.query(
        "CustomerTable",
        columns: ["PhoneNo"],
        where: "CustomerID = ?",
        whereArgs: [customerId],
        orderBy: "PhoneNo DESC",
        limit: 1,
      );
      if (cu.isEmpty) {
        return null; // order not found
      }
      return cu[0]['PhoneNo'];
    }

    Future<double?> getOAmt(String orId) async {
      final Database db = await _dbService.db;
      final List<Map<String, dynamic>> cu = await db.query(
        "CartOrder",
        columns: ["OrderAmount"],
        where: "OrderId = ?",
        whereArgs: [orId],
        orderBy: "OrderId DESC",
        limit: 1,
      );
      if (cu.isEmpty) {
        return null; // order not found
      }
      print(cu[0]['OrderAmount']);
      return cu[0]['OrderAmount'] as double?;
    }







    void _sendMessage(int cusid) async {
      final double? oamt=await getOAmt(orderid);
     var phoneNumber =await getPhone(cusid);
      final customerInfo = await getCustomerInfo(
          cusid);
      final orderId = await getLatestOrderIdByCustomerId(
          cusid);
      List<Map<String, dynamic>> orderItems = await getOrderItems(orderId!);
      String bought = '';
      int num = 0;
      double tot = 0.0;
      double per = 0.0;
      for (Map<String, dynamic> row in orderItems) {
        var item = ("${row['ItemName']}  ${row['Quantity']}   ₹ ${row['Price']}      ₹ ${int
            .parse(row['Quantity']) * double.parse(row['Price'])}");
        bought += '$item\n';
        num += int.parse(row['Quantity']);
        tot += int.parse(row['Quantity']) * double.parse(row['Price']);
        per += int.parse(row['Quantity']) * (double.parse(row['Price']) * (100 - row['Discount'])/100);
      }

      final message = '🎉--Thanks For Visiting Bites--🎉\n\n'
          '~~~~Bites~~~~\n\n'
          'Gopabandhu Chaka, Unit -- 8 Bhubasenswar\n'
          'Contact No: +91 7064312417\n'
          // 'GSTIN No: \n'
          '--------------------------------\n'
          'CUSTOMER INFORMATION:\n\n'
          'Name: ${customerInfo[0]["FirstName"]}\n' /*${customerInfo[0]["LastName"]}*/
          'Invoice Date: ${DateFormat('MM/dd/yyyy').format(DateTime.now())}\n'
          '\n\n'
          '--------------------------------\n'
          'ORDER DETAILS:\n\n'
          'Order ID: ${orderId ?? "NO ID"}\n\n'
          'ITEM---QTY---RATE---TOTAL\n\n'
          '$bought\n'
          '--------------------------------\n\n'
          'ORDER SUMMARY:\n\n'
          'Total Quantity: $num\n'
          'Sub-total: ₹ ${tot.toStringAsFixed(2)}\n'
          'Discount: ₹ ${(tot-per).toStringAsFixed(2)}\n'
          // 'CGST @ 2.5%\n'
          // 'SGST @ 2.5%\n'
          'Grand Total: ₹ ${per.toStringAsFixed(2)} \n\n'
          '--------------------------------\n\n'
          'Thank You\n'
          'Powered by BuyByeQ';


      var url = "whatsapp://send?phone=+91$phoneNumber&text=${Uri.encodeFull(message)}";

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    }


    void _sendText(int cusid) async {
      var phoneNumber =await getPhone(cusid);
      final customerInfo = await getCustomerInfo(cusid);
      final orderId = await getLatestOrderIdByCustomerId(cusid);

      List<Map<String, dynamic>> orderItems = await getOrderItems(orderId!);
      String bought = '';
      double tot = 0.0;
      double per = 0.0;
      int num = 0;
      for (Map<String, dynamic> row in orderItems) {
        var item = ("${row['ItemName']}  ${row['Quantity']}   ₹ ${row['Price']}   ₹ ${int
            .parse(row['Quantity']) * double.parse(row['Price'])}");
        bought += '$item\n';
        num += int.parse(row['Quantity']);
        tot += int.parse(row['Quantity']) * double.parse(row['Price']);
        per += int.parse(row['Quantity']) * (double.parse(row['Price']) * (100 - row['Discount'])/100);
      }

      final message = '🎉--Thanks For Visiting Bites--🎉\n\n'
          '~~~~Bites~~~~\n\n'
          'Gopabandhu Chaka, Unit -- 8 Bhubasenswar\n'
          'Contact No: +91 7064312417\n'
          // 'GSTIN No: \n'
          '--------------------------------\n'
          'CUSTOMER INFORMATION:\n\n'
          'Name: ${customerInfo[0]["FirstName"]}\n' /*${customerInfo[0]["LastName"]}*/
          'Invoice Date: ${DateFormat('MM/dd/yyyy').format(DateTime.now())}\n'
          '\n\n'
          '--------------------------------\n'
          'ORDER DETAILS:\n\n'
          'Order ID: ${orderId ?? "NO ID"}\n\n'
          'ITEM---QTY---RATE---TOTAL\n\n'
          '$bought\n\n'
          '--------------------------------\n\n'
          'ORDER SUMMARY:\n\n'
          'Total Quantity: $num\n'
          'Sub-total: ₹ ${tot.toStringAsFixed(2)}\n'
          'Discount: ₹ ${(tot-per).toStringAsFixed(2)}\n'
          // 'CGST @ 2.5%\n'
          // 'SGST @ 2.5%\n'
          'Grand Total: ₹ ${per.toStringAsFixed(2)}\n\n'
          '--------------------------------\n\n'
          'Thank You\n'
          'Powered by BuyByeQ';

      String url = 'sms:+91$phoneNumber?body=${Uri.encodeQueryComponent(message)}';
      await launchUrl(Uri.parse(url));

      // if (await canLaunchUrl(Uri.parse(url))) {
      //   await launchUrl(Uri.parse(url));
      // } else {
      //   throw 'Could not launch $url';
      // }
    }

    Future<void> printDoc() async {
      final doc = pw.Document();
      doc.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return buildPrintableData();
          }));
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save());
    }

    return Scaffold(
      appBar: appbar,
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 15,
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
          print(cusid);
        },
        child: const Icon(Icons.menu, color: Colors.orangeAccent),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.00),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 5, bottom: 20, left: 40, right: 40),
                  child: Column(
                    children: const [
                      Text("Bites",
                          style: TextStyle(
                              fontSize: 28.00, fontWeight: FontWeight.bold)),
                      Text("Gopabandhu Chaka, Unit -- 8 Bhubasenswar",
                          style: TextStyle(
                              fontSize: 14.00, fontWeight: FontWeight.w400)),
                      Text("Contact No: +91 7064312417",
                          style: TextStyle(
                              fontSize: 14.00, fontWeight: FontWeight.w400)),
                      // Text("GSTIN No: 23DKJFVR445GVVKE",
                      //     style: TextStyle(
                      //         fontSize: 14.00, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                const SizedBox(height: 4.00),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: getCustomerInfo(int.parse(cusid)),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator(); // or some other loading indicator
                    }
                    final customer = snapshot.data![0];
                    final firstName = customer['FirstName'];
                    final lastName = customer['LastName'];
                    return Row(
                      children: [
                        Text(
                          'Customer Name: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('$firstName' /*$lastName*/),
                      ],
                    );
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FutureBuilder<int?>(
                      future: getLatestOrderIdByCustomerId(int.parse(cusid)),
                      builder:
                          (BuildContext context, AsyncSnapshot<int?> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        final customer = snapshot.data!;
                        final order = customer;
                        return Row(
                          children: [
                            Text(
                              'Invoice Number: ',
                            ),
                            Text('$order'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                Text(
                    "Invoice Date: ${DateFormat('MM/dd/yyyy').format(
                        DateTime.now())}",
                    style: const TextStyle(
                        fontSize: 14.00, fontWeight: FontWeight.w400)),
                const SizedBox(height: 15.00),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 20),
                    FutureBuilder<int?>(
                      future: getLatestOrderIdByCustomerId(int.parse(cusid)),
                      builder:
                          (BuildContext context, AsyncSnapshot<int?> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        final customer = snapshot.data!;
                        final order = customer;
                        return Row(
                          children: [
                            Text(
                              'OrderID: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('$order'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const Divider(
                  thickness: 2,
                ),
                InvoiceBuilder(),
                const SizedBox(height: 15.00),
                const Center(
                  child: Text(
                    "Thanks You!",
                    style: TextStyle(color: Colors.grey, fontSize: 15.00),
                  ),
                ),
                const Center(
                  child: Text(
                    "Powered By BuyByeQ",
                    style: TextStyle(color: Colors.grey, fontSize: 15.00),
                  ),
                ),
                const SizedBox(height: 25.00),
                Center(
                  child: Row(
                    children: [
                      InkWell(onTap: () {
                        printDoc();
                      },
                        child: SizedBox(
                          width: 40, height: 40,
                          child: Image(fit: BoxFit.cover,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.2,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.2,
                            image: AssetImage(
                                "assets/save.png"),
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(onTap: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const BTPrinter()));
                      },
                        child: SizedBox(
                          width: 40, height: 40,
                          child: Image(fit: BoxFit.cover,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.2,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.2,
                            image: AssetImage(
                                "assets/p.png"),
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(onTap: () {
                        _sendMessage(int.parse(cusid));
                      },
                        child: SizedBox(
                          width: 40, height: 40,
                          child: Image(fit: BoxFit.cover,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.2,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.2,
                            image: AssetImage(
                                "assets/wa.png"),
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(onTap: () {
                        _sendText(int.parse(cusid));
                      },
                        child: SizedBox(
                          width: 40, height: 40,
                          child: Image(fit: BoxFit.cover,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.2,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.2,
                            image: AssetImage(
                                "assets/sms.png"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
