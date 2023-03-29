import 'dart:io';
import 'dart:ui';
import 'package:buybyeq/screens/updateresturant.dart';
import 'package:flutter/material.dart';
import '../common/appBar/apbar.dart';
import '../common/drawer/custom_drawer.dart';
import '../database/resturant_curd.dart';
import '../database/resturantdetail.dart';

class ResturantDetail extends StatefulWidget {
  @override
  _ResturantDetailState createState() => _ResturantDetailState();
}

class _ResturantDetailState extends State<ResturantDetail> {
  String? fileToDisplay;
  String? resturantname;
  String? resturantadress;
  String? resturantemail;

  List<Resturant> resturants = [];
  Resturantcurdmap _resturanttablemap = Resturantcurdmap();
  Resturant x = Resturant.empty();

  void selectall() async {
    try {
      List<Resturant> data = await _resturanttablemap.selectall();
      resturants.clear();
      resturants.addAll(data);
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching restaurants')));
    }
  }

  @override
  void initState() {
    selectall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    for (var a in resturants){
      fileToDisplay = resturants[0].Image;
      resturantname = resturants[0].RestaurantName;
      resturantadress = resturants[0].Address;
      resturantemail = resturants[0].Email;
    }
    return SafeArea(
      child: Scaffold(
        appBar: appbar,
        drawer: CustomDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height/20),
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: width/4,
                child: fileToDisplay != null ?
                ClipOval(
                  child: Image.file(
                    File(fileToDisplay!),
                    fit: BoxFit.cover,
                    width: width/2,
                    height: height/4,
                  ),
                ) :
                Container(
                    child: Icon(
                      Icons.no_photography_outlined,
                      color: Colors.red.shade400,
                      size: 60,
                    ),
                    width: width/2,
                    height: height/5
                ),
              ),
              SizedBox(height: height/100),
              Text(
                "$resturantname",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                maxLines: 1,
              ),
              SizedBox(height: height/80),
              resturantemail != null || resturantemail == '' ?
              Text(
                '$resturantemail',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 1,
              ) :
              Text(
                  "No email",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 1,
              ),
              SizedBox(height: height/80),
              resturantadress != null || resturantadress == '' ?
              Text(
                '$resturantadress',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),

                maxLines: 3,
              ) :
              Text(
                "No address",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
                maxLines: 1,
              ),
              SizedBox(height: height/100),
              ListTile(
                leading: Icon(Icons.restaurant,size: 30),
                title: Text('Edit restaurant Info'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResturantDetailUpdate(
                            resturants : resturants[0],
                        ),
                      )).then((value) => selectall());
                },
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
