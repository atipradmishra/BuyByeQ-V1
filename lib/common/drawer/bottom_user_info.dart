import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/connections.dart';
import '../../widgets/intro.dart';

class BottomUserInfo extends StatelessWidget {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  final bool isCollapsed;
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

  BottomUserInfo({
    Key? key,
    required this.isCollapsed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Future<String?> getRestaurantImage() async {
      final db = await _dbService.db;
      final List<Map<String, dynamic>> restaurant = await db.query(
        'Restaurant',
        columns: ['Image'],
        orderBy: 'UpdatedOn DESC',
        limit: 1,
      );
      if (restaurant.isEmpty) {
        return null; // restaurant not found
      }
      return restaurant[0]['Image'];
    }

    Future<String?> getUserName() async {
      final db = await _dbService.db;
      final List<Map<String, dynamic>> user = await db.query(
        'User',
        columns: ['UserFirstName'],
        orderBy: 'UpdatedOn DESC',
        limit: 1,
      );
      if (user.isEmpty) {
        return null; // restaurant not found
      }
      return user[0]['UserFirstName'];
    }

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

    Future<String?> getUserImageOrRes() async {
      var i = await getUI(); // get the current user's ID
      final db = await _dbService.db;

      // check if the current user has an ImagePath value in the User table
      final user = await db.query(
        'User',
        columns: ['ImagePath'],
        where: 'UserId = ?',
        whereArgs: [i],
      );
      if (user.isNotEmpty && user[0]['ImagePath'] != null) {
        // return the ImagePath from the User table
        return user[0]['ImagePath'].toString();
      }

      // if the User table doesn't have an ImagePath for the current user, get the latest Image from the Restaurant table
      final List<Map<String, dynamic>> restaurant = await db.query(
        'Restaurant',
        columns: ['Image'],
        orderBy: 'UpdatedOn DESC',
        limit: 1,
      );
      if (restaurant.isEmpty) {
        return null; // restaurant not found
      }
      final imagePath = restaurant[0]['Image'];

      // update the current user's ImagePath with the retrieved value from the Restaurant table
      await db.update(
        'User',
        {'ImagePath': imagePath},
        where: 'UserId = ?',
        whereArgs: [i],
      );

      return imagePath;
    }




    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isCollapsed ? MediaQuery.of(context).size.width * 0.20 : MediaQuery.of(context).size.width *.25,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: isCollapsed//when isCollapsed is false
          ? Center(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FutureBuilder<String?>(
                          future: getUserImageOrRes(),
                          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Image.file(
                                File(snapshot.data!),
                                fit: BoxFit.fill,
                              );
                            } else {
                              // Placeholder image or empty container
                              return Container(
                                color: Colors.grey,
                                child: Center(child: Text('No Image',style: TextStyle(fontSize: 4))),
                              );
                            }
                          },
                        ),
                      )

                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: FutureBuilder<String?>(
                              future: getUserName(),
                              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Text(
                                    snapshot.data!.split('@')[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                  );
                                } else {
                                  // Placeholder image or empty container
                                  return Center(child: Text('No User Name',style: TextStyle(color:Colors.red,fontSize: 10)));

                                }
                              },
                            ),

                          ),
                        ),
                        SizedBox(height: 7),
                        Expanded(
                          child: Text(
                            'Owner',
                            style: TextStyle(fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'UserId: 23BBQas452',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.tealAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: () {
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
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FutureBuilder<String?>(
                        future: getRestaurantImage(),
                        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.file(
                              File(snapshot.data!),
                              fit: BoxFit.fill,
                            );
                          } else {
                            // Placeholder image or empty container
                            return Container(
                              color: Colors.grey,
                              child: Center(child: Text('No Image',style: TextStyle(fontSize: 4))),
                            );
                          }
                        },
                      ),
                    )

                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 18,
                    ),
                    tooltip: 'Logout',
                  ),
                ),
              ],
            ),
    );
  }
}
