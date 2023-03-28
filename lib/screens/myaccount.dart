import 'dart:io';
import 'dart:ui';

import 'package:buybyeq/screens/userinfos/edit.dart';
import 'package:buybyeq/screens/userinfos/passwordchng.dart';
import 'package:buybyeq/widgets/intro.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/connections.dart';

class MyAccountScreen extends StatefulWidget {
  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
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

  Future<void> _breakSession() async {
    final prefs = await SharedPreferences.getInstance();
    var id=await getUI();
    final db = await ConnectionSQLiteService.instance.db;
    await db.update(
      'User',
      {'IsActive': 0},
      where: 'UserId = ?',
      whereArgs: [id],
    );
    await prefs.setBool('logged_in', false);
  }

  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;

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

  Future<String?> getUserName() async {
    final db = await _dbService.db;
    final List<Map<String, dynamic>> name = await db.query(
      'User',
      columns: ['UserFirstName'],
      orderBy: 'UpdatedOn DESC',
      limit: 1,
    );
    if (name.isEmpty) {
      return null; // restaurant not found
    }
    return name[0]['UserFirstName'];
  }

  Future<String?> getEmail() async {
    final db = await _dbService.db;
    final List<Map<String, dynamic>> em = await db.query(
      'User',
      columns: ['Email'],
      orderBy: 'UpdatedOn DESC',
      limit: 1,
    );
    if (em.isEmpty) {
      return null; // restaurant not found
    }
    return em[0]['Email'];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            ClipOval(
              child: FutureBuilder<String?>(
                future: getUserImage(),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
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
                          child:
                              Text('No Image', style: TextStyle(fontSize: 4))),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            FutureBuilder<String?>(
              future: getUserName(),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Text(
                    snapshot.data!.split('@')[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  );
                } else {
                  // Placeholder image or empty container
                  return Center(
                      child: Text('No User Name',
                          style: TextStyle(color: Colors.red, fontSize: 10)));
                }
              },
            ),
            SizedBox(height: 5),
            FutureBuilder<String?>(
              future: getEmail(),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Text(
                    snapshot.data!,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  );
                } else {
                  // Placeholder image or empty container
                  return Center(
                      child: Text('No Email',
                          style: TextStyle(color: Colors.red, fontSize: 10)));
                }
              },
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Edit Profile'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsUpdateForm(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Change Password'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(),
                    ));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Log Out',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange)),
                        content: const Text('LogOut of BuyByeQ?',
                            style: TextStyle(fontSize: 16)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _breakSession();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Intro()));
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
