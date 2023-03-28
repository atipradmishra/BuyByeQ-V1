import 'package:buybyeq/screens/addmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common/appBar/apbar.dart';
import '../common/drawer/custom_drawer.dart';
import '../database/menu_curd.dart';
import '../database/menumodel.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {


  @override


  // This function is called whenever the text field changes
  // void _runFilter(String enteredKeyword) {
  //   List<Map<String, dynamic>> results = [];
  //   if (enteredKeyword.isEmpty) {
  //     // if the search field is empty or only contains white-space, we'll display all users
  //     results = _allUsers;
  //   } else {
  //     results = _allUsers
  //         .where((user) =>
  //         user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
  //         .toList();
  //     // we use the toLowerCase() method to make it case-insensitive
  //   }
  //
  // }


  List<Menu> menu = [];
  Menucurdmap _menutablemap = Menucurdmap();
  Menu x = Menu.empty();

  void selectallmenus() async {
    try {
      List<Menu> data = await _menutablemap.selectall();
      menu.clear();
      menu.addAll(data);
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching Menus')));
    }
  }

  Color getCorrectColor(index) {
    if (menu[index].Type == "veg") {
      return Colors.lightGreen;
    } else {
      return Colors.red;
    }
  }
  Color? getColor(index) {
    if (menu[index].Type == "veg") {
      return Colors.green[100];
    }
    else{
      return Colors.red[100];
    }
  }

  @override
  void initState() {
    selectallmenus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    ScreenUtil.init(context, designSize: Size(width, height));
    List<String> menuimage = [];
    for(var a in menu){
      var b = a.ImagePath.toString();
      menuimage.addAll([b]);
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appbar,
        drawer: CustomDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                child: Text(
                  'Menu',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Color(0xFFEF8739),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                // onChanged: (value) => _runFilter(value),
                decoration: const InputDecoration(
                    labelText: 'Search', suffixIcon: Icon(Icons.search)),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                child: Text('Add Menu'),
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMenu(),
                      )).then((value) => selectallmenus());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent[100],
                  side: BorderSide(
                      width: 2, color: Color.fromRGBO(25, 153, 0, 1)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Expanded(
                child: menu.isNotEmpty
                    ? ListView.builder(
                  itemCount: menu.length,
                  itemBuilder: (context, index) => Card(
                      key: ValueKey(menu[index].MenuItemId),
                      color: getColor(index),
                      elevation: 10,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                            child: Container(
                              height: height/12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 12,
                                    color: Color(0x34000000),
                                    offset: Offset(-2, 5),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(8, 8, 12, 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: 4,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        color: getCorrectColor(index),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                              child: Text(
                                                menu[index].MenuItemName.toString(),
                                                maxLines: 1,
                                                style:
                                                TextStyle(
                                                  fontFamily: 'Outfit',
                                                  color: Color(0xFF101213),
                                                  fontSize: ScreenUtil().setSp(20),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '₹ '+ menu[index].Price.toString(),
                                              style:
                                              TextStyle(
                                                fontFamily: 'Outfit',
                                                color: Color(0xFF4B39EF),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          IconButton(
                                              onPressed: (){
                                                showDialog(context: context,barrierDismissible: false, builder: (BuildContext context){
                                                  return AlertDialog(
                                                    title: Text('Confirm'),
                                                    content: Text('Are you sure you want to delete ${menu[index].MenuItemName}?',style: TextStyle(fontSize: ScreenUtil().setSp(20))),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await _menutablemap.deleteItem(menu[index].MenuItemId ?? 0);
                                                          Navigator.pop(context);
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(SnackBar(content: Text('Menu Deleted Successfully')));
                                                        },
                                                        child: Text('Delete'),
                                                      ),
                                                    ],
                                                  );
                                                }).then((value) => selectallmenus());
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                size: 25,
                                                color: Colors.black,
                                              )
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                                  child: IconButton(
                                                      onPressed: () async {
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => AddMenu(
                                                                menus : menu[index],
                                                              ),
                                                            )).then((value) => selectallmenus());
                                                      },
                                                      icon: Icon(
                                                        Icons.edit,
                                                        size: 25,
                                                        color: Colors.black,
                                                      )
                                                  ),
                                                ),
                                              ],
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
                        ],
                      )
                  ),
                )
                    : const Text(
                  'No Menu found',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}