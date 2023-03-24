import 'package:buybyeq/common/appBar/apbar.dart';
import 'package:buybyeq/menu&cart/screens/menufood.dart';
import 'package:flutter/material.dart';

import '../common/drawer/custom_drawer.dart';
import 'myaccount.dart';
import 'orders.dart';
class LetsNavi extends StatefulWidget {
  const LetsNavi({Key? key}) : super(key: key);

  @override
  State<LetsNavi> createState() => _LetsNaviState();
}

class _LetsNaviState extends State<LetsNavi> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;
  final List _listPages = [];
  late Widget _currentPage;
  @override
  void initState() {
    super.initState();
    _listPages
      ..add(const ShoppingMenu())
      ..add(const Orders())
      ..add(MyAccountScreen());
    _currentPage = const ShoppingMenu();
  }

  void _changePage(int selectedIndex) {
    setState(() {
      _currentIndex = selectedIndex;
      _currentPage = _listPages[selectedIndex];
    });
  }
  Widget build(BuildContext context) {
    return  Scaffold(
      key:_scaffoldKey,
      appBar: appbar,
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 15,
        onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
              },
        child: const Icon(Icons.menu,color:Colors.orangeAccent),),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body:_currentPage,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFF9900),
        selectedItemColor: const Color(0xFF10161d),
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt,),
            label: "Running Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
        ],
        onTap: (selectedIndex) => _changePage(selectedIndex),
      ),
    );
  }
}
