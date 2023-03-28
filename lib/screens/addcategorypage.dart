import 'package:flutter/material.dart';
import '../common/appBar/apbar.dart';
import '../common/drawer/custom_drawer.dart';
import '../database/catagorymodel.dart';
import '../database/category_curd.dart';


class AddCategory extends StatefulWidget {
  MenuCategory? categories;
  AddCategory({this.categories});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _txtitemname = TextEditingController();
  TextEditingController _txtdescription = TextEditingController();
  Categorycurdmap _categorytablemap = Categorycurdmap();
  MenuCategory category = MenuCategory.empty();

  String title = "Add Category";
  void FormData() {
    if (widget.categories != null) {
      title = "Update Category";
      _txtitemname.text = widget.categories!.MenuCategoryName.toString();
      _txtdescription.text = widget.categories!.Description.toString();
      category = widget.categories!;
    }
  }

  void save() {
    category.MenuCategoryName = _txtitemname.text;
    category.Description = _txtdescription.text;
    if (category.MenuCategoryId == null) {
      addcategory();
      return;
    }
    else {
      updatecategory();
    }
  }

  void updatecategory() async {
    try {
      if (await _categorytablemap.update(category)) {
        showmessage('Category updated');
        return;
      }
      showmessage('No Category changed');
    } catch (error) {
      print(error);
      showmessage('Error');
    }
  }

  void addcategory() async {
    try {
      category.MenuCategoryName = _txtitemname.text;
      category.Description = _txtdescription.text;
      MenuCategory data = await _categorytablemap.add(category);
      category.MenuCategoryId = data.MenuCategoryId;
      showmessage('Category added successful');
      setState(() {});
    } catch (error) {
      print(error);
      showmessage('Error Saving Category');
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
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(30, 30, 30, 10),
                    child: TextFormField(
                      controller: _txtitemname,
                      obscureText: false,
                      decoration: InputDecoration(
                        hintText: 'Category name',
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
                      controller: _txtdescription,
                      obscureText: false,
                      maxLines: 5,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Description',
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
                    width: width/2,
                    child: ElevatedButton(
                      child: Text('Save', style: TextStyle(fontSize: 25,color: Colors.green),),
                      onPressed: () async {
                        var a = _txtitemname.text;
                        if (a == null || a ==''){
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Caregory Name is Required')));
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
            ),
          )
      ),
    );
  }
}
