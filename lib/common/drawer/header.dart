import 'dart:io';

import 'package:flutter/material.dart';

import '../../database/connections.dart';

class CustomDrawerHeader extends StatelessWidget {
  final bool isColapsed;
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;

  CustomDrawerHeader({
    Key? key,
    required this.isColapsed,
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

    Future<String?> getRestaurantName() async {
      final db = await _dbService.db;
      final List<Map<String, dynamic>> restaurant = await db.query(
        'Restaurant',
        columns: ['RestaurantName'],
        orderBy: 'UpdatedOn DESC',
        limit: 1,
      );
      if (restaurant.isEmpty) {
        return null; // restaurant not found
      }
      return restaurant[0]['RestaurantName'];
    }


    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: isColapsed
          ? MediaQuery.of(context).size.width * 0.50
          : MediaQuery.of(context).size.width * .2,
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.only(top: 12,bottom: 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isColapsed) Center(
                          child: Container(
                              width: MediaQuery.of(context).size.width * .12,
                              height: MediaQuery.of(context).size.width * .10,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80)),
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
                              ))) else Center(
                          child: Container(
                              width: MediaQuery.of(context).size.width * .31,
                              height: MediaQuery.of(context).size.width * .5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  ClipRRect(
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
                                            width: 50,
                                            height: 50,
                                            color: Colors.grey,
                                            child: Center(child: Text('No Image',style: TextStyle(fontSize: 4))),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child:
                                      FutureBuilder<String?>(
                                        future: getRestaurantName(),
                                        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                          if (snapshot.hasData && snapshot.data != null) {
                                            return Text(
                                              snapshot.data!,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                              maxLines: 1,
                                            );
                                          } else {
                                            // Placeholder image or empty container
                                            return Center(child: Text('No Restaurant Name',style: TextStyle(color:Colors.red,fontSize: 10)));

                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )))
            ],
          ),
        ),
      ),
    );
  }
}
