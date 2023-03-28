import 'dart:io';

import 'package:buybyeq/common/appBar/apbar.dart';
import 'package:buybyeq/screens/pagesnav.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../database/connections.dart';
import '../myaccount.dart';

class UserDetailsUpdateForm extends StatefulWidget {
  @override
  _UserDetailsUpdateFormState createState() => _UserDetailsUpdateFormState();
}

class _UserDetailsUpdateFormState extends State<UserDetailsUpdateForm> {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _gender = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phoneNo = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _streetNo = TextEditingController();
  TextEditingController _zipCode = TextEditingController();
  FilePickerResult? result;
  String? _filePath;
  PlatformFile? pickedfile;
  bool isLoding = false;
  File? fileToDisplay;

  Future<int?> getUI() async {
    final db = await _dbService.db;
    final List<Map<String, dynamic>> users = await db.query(
      'User',
      columns: ['UserId'],
      where: 'IsActive = 1',
      limit: 1,
    );
    if (users.isEmpty) {
      return null; // user not found
    }
    return users[0]['UserId'];
  }

  Future<String?> getUserImage() async {
    final db = await _dbService.db;
    var i = await getUI();
    final List<Map<String, dynamic>> user = await db.query(
      'User',
      columns: ['ImagePath'],
      orderBy: 'UpdatedOn DESC',
      where: 'UserId = ?',
      whereArgs: [i],
      limit: 1,
    );
    if (user.isEmpty) {
      return null; // restaurant not found
    }
    return user[0]['ImagePath'];
  }

