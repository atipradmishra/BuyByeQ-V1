import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../common/appBar/apbar.dart';
import '../common/drawer/custom_drawer.dart';
import 'package:file_picker/file_picker.dart';
import '../database/catagorymodel.dart';
import '../database/category_curd.dart';
import '../database/item_category_mapping.dart';
import '../database/menumodel.dart';
import '../database/menu_category_curd.dart';
import '../database/menu_curd.dart';

class AddMenu extends StatefulWidget {
  Menu? menus;
  AddMenu({this.menus});

  @override
  State<AddMenu> createState() => _AddMenuState();
}

class _AddMenuState extends State<AddMenu> {
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


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  SingleValueDropDownController _txttype = SingleValueDropDownController();
  TextEditingController _txtitemname = TextEditingController();
  TextEditingController _txtdiscount = TextEditingController();
  TextEditingController _txtprice = TextEditingController();


  Menucurdmap _menutablemap = Menucurdmap();
  Menu menu = Menu.empty();
  MenuCategoryMappingcurdmap _menucategorytablemap = MenuCategoryMappingcurdmap();
  Menu_Category_Mapping _menu_category_mapping = Menu_Category_Mapping.empty();
  Categorycurdmap _categorytablemap = Categorycurdmap();
  MenuCategory menuategory = MenuCategory.empty();
  // Menupricecurdmap _pricetablemap = Menupricecurdmap();
  // Menuprice menuprice = Menuprice.empty();
  // size menusizes = size.empty();
  int? menuitemid;
  void addmenu() async {
    try {
      // menu table data push
      menu.MenuItemName = _txtitemname.text;
      menu.Price = _txtprice.text;
      menu.DiscountPercentage = _txtdiscount.text;
      menu.Type = _txttype.dropDownValue?.value;
      menu.ImagePath = _filePath;
      Menu data = await _menutablemap.add(menu);
      menu.MenuItemId = data.MenuItemId;
      menuitemid = data.MenuItemId;
      // menu_category_data_push
      _menu_category_mapping.MenuItemId = menu.MenuItemId.toString();
      _menu_category_mapping.MenuCategoryId = categoryValue;
      Menu_Category_Mapping data_1 = await _menucategorytablemap.add(_menu_category_mapping);
      _menu_category_mapping.ItemCategoryMappingId = data_1.ItemCategoryMappingId;
      // for (int i = 0; i<menusize.length; i++){
      //   // menu price data push
      //   menuprice.MenuId = menu.MenuItemId.toString();
      //   menuprice.SizeId = menusize[i].MenuSizeId.toString();
      //   menuprice.MenuPrice = listController[i].text;
      //   Menuprice data_2 = await _pricetablemap.add(menuprice);
      //   menuprice.MenuPriceId = data_2.MenuPriceId;
      // }

      showmessage('Menu added successful');
      setState(() {});
    } catch (error) {
      print(error);
      showmessage('Error Saving Menu');
    }
  }

  List<MenuCategory> category = [];
  String? categoryValue;
  void selectallcategories() async {
    try {
      List<MenuCategory> data = await _categorytablemap.selectall();
      category.clear();
      category.addAll(data);
      setState(() {});
    } catch (error) {
      showmessage('Error fetching Categories');
    }
  }

  // final List<TextEditingController> listController = [TextEditingController()];
  // List<size> menusize = [];
  // Sizecurdmap _sizetablemap = Sizecurdmap();
  // void selectallsizes() async {
  //   try {
  //     List<size> data = await _sizetablemap.selectall();
  //     menusize.clear();
  //     menusize.addAll(data);
  //     setState(() {});
  //   } catch (error) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error fetching sizes')));
  //   }
  // }

  String title = "Add Menu";
  void FormData() {
    if (widget.menus != null) {
      title = "Update Menu";
      _txtitemname.text = widget.menus!.MenuItemName.toString();
      _txtdiscount.text = widget.menus!.DiscountPercentage.toString();
      _txtprice.text = widget.menus!.Price.toString();
      _filePath = widget.menus!.ImagePath.toString();
      menu = widget.menus!;
    }
  }

  void save() {
    menu.MenuItemName = _txtitemname.text;
    menu.DiscountPercentage = _txtdiscount.text;
    menu.Price = _txtprice.text;
    menu.Type = _txttype.dropDownValue!.value;
    menu.ImagePath = _filePath;
    if (menu.MenuItemId == null) {
        addmenu();
        return;
    }
    else {
      updatemenu();
    }
  }

