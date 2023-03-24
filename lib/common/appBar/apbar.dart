import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/pagesnav.dart';
import '../cartmodel/cartmodel.dart';

// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
AppBar appbar=AppBar(

      leading: Row(
        children: [

          Padding(
            padding: const EdgeInsets.only(left:4),
            child: SizedBox(width:40,height:40,child: Image.asset(fit: BoxFit.cover,'assets/buybyeq_logo.png'),),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFF9900),
      title: const Text(
        'BuyByeQ',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        CartStackModel()
      ],
    );

