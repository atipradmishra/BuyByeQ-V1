import 'package:flutter/material.dart';
import '../common/appBar/apbar.dart';
import '../common/drawer/custom_drawer.dart';
import '../database/role_curd.dart';
import '../database/rolemodel.dart';


class AddRole extends StatefulWidget {
  Role? roles;
  AddRole({this.roles});

  @override
  State<AddRole> createState() => _AddRoleState();
}

class _AddRoleState extends State<AddRole> {

  TextEditingController _txtrolename = TextEditingController();
  Rolecurdmap _roletablemap = Rolecurdmap();
  Role role = Role.empty();

  String title = "Add Role";
  void FormData() {
    if (widget.roles != null) {
      title = "Update Role";
      _txtrolename.text = widget.roles!.RoleName.toString();
      role = widget.roles!;
    }
  }

  void save() {
    role.RoleName = _txtrolename.text;
    if (role.RoleId == null) {
      addrole();
      return;
    }
    else {
      updaterole();
    }
  }

  void updaterole() async {
    try {
      if (await _roletablemap.update(role)) {
        showmessage('Role updated');
        return;
      }
      showmessage('No Role changed');
    } catch (error) {
      print(error);
      showmessage('Error');
    }
  }

  void addrole() async {
    try {
      role.RoleName = _txtrolename.text;
      Role data = await _roletablemap.add(role);
      role.RoleId = data.RoleId;
      showmessage('Role added successful');
      setState(() {});
    } catch (error) {
      print(error);
      showmessage('Error Saving Role');
    }
  }

  void showmessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    FormData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
          child: Scaffold(
            appBar: appbar,
            drawer: CustomDrawer(),
            body: Column(
              children: [
                SizedBox(height: height/50),
                Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFFEF8739),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(30, height/4, 30, 10),
                  child: TextFormField(
                    controller: _txtrolename,
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: 'Role name',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height/15,
                  width: width/3,
                  child: ElevatedButton(
                    child: Text('Save', style: TextStyle(fontSize: 25,color: Colors.green),),
                    onPressed: () async {
                      var a = _txtrolename.text;
                      if (a == null || a ==''){
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Role Name is Required')));
                      } else {
                        save();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          width: 1, color: Color.fromRGBO(25, 153, 0, 1)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}
