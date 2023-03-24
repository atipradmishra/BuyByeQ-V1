import 'package:buybyeq/invoice/Screens/Widgets/invoice_table.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart'as pw;
import 'package:provider/provider.dart';

import '../../../menu&cart/cartprovider/cartprovider.dart';
import '../../../menu&cart/models/cartmodel.dart';

final List<String> _food = ["Veg Roll", "Chicken Soup", "Rice", "Biryani"];
List<String> get food => _food;
final List<double> _price = [2.15, 3.61, 4.21, 5.32];
List<double> get price => _price;
final List<int> _quantity = [2, 3, 1, 5];
List<int> get quantity => _quantity;
CartProvider cart=CartProvider();
Future<List<Cart>>itemscart=cart.getData();


buildPrintableData() => pw.Center(
        child: pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Padding(
          padding:
              const pw.EdgeInsets.only(top: 5, bottom: 20, left: 40, right: 40),
          child:pw.Column(children: [
            pw.Text("Biryani Bites",
                style: pw.TextStyle(fontSize: 25.00, fontWeight: pw.FontWeight.bold)),
            pw.Text("Gopabandhu Chaka, Unit -- 8 Bhubasenswar",
                style: const pw.TextStyle(
                  fontSize: 14.00,
                )),
            pw.Text("Contact No: +91 99999999",
                style: const pw.TextStyle(
                  fontSize: 14.00,
                )),
            pw.Text("GSTIN No: 23DKJFVR445GVVKE",
                style: const pw.TextStyle(
                  fontSize: 14.00,
                )),
          ]),
        ),
        pw.SizedBox(height: 4.00),
        pw.Text("Customer Name: Mr. Pradeep Bisai",
            style: pw.TextStyle(fontSize: 14.00, fontWeight: pw.FontWeight.bold)),
        pw.Text("Invoice Number: 14722",
            style: const pw.TextStyle(
              fontSize: 14.00,
            )),
        pw.Text("Invoice Date: ${DateFormat('MM/dd/yyyy').format(DateTime.now())}",
            style: const pw.TextStyle(
              fontSize: 14.00,
            )),
        pw.SizedBox(height: 15.00),
        pw.Divider(thickness: 2,),
        pw.Column(
          children: [
            //header()
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(width: 20),
                pw.Text(
                  "ORDER ID: 200",
                  style:
                  pw.TextStyle(fontSize: 14.00, fontWeight: pw.FontWeight.bold),
                )
              ],
            ),

            pw.SizedBox(height: 10.00),
            // tableHeader(),
            pw.Container(
              width: double.infinity,
              height: 36.00,
              child:pw.Center(
                child:pw.Row(
                  children: [
                    pw.Text(
                      "Item Name",
                      style: pw.TextStyle(
                          fontSize: 16.00, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "Quantity",
                      style: pw.TextStyle(
                          fontSize: 16.00, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "Rate",
                      style: pw.TextStyle(
                          fontSize: 16.00, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "Total",
                      style: pw.TextStyle(
                          fontSize: 16.00, fontWeight:pw. FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < food.length; i++) buildTableData(i),
            pw.SizedBox(height: 15),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 5.0),
              child: pw.Container(
                width: double.infinity,
                height: 120,
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Sub Total",
                          style: pw.TextStyle(
                            fontSize: 14.00,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Spacer(),
                        pw.Text(
                          "\$ 23.50",
                          style: pw.TextStyle(
                            fontSize: 14.00,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Discount",
                          style: pw.TextStyle(
                            fontSize: 14.00,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Spacer(),
                        pw.Text(
                          "\$ 23.50",
                          style: pw.TextStyle(
                            fontSize: 14.00,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          "CGST @2.5%",
                          style: pw.TextStyle(
                            fontSize: 14.00,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Spacer(),
                        pw.Text(
                          "\$ 23.50",
                          style: pw.TextStyle(
                            fontSize: 15.00,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          "SGST@2.5",
                          style: const pw.TextStyle(
                            fontSize: 14.00,
                          ),
                        ),
                        pw.Spacer(),
                        pw.Text(
                          "\$ 23.50",
                          style: pw.TextStyle(
                            fontSize: 14.00,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Grand Total",
                          style: pw.TextStyle(
                            fontSize: 14.00,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Spacer(),
                        pw.Text(
                          "\$ 23.50",
                          style: pw.TextStyle(
                            fontSize: 14.00,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 2,),
        pw.SizedBox(height: 15.00),
        pw.Center(
          child: pw.Text(
            "Thanks You!",
            style: const pw.TextStyle(fontSize: 15.00),
          ),
        ),
        pw.Center(
          child: pw.Text(
            "Powered By BuyByeQ",
            style: const pw.TextStyle( fontSize: 15.00),
          ),
        ),
      ]),
    ));

pw.Container buildTableData(int i) => pw.Container(
      width: double.infinity,
      height: 36.00,
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: .0),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Container(
              width: 150,
              child: pw.Text(
                " ${food[i]}",
                style: pw.TextStyle(fontSize: 14.00, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              width: 50,
              child: pw.Center(
                child: pw.Text(
                  "${quantity[i]}",
                  style:
                  pw.TextStyle(fontSize: 14.00, fontWeight: pw.FontWeight.normal),
                ),
              ),
            ),
            pw.Container(
              width: 80,
              child: pw.Center(
                child: pw.Text(
                  "${price[i]}",
                  style:
                  pw.TextStyle(fontSize: 14.00, fontWeight: pw.FontWeight.normal),
                ),
              ),
            ),
            pw.Container(
              width: 60,
              child: pw.Center(
                child: pw.Text(
                  "${price[i] * quantity[i]}",
                  style:
                  pw.TextStyle(fontSize: 18.00, fontWeight: pw.FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
      ),
    );

