import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common/appBar/apbar.dart';
import '../common/drawer/custom_drawer.dart';
import '../database/role_curd.dart';
import '../database/rolemodel.dart';
import 'addrolepage.dart';

class RolePage extends StatefulWidget {
  const RolePage({Key? key}) : super(key: key);

  @override
  _RolePageState createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {


  @override


  List<Role> role = [];
  Rolecurdmap _roletablemap = Rolecurdmap();

  void selectallroles() async {
    try {
      List<Role> data = await _roletablemap.selectall();
      role.clear();
      role.addAll(data);
      setState(() {});
    } catch (error) {
      showmessage('Error fetching Data');
    }
  }

  void showmessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }



  @override
  void initState() {
    selectallroles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    ScreenUtil.init(context, designSize: Size(width, height));
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
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
                    'Role',
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
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  child: Text('Add Role'),
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRole(),
                        )).then((value) => selectallroles());
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
                  child: role.isNotEmpty
                      ? ListView.builder(
                        itemCount: role.length,
                        itemBuilder: (context, index) => Card(
                        key: ValueKey(role[index].RoleId),
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
                                            role[index].RoleName.toString(),
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
                                              content: Text('Are you sure you want to delete ${role[index].RoleName}?',style: TextStyle(fontSize: ScreenUtil().setSp(20))),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _roletablemap.deleteItem(role[index].RoleId ?? 0);
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(SnackBar(content: Text('Category Deleted Successfully')));
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            );
                                          }).then((value) => selectallroles());
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
                                              builder: (context) => AddRole(
                                                roles : role[index],
                                              ),
                                            )).then((value) => selectallroles());
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
                    'No Role found',
                    style: TextStyle(fontSize: 24),
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