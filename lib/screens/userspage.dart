import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common/appBar/apbar.dart';
import '../common/drawer/custom_drawer.dart';
import '../database/usemodel.dart';
import '../database/user_curd.dart';
import 'adduserpage.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  @override

  List<User> user = [];
  Usercurdmap _usertablemap = Usercurdmap();
  User x = User.empty();

  void selectallusers() async {
    try {
      List<User> data = await _usertablemap.selectall();
      user.clear();
      user.addAll(data);
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching Menus')));
    }
  }


  @override
  void initState() {
    selectallusers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    ScreenUtil.init(context, designSize: Size(width, height));
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
                  'Users',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Color(0xFFEF8739),
                    fontSize: ScreenUtil().setSp(25),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                // onChanged: (value) => _runFilter(value),
                decoration: const InputDecoration(
                    labelText: 'Search', suffixIcon: Icon(Icons.search)),
              ),
              SizedBox(
                height: height/35,
              ),
              ElevatedButton(
                child: Text('Add User'),
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddUser(),
                      )).then((value) => selectallusers());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                      width: 2, color: Color.fromRGBO(25, 153, 0, 1)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Expanded(
                child: user.isNotEmpty
                    ? ListView.builder(
                  itemCount: user.length,
                  itemBuilder: (context, index) => Card(
                      key: ValueKey(user[index].UserId),
                      elevation: 10,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.person_outline_outlined,
                                  color: Color(0xFF4B39EF),
                                  size: 32,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user[index].UserName.toString(),
                                          style: TextStyle(
                                            color: Color(0xFF101213),
                                            fontSize: ScreenUtil().setSp(18),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
                                  child: IconButton(
                                      onPressed: (){
                                        showDialog(context: context,barrierDismissible: false, builder: (BuildContext context){
                                          return AlertDialog(
                                            title: Text('Confirm'),
                                            content: Text('Are you sure you want to delete ${user[index].UserName}?',style: TextStyle(fontSize: ScreenUtil().setSp(20))),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await _usertablemap.deleteItem(user[index].UserId ?? 0);
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(content: Text('Category Deleted Successfully')));
                                                },
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          );
                                        }).then((value) => selectallusers());
                                      },
                                      icon: Icon(
                                        Icons.delete_outlined,
                                        size: 25,
                                        color: Colors.black,
                                      )
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddUser(
                                              // roles : role[index],
                                            ),
                                          )).then((value) => selectallusers());
                                    },
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 25,
                                      color: Colors.black,
                                    )
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                )
                    : const Text(
                  'No User found',
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