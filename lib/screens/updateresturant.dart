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

class ResturantDetailUpdate extends StatefulWidget {
  Resturant? resturants;
  ResturantDetailUpdate({this.resturants});

  @override
  State<ResturantDetailUpdate> createState() => _ResturantDetailUpdateState();
}

class _ResturantDetailUpdateState extends State<ResturantDetailUpdate> {
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
    if (widget.resturants != null) {
      _nameController.text = widget.resturants!.RestaurantName.toString();
      _phoneController.text = widget.resturants!.PhoneNo.toString();
      _emailController.text = widget.resturants!.Email.toString();
      _adsressController.text = widget.resturants!.Address.toString();
      _gstController.text = widget.resturants!.GSTNumber.toString();
      _cgstController.text = widget.resturants!.CGST.toString();
      _sgstController.text = widget.resturants!.SGST.toString();
      _panController.text = widget.resturants!.PanNumber.toString();
      _filePath = widget.resturants!.Image.toString();
      x = widget.resturants!;
    }
  }
  Resturantcurdmap _resturanttablemap = Resturantcurdmap();
  Resturant x = Resturant.empty();
  void save() {
    x.RestaurantName = _nameController.text;
    x.PhoneNo = _phoneController.text;
    x.Email = _emailController.text;
    x.Address = _adsressController.text;
    x.GSTNumber = _gstController.text;
    x.CGST = _cgstController.text;
    x.SGST = _sgstController.text;
    x.PanNumber = _panController.text;
    x.Image = _filePath;
    if (widget.resturants == null) {
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
        showmessage('Restaurant updated');
        return;
      }
      showmessage('No Restaurant changed');
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
      showmessage('Restaurant added successful');
      setState(() {});
    } catch (error) {
      print(error);
      showmessage('Error Saving Restaurant');
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
            drawer: CustomDrawer(),
            appBar: appbar,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: height/60),
                  Center(
                    child: Text(
                      widget.resturants == null ? 'Add Restaurant' : 'Edit Restaurant',
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
                            padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Restaurant Name is Required';
                                }
                                return null;
                              },
                              controller: _nameController,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Restaurant Name*',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Phone Number';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              controller: _phoneController,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Phone NUmber*',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(20, 10, 10, 10),
                                  child: TextFormField(
                                    controller: _cgstController,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      hintText: 'CGST',
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
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
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(5, 10, 20, 10),
                                  child: TextFormField(
                                    controller: _sgstController,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      hintText: 'SGST',
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
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
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                            child: TextFormField(
                              controller: _gstController,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'GST Number',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                            child: TextFormField(
                              controller: _panController,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Pan Number',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                            child: TextFormField(
                              controller: _adsressController,
                              autofocus: false,
                              obscureText: false,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Address',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: height/40),
                            child: SizedBox(
                              height: height/15,
                              width: width/2,
                              child: ElevatedButton(
                                child: Text('Save', style: TextStyle(fontSize: 25,color: Colors.green),),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
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
                          ),
                        ],
                      )
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