  void pickFile() async {
    try {
      setState(() {
        isLoding = true;
      });
      result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null) {
        pickedfile = result!.files.first;
        fileToDisplay = File(pickedfile!.path.toString());
        _filePath = pickedfile!.path.toString();
      }
      setState(() {
        isLoding = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void showmessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> getAllUserValues() async {
    final db = await _dbService.db;
    var users = await db.query(
      'User',
      where: 'IsActive = 1',
      limit: 1,
    );
    for (final user in users) {
      final userFirstName = user['UserFirstName'].toString();
      final userLastName = user['UserLastName'].toString();
      final userName = user['UserName'].toString();
      final gender = user['Gender'].toString();
      final email = user['Email'].toString();
      final phoneNo = user['PhoneNo'].toString();
      final address = user['Address'].toString();
      final streetNo = user['StreetNo'].toString();
      final zipCode = user['ZipCode'].toString();
      final imagePath = user['ImagePath'].toString();

      setState(() {
        _firstName = TextEditingController(text: userFirstName);
        _lastName = TextEditingController(text: userLastName);
        _username = TextEditingController(text: userName);
        _gender = TextEditingController(text: gender);
        _email = TextEditingController(text: email);
        _phoneNo = TextEditingController(text: phoneNo);
        _address = TextEditingController(text: address);
        _streetNo = TextEditingController(text: streetNo);
        _zipCode = TextEditingController(text: zipCode);
      });
    }
  }

  void saveData() async {
    Future<int?> getUI() async {
      final db = await _dbService.db;
      final List<Map<String, dynamic>> users = await db.query(
        'User',
        columns: ['UserId'],
        where: 'IsActive = 1',
        limit: 1,
      );
      if (users.isEmpty) {
        return null; // user not found
      }
      return users[0]['UserId'];
    }

    final db = await _dbService.db;
    final String fname = _firstName.text.trim();
    final String lname = _lastName.text.trim();
    final String uname = _username.text.trim();
    final String gen = _gender.text.trim();
    final String em = _email.text.trim();
    final String ph = _phoneNo.text.trim();
    final String address = _address.text.trim();
    final String sn = _streetNo.text.trim();
    final String zp = _zipCode.text.trim();
    final String path = _filePath?.trim() ?? '';

    var id = await getUI();

    if (fname.isNotEmpty) {
      await db.update(
        'User',
        {'UserFirstName': fname},
        where: 'UserId = ?',
        whereArgs: [id],
      );
    }
    if (lname.isNotEmpty) {
      await db.update(
        'User',
        {'UserLastName': lname},
        where: 'UserId = ?',
        whereArgs: [id],
      );
    }

    if (uname.isNotEmpty) {
      await db.update(
        'User',
        {'UserName': uname},
        where: 'UserId = ?',
        whereArgs: [id],
      );
    }

    if (gen.isNotEmpty) {
      await db.update(
        'User',
        {'Gender': gen},
        where: 'UserId = ?',
        whereArgs: [id],
      );
    }

    if (em.isNotEmpty) {
      await db.update(
        'User',
        {'Email': em},
        where: 'UserId = ?',
        whereArgs: [id],
      );
    }

    if (ph.isNotEmpty) {
      await db.update(
        'User',
        {'PhoneNo': ph},
        where: 'UserId = ?',
        whereArgs: [id],
      );
    }

    if (address.isNotEmpty) {
      await db.update(
        'User',
        {'Address': address},
        where: 'UserId = ?',
        whereArgs: [id],
      );
    }

    if (sn.isNotEmpty) {
      await db.update(
        'User',
        {'StreetNo': sn},
        where: 'UserId = ?',
        whereArgs: [id],
      );
    }

    if (zp.isNotEmpty) {
      await db.update(
        'User',
        {'ZipCode': zp},
        where: 'UserId = ?',
        whereArgs: [id],
      );
    }
    if (path.isNotEmpty) {
      await db.update(
        'User',
        {'ImagePath': path},
        where: 'UserId = ?',
        whereArgs: [id],
      );
    }
  }

  @override
  void initState() {
    getAllUserValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    ScreenUtil.init(context, designSize: Size(width, height));
    return Scaffold(
      appBar: appbar,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                'Edit My Details',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Color(0xFFEF8739),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () async {
                final androidInfo = await DeviceInfoPlugin().androidInfo;
                late final Map<Permission, PermissionStatus> statusess;
                if (androidInfo.version.sdkInt! <= 32) {
                  statusess = await [Permission.storage].request();
                } else {
                  statusess = await [Permission.photos].request();
                }

                var allAccepted = true;
                statusess.forEach((permission, status) {
                  if (status != PermissionStatus.granted) {
                    allAccepted = false;
                  }
                });
                if (allAccepted) {
                  pickFile();
                } else {
                  showmessage('This permission is required');
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: width / 6,
                child: fileToDisplay != null || _filePath != null
                    ? ClipOval(
                        child: Image.file(
                          File(_filePath!),
                          fit: BoxFit.cover,
                          width: width / 2,
                          height: height / 4,
                        ),
                      )
                    : FutureBuilder<String?>(
                        future: getUserImage(),
                        builder: (BuildContext context,
                            AsyncSnapshot<String?> snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return ClipOval(
                              child: Image.file(
                                File(snapshot.data!),
                                width: width / 2,
                                height: height / 4,
                                fit: BoxFit.cover,
                              ),
                            );
                          } else {
// Placeholder image or empty container
                            return Container(
                              color: Colors.grey,
                              child: Center(
                                  child: Text('No Image',
                                      style: TextStyle(fontSize: 4))),
                            );
                          }
                        },
                      ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.58,
                child: Form(
                    key: _formKey,
                    child: ListView(
                        padding: EdgeInsets.all(16.0),
                        children: <Widget>[
                          TextFormField(
                            controller: _firstName,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter first name';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _lastName,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                            ),
                          ),
                          TextFormField(
                            controller: _username,
                            decoration: InputDecoration(
                              labelText: 'Username',
                            ),
                          ),
                          TextFormField(
                            controller: _gender,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                            ),
                          ),
                          TextFormField(
                            controller: _email,
                            decoration: InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                          TextFormField(
                            controller: _phoneNo,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                            ),
                          ),
                          TextFormField(
                            controller: _address,
                            decoration: InputDecoration(
                              labelText: 'Address',
                            ),
                          ),
                          TextFormField(
                            controller: _streetNo,
                            decoration: InputDecoration(
                              labelText: 'Street Number',
                            ),
                          ),
                          TextFormField(
                            controller: _zipCode,
                            decoration: InputDecoration(
                              labelText: 'Zip Code',
                            ),
                          ),
                        ])),
              ),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    saveData();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Updating UserInfo...',
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 1),
                      ),
                    );
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LetsNavi(),
                        ));
                  },
                  child: Text('Save')),
            )
          ],
        ),
      ),
    );
  }
}
