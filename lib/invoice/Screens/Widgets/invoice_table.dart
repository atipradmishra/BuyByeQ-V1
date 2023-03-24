import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../../../menu&cart/cartprovider/cartprovider.dart';
import '../../../menu&cart/screens/cartui.dart';

class InvoiceBuilder extends StatelessWidget {
  InvoiceBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Column(
      children: [
        const SizedBox(height: 10.00),
        tableHeader(),
        Consumer<CartProvider>(builder: (
          BuildContext context,
          provider,
          index,
        ) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: provider.cart.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: .0),
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          " ${provider.cart[index].productName}",
                          style: const TextStyle(
                              fontSize: 14.00, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Center(
                          child: Text(
                            "${provider.cart[index].quantity!.value}",
                            style: const TextStyle(
                                fontSize: 14.00, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Center(
                          child: Text(
                            "${provider.cart[index].productPrice}",
                            style: const TextStyle(
                                fontSize: 14.00, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Center(
                          child: Text(
                            "${provider.cart[index].productPrice! * provider.cart[index].quantity!.value}",
                            style: const TextStyle(
                                fontSize: 14.00, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
        const Divider(
          thickness: 2,
        ),
        const SizedBox(height: 15.00),
        buildTotal(),
      ],
    );
  }



  Widget tableHeader() => Container(
        color: Colors.white10,
        width: double.infinity,
        height: 36.00,
        child: Center(
          child: Row(
            children: const [
              Text(
                "Item Name",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.00,
                    fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                "Quantity",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.00,
                    fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                "Rate",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.00,
                    fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                "Total",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.00,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

  Widget buildTotal() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
            color: const Color.fromARGB(255, 255, 251, 251),
            width: double.infinity,
            height: 160,
            child: SingleChildScrollView(child: Consumer<CartProvider>(
                builder: (BuildContext context, value, Widget? child) {
              final ValueNotifier<double> totalPrice = ValueNotifier(0);
              for (var element in value.cart) {
                totalPrice.value =
                    (element.productPrice! * element.quantity!.value) +
                        (totalPrice.value);
              }
              return ValueListenableBuilder<double>(
                valueListenable: totalPrice,
                builder: (context, val, child) {
                    return Column(
                    children: [
                     Calculation(),

                    ],
                  );
                },
              );
            }))),
      );
}
