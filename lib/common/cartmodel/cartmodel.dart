import 'package:buybyeq/menu&cart/cartprovider/cartprovider.dart';
import 'package:buybyeq/menu&cart/screens/cartui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class CartStackModel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart,child){
      return Stack(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/cart') {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen(), settings: RouteSettings(name: '/cart'))
                );
              }
            },
          ),

          if(cart.getCounter()>0)
          Positioned(
            right: 8,
            top: 23,
            child: Container(padding: EdgeInsets.all(1),
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red,
                  border: Border.all(color: Colors.white)),
              child: Center(
                  child: Text(
                '${cart.getCounter()}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 10),
              )),
            ),
          ),

        ],
      );}
    );
  }
}
