import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:buybyeq/screens/resturabtdetail.dart';
import 'package:buybyeq/screens/rolepage.dart';
import 'package:buybyeq/screens/updateresturant.dart';
import 'package:buybyeq/screens/userspage.dart';
import 'package:csv/csv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:buybyeq/common/appBar/apbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/drawer/custom_drawer.dart';
import '../database/connections.dart';
import '../database/resturant_curd.dart';
import '../database/resturantdetail.dart';
import '../settings/settings.dart';
import 'categorypage.dart';
import 'menupage.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override

  List<Resturant> resturants = [];
  Resturantcurdmap _resturanttablemap = Resturantcurdmap();
  Resturant x = Resturant.empty();

  void selectallrest() async {
    try {
      List<Resturant> data = await _resturanttablemap.selectall();
      resturants.clear();
      resturants.addAll(data);
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching Resturants')));
    }
  }

  @override
  void initState() {
    selectallrest();
    super.initState();
  }

  Widget build(BuildContext context) {
    List<List<dynamic>> _data = [];
    String? filePath;
    ConnectionSQLiteService _connection = ConnectionSQLiteService.instance;

    Future<Database> _getDatabase() async {
      return await _connection.db;
    }

    void _pickFile() async {
      Database db = await _getDatabase();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        // allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      // if no file is picked
      if (result == null) return;
      // we will log the name, size and path of the
      // first picked file (if multiple are selected)
      filePath = result.files.first.path!;

      final input = File(filePath!).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      await db.transaction((txn) async {
        for (final row in fields.skip(1)) {
          await txn.rawQuery(
              '''INSERT INTO MenuCategory (MenuCategoryName) VALUES(?)
              ON CONFLICT (MenuCategoryName) DO NOTHING;
              ''',
              [row[4]]
          );
          await txn.rawInsert(
              'INSERT INTO MenuItem (MenuItemName,Type,DiscountPercentage,Price) VALUES(?, ?,?, ?)',
              [row[0].toString(), row[1].toString().toLowerCase(),row[2],row[3]]
          );
          // await txn.rawQuery(
          //     '''
          //     INSERT INTO ItemCategoryMapping (MenuItemId)
          //     VALUES ((SELECT MenuItemId FROM MenuItem WHERE MenuItemName = ${row[0].toString()})
          //    ''',
          //   [row[4],row[0]]
          // );
        }
      });

      setState(() {
        _data = fields;
      });
    }

    Future<File> savePrebuiltExcelFile() async {
      // Get the path to the app's local storage directory
      String directory = (await getExternalStorageDirectory())!.path;

      // Define the filename for the downloaded Excel file
      String fileName = 'MenuList.csv';

      // Read the file from the app's assets
      ByteData data = await rootBundle.load('assets/MenuList.csv');

      // Write the file to the device's local storage
      File file = File('$directory/$fileName');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);

      return file;
    }

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    ScreenUtil.init(context, designSize: Size(width, height));
    return SafeArea(
        child: Scaffold(
          drawer: const CustomDrawer(),
          appBar: appbar,
          body: SingleChildScrollView(
            child: Container(
              height: height,
              width: width,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, height/15),
                    child: Text(
                      'Configuration',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFFEF8739),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => MenuPage()));
                        },
                        child: Container(
                          width: 160,
                          height: 136,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Color(0x34090F13),
                                offset: Offset(0, 2),
                              )
                            ],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFEF8739),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  child: Text(
                                    'Menu',
                                    style: TextStyle(
                                      color: Color(0xFF101213),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => CategoryPage()));
                        },
                        child: Container(
                          width: 160,
                          height: 136,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Color(0x34090F13),
                                offset: Offset(0, 2),
                              )
                            ],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFEF8739),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  child: Text(
                                    'Category',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF101213),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ),
                    ],
                  ),
                  SizedBox(height: height/40),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => UserPage()));
                        },
                        child: Container(
                          width: 160,
                          height: 136,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Color(0x34090F13),
                                offset: Offset(0, 2),
                              )
                            ],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFEF8739),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  child: Text(
                                    'Users',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF101213),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => RolePage()));
                        },
                        child: Container(
                          width: 160,
                          height: 136,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Color(0x34090F13),
                                offset: Offset(0, 2),
                              )
                            ],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFEF8739),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  child: Text(
                                    'Role',
                                    style: TextStyle(
                                      color: Color(0xFF101213),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height/40),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => Settings()));
                        },
                        child: Container(
                          width: 160,
                          height: 136,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Color(0x34090F13),
                                offset: Offset(0, 2),
                              )
                            ],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFEF8739),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  child: Text(
                                    'Printer/QR-code',
                                    style: TextStyle(
                                      color: Color(0xFF101213),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          if (resturants.isEmpty) {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => ResturantDetailUpdate())).then((value) => selectallrest());;
                          } else {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => ResturantDetail()));
                          }
                        },
                        child: Container(
                          width: 160,
                          height: 136,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Color(0x34090F13),
                                offset: Offset(0, 2),
                              )
                            ],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFEF8739),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  child: Text(
                                    'Restaurant Details',
                                    style: TextStyle(
                                      color: Color(0xFF101213),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(15, 40, 10, height/20),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                onTap: () async {
                                  File file = await savePrebuiltExcelFile();
                                  String path = file.path;
                                  bool launched = await launch(path, forceSafariVC: false);
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF090F13),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 5,
                                        color: Color(0x3314181B),
                                        offset: Offset(0, 2),
                                      )
                                    ],
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Icon(
                                    Icons.cloud_download_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              Text(
                                'Download Template',
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              onTap: () async {
                                final androidInfo = await DeviceInfoPlugin().androidInfo;
                                late final Map<Permission,PermissionStatus> statusess;
                                if (androidInfo.version.sdkInt! <= 32){
                                  statusess = await [
                                    Permission.storage
                                  ].request();
                                } else {
                                  statusess = await [
                                    Permission.photos
                                  ].request();
                                }
                                var allAccepted = true;
                                statusess.forEach((permission, status) {
                                  if (status != PermissionStatus.granted){
                                    allAccepted = false;
                                  }
                                });
                                if (allAccepted){
                                  _pickFile();
                                } else {
                                  await  openAppSettings();
                                }
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color(0xFF090F13),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 5,
                                      color: Color(0x3314181B),
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                  shape: BoxShape.circle,
                                ),
                                alignment: AlignmentDirectional(0, 0),
                                child: Icon(
                                  Icons.cloud_upload,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                            Text(
                              'Upload Menu/Category',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}
