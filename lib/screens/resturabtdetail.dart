import 'dart:io';
import 'package:buybyeq/database/resturant_curd.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import '../common/appBar/apbar.dart';
import '../common/drawer/custom_drawer.dart';
import '../database/resturantdetail.dart';

class ResturantDetail extends StatefulWidget {
  final Resturant? resturant;
  const ResturantDetail({Key? key, this.resturant}) : super(key: key);

  @override
  State<ResturantDetail> createState() => _ResturantDetailState();
}

class _ResturantDetailState extends State<ResturantDetail> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _adsressController = TextEditingController();
  TextEditingController _gstController = TextEditingController();
  TextEditingController _cgstController = TextEditingController();
  TextEditingController _sgstController = TextEditingController();
  TextEditingController _panController = TextEditingController();


  FilePickerResult? result;
  String? _filePath;
  PlatformFile? pickedfile;
  bool isLoding = false;
  File? fileToDisplay;


  void pickFile() async{
    try{
      setState(() {
        isLoding = true;
      });
      result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if(result != null){
        pickedfile = result!.files.first;
        fileToDisplay = File(pickedfile!.path.toString());
        _filePath = pickedfile!.path.toString();
      }
      setState(() {
        isLoding = false;
      });
    }catch(e){
      print(e);
    }
  }
  void FormData() {
    if (widget.resturant != null) {
      _nameController.text = widget.resturant!.RestaurantName.toString();
      _phoneController.text = widget.resturant!.PhoneNo.toString();
      x = widget.resturant!;
    }
  }
  Resturantcurdmap _resturanttablemap = Resturantcurdmap();
  Resturant x = Resturant.empty();
  void save() {
    x.RestaurantName = _nameController.text;
    x.PhoneNo = _phoneController.text;
    if (widget.resturant == null) {
      add();
      return;
    }
    else {
      update();
    }
  }
  void update() async {
    try {
      if (await _resturanttablemap.update(x)) {
        showmessage('Resturant updated');
        return;
      }
      showmessage('No Resturant changed');
    } catch (error) {
      print(error);
      showmessage('Error');
    }
  }

  void add() async {
    try {
      x.RestaurantName = _nameController.text;
      x.PhoneNo = _phoneController.text;
      x.Email = _emailController.text;
      x.Address = _adsressController.text;
      x.GSTNumber = _gstController.text;
      x.CGST = _cgstController.text;
      x.SGST = _sgstController.text;
      x.PanNumber = _panController.text;
      x.Image = _filePath;
      Resturant data = await _resturanttablemap.add(x);
      x.RestaurantID = data.RestaurantID;
      showmessage('Resturant added successful');
      setState(() {});
    } catch (error) {
      print(error);
      showmessage('Error Saving Resturant');
    }
  }

  void showmessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
  @override
  void initState() {
    super.initState();
    FormData();
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
            drawer: const CustomDrawer(),
            appBar: appbar,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: height/60),
                  Center(
                    child: Text(
                      widget.resturant == null ? 'Add Resturant' : 'Edit Resturant',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFFEF8739),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: height/60),
                  GestureDetector(
                    onTap:() async {
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
                        pickFile();
                      } else {
                        showmessage('This permission is required');
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: width/5,
                      child: fileToDisplay != null || _filePath != null ?
                      ClipOval(
                        child: Image.file(
                          File(_filePath!),
                          fit: BoxFit.cover,
                          width: width/2,
                          height: height/5,
                        ),
                      ) :
                      Container(
                          decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.black),
                            borderRadius: BorderRadius.all(Radius.circular(200)),),
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            size: 60,
                          ),
                          width: width/2,
                          height: height/5
                      ),
                    ),
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(30, 30, 30, 10),
                            child: TextFormField(
                              controller: _nameController,
                              validator: (value) {
                                if (value == null) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Resturant Name',
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
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _phoneController,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Phone Number',
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
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 10),
                            child: TextFormField(
                              controller: _emailController,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Email',
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
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 10),
                            child: TextFormField(
                              controller: _adsressController,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Address',
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
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 10),
                            child: TextFormField(
                              controller: _gstController,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'GST Number',
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
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 10),
                            child: TextFormField(
                              controller: _cgstController,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'CGST',
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
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 10),
                            child: TextFormField(
                              controller: _sgstController,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'SGST',
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
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 10),
                            child: TextFormField(
                              controller: _panController,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Pan Number',
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
                        ],
                      )
                  ),
                  SizedBox(
                    height: height/15,
                    width: width/2,
                    child: ElevatedButton(
                      child: Text('Save', style: TextStyle(fontSize: 25,color: Colors.green)),
                      onPressed: () {
                        save();
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
            ),
          )
      ),
    );
  }
}