  void updatemenu() async {
    try {
      if (await _menutablemap.update(menu) ) {
        _menucategorytablemap.Update(widget.menus!.MenuItemId!,categoryValue.toString());
          showmessage('Menu updated');
          return;
      }
      showmessage('No Menu changed');
    } catch (error) {
      print(error);
      showmessage('Error');
    }
  }

  void showmessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  void initState() {
    _txttype = SingleValueDropDownController();
    selectallcategories();
    FormData();
    // selectallsizes();
    super.initState();
  }


  @override
  void dispose() {
    _txttype.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    List<String> categoryid = [];
    List<String> categoryname = [];
    for (var a in category){
      var b = a.MenuCategoryName.toString();
      var c = a.MenuCategoryId;
      categoryname.addAll([b]);
      categoryid.addAll([c.toString()]);
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
          child: Scaffold(
            appBar: appbar,
            drawer: CustomDrawer(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: height/60),
                  Center(
                    child: Text(
                      title,
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
                          Permission.storage,
                          Permission.sms
                        ].request();
                      } else {
                        statusess = await [
                          Permission.photos,
                          Permission.sms
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
                        await  openAppSettings();
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
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(30, 30, 30, 10),
                    child: TextFormField(
                      controller: _txtitemname,
                      obscureText: false,
                      decoration: InputDecoration(
                        hintText: 'Item name',
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
                      controller: _txtdiscount,
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'DiscountPercentage',
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
                      controller: _txtprice,
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Price',
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
                    child: Container(
                      width: width/1.15,
                      height: height/15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          )
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropDownTextField(
                          dropDownIconProperty: IconProperty(
                              color: Colors.black,
                              size: 50
                          ),
                          // initialValue: "name4",
                          controller: _txttype,
                          clearOption: true,
                          // enableSearch: true,
                          dropdownColor: Colors.orange[300],
                          textFieldDecoration: InputDecoration(
                            hintText: 'Type',
                          ),
                          validator: (value) {
                            if (value == null) {
                              return "Required field";
                            } else {
                              return null;
                            }
                          },
                          dropDownItemCount: 2,

                          dropDownList: [
                            DropDownValueModel(name: 'Veg', value: "veg"),
                            DropDownValueModel(name: 'Non-Veg',value: "NonVeg"),
                          ],
                          onChanged: (val) {},
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(30, 10, 30, 20),
                    child: Container(
                      width: width/1.18,
                      height: height/15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          )
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          dropdownColor: Colors.orange,
                          value: categoryValue,
                          onChanged: (String? value) {
                            setState(() {
                              categoryValue = value;
                            });
                          },
                          hint: Text('Select Category', style: TextStyle(fontSize: 15)),
                          items:
                          categoryname.map((String value) {
                            int b = categoryname.indexOf(value);
                            return DropdownMenuItem<String>(
                                value: categoryid[b],
                                child: Text(value)
                            );
                          }).toList(),
                          iconSize: 50,
                          iconEnabledColor: Colors.black,
                          isExpanded: true,
                        ),
                      ),
                    ),
                  ),
                  // ListView.builder(
                  //   shrinkWrap: true,
                  //   itemCount: menusize.length,
                  //     itemBuilder:(context, index) {
                  //     return _field(index);
                  //     }
                  // ),
                  SizedBox(
                    height: height/15,
                    width: width/2,
                    child: ElevatedButton(
                      child: Text('Save', style: TextStyle(fontSize: 25,color: Colors.green)),
                      onPressed: () async {
                        if (_txtitemname.text == null || _txtitemname.text ==''){
                          showmessage('Item Name is Required');
                        } else if (_txtprice.text == null || _txtprice.text ==''){
                          showmessage('Item Price is Required');
                        } else if (_txttype.dropDownValue?.value == null || _txttype.dropDownValue?.value ==''){
                          showmessage('Select Menu Type');
                        } else if (categoryValue == null){
                          showmessage('Select Category');
                        }
                        // else if (_filePath == null){
                        //   showmessage('Select Menu Picture to Upload');
                        // }
                        else {
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
            ),
          )
      ),
    );
  }
}
