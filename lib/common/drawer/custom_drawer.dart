import 'package:buybyeq/common/drawer/bottom_user_info.dart';
import 'package:buybyeq/common/drawer/custom_list_tile.dart';
import 'package:buybyeq/common/drawer/header.dart';
import 'package:flutter/material.dart';
import '../../screens/ordersrecords/completeordersdatesort.dart';
import '../../screens/ordersrecords/orderViewingNoEdit.dart';
import '../../screens/settings.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedContainer(
        curve: Curves.easeInBack,
        duration: const Duration(milliseconds: 500),
        width:// _isCollapsed
            //?
          MediaQuery.of(context).size.width * 0.75,
            //: MediaQuery.of(context).size.width * 0.15,
        margin: const EdgeInsets.only(bottom: 15, top: 15),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          color: Color.fromRGBO(252, 253, 253, 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomDrawerHeader(isColapsed: !_isCollapsed),
              const Divider(
                color: Colors.deepOrange,
              ),
              CustomListTile(
                onTapped: () {
                  print('tapped dashboard');
                },
                isCollapsed: !_isCollapsed,
                icon: Icons.home_outlined,
                title: 'DashBoard',
                infoCount: 0,
              ),
              CustomListTile(
                isCollapsed: !_isCollapsed,
                icon: Icons.calendar_today,
                title: 'Take Order',
                infoCount: 0,
                onTapped: () {
                  print('tapped take order');
                },
              ),
              CustomListTile(
                isCollapsed: !_isCollapsed,
                icon: Icons.view_week,
                title: 'View Orders',
                infoCount: 0,
                onTapped: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrdersNoEdit(),
                    ),
                  );
                },
              ),
              CustomListTile(
                isCollapsed: !_isCollapsed,
                icon: Icons.incomplete_circle,
                title: 'Complete Orders',
                infoCount: 0,
                onTapped: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersComplete(),
                      ));
                },
              ),
              CustomListTile(
                isCollapsed: !_isCollapsed,
                icon: Icons.cloud,
                title: 'Store/Inventory',
                infoCount: 0,
                onTapped: () {},
              ),
              CustomListTile(
                isCollapsed: !_isCollapsed,
                icon: Icons.download_for_offline,
                title: 'Downloads',
                infoCount: 1,
                onTapped: () {},
              ),
              const Divider(
                color: Colors.deepOrange,
              ),
              const Spacer(),
              CustomListTile(
                isCollapsed: !_isCollapsed,
                icon: Icons.notifications,
                title: 'Notifications',
                infoCount: 0,
                onTapped: () {

                },
              ),
              CustomListTile(
                isCollapsed: !_isCollapsed,
                icon: Icons.settings,
                title: 'Settings',
                infoCount: 0,
                onTapped: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                },
              ),
              const SizedBox(height: 10),
              BottomUserInfo(isCollapsed: !_isCollapsed),
              // Align(
              //   alignment: !_isCollapsed
              //       ? Alignment.bottomRight
              //       : Alignment.bottomCenter,
              //   child: IconButton(
              //     splashColor: Colors.transparent,
              //     icon: Icon(
              //       _isCollapsed
              //           ? Icons.arrow_back_ios
              //           : Icons.arrow_forward_ios,
              //       color: Colors.black,
              //       size: 16,
              //     ),
              //     onPressed: () {
              //       setState(() {
              //         _isCollapsed = !_isCollapsed;
              //       });
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
