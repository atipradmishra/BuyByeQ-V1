import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common/appBar/apbar.dart';
import '../common/drawer/custom_drawer.dart';
import '../database/catagorymodel.dart';
import '../database/category_curd.dart';
import 'addcategorypage.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {


  @override


  // This function is called whenever the text field changes
  // void _runFilter(String enteredKeyword) {
  //   List<Map<String, dynamic>> results = [];
  //   if (enteredKeyword.isEmpty) {
  //     // if the search field is empty or only contains white-space, we'll display all users
  //     results = _allUsers;
  //   } else {
  //     results = _allUsers
  //         .where((user) =>
  //         user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
  //         .toList();
  //     // we use the toLowerCase() method to make it case-insensitive
  //   }
  //
  // }

  List<MenuCategory> category = [];
  Categorycurdmap _categorytablemap = Categorycurdmap();

  void selectallcategories() async {
    try {
      List<MenuCategory> data = await _categorytablemap.selectall();
      category.clear();
      category.addAll(data);
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching Categories')));
    }
  }

  // void updateuser() async {
  //   try {
  //     if (await  _categorytablemap.update(category)) {
  //       showmessage('Category updated');
  //       return;
  //     }
  //     showmessage('No Category changed');
  //   } catch (error) {
  //     print(error);
  //     showmessage('Error');
  //   }
  // }

  void showmessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }



  @override
  void initState() {
    selectallcategories();
    super.initState();
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
          appBar: appbar,
          drawer: CustomDrawer(),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                  child: Text(
                    'Category',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFFEF8739),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  // onChanged: (value) => _runFilter(value),
                  decoration: const InputDecoration(
                      labelText: 'Search', suffixIcon: Icon(Icons.search)),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  child: Text('Add Category'),
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCategory(),
                        )).then((value) => selectallcategories());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent[100],
                    side: BorderSide(
                        width: 2, color: Color.fromRGBO(25, 153, 0, 1)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                Expanded(
                  child: category.isNotEmpty
                      ? ListView.builder(
                    itemCount: category.length,
                    itemBuilder: (context, index) => Card(
                        key: ValueKey(category[index].MenuCategoryId),
                        color: Colors.grey,
                        elevation: 10,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                              child: Container(
                                height: height/12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12,
                                      color: Color(0x34000000),
                                      offset: Offset(-2, 5),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(8, 8, 12, 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: 4,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrangeAccent,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                                child: Text(
                                                  category[index].MenuCategoryName.toString(),
                                                  maxLines: 1,
                                                  style:
                                                  TextStyle(
                                                    color: Color(0xFF101213),
                                                    fontSize: ScreenUtil().setSp(20),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            IconButton(
                                                onPressed: (){
                                                  showDialog(context: context,barrierDismissible: false, builder: (BuildContext context){
                                                    return AlertDialog(
                                                      title: Text('Confirm'),
                                                      content: Text('Are you sure you want to delete ${category[index].MenuCategoryName}?',style: TextStyle(fontSize: ScreenUtil().setSp(20))),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            await _categorytablemap.deleteItem(category[index].MenuCategoryId ?? 0);
                                                            Navigator.pop(context);
                                                            ScaffoldMessenger.of(context)
                                                                .showSnackBar(SnackBar(content: Text('Category Deleted Successfully')));
                                                          },
                                                          child: Text('Delete'),
                                                        ),
                                                      ],
                                                    );
                                                  }).then((value) => selectallcategories());
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  size: 25,
                                                  color: Colors.black,
                                                )
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                                    child: IconButton(
                                                        onPressed: () async {
                                                          await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => AddCategory(
                                                                  categories : category[index],
                                                                ),
                                                              )).then((value) => selectallcategories());
                                                        },
                                                        icon: Icon(
                                                          Icons.edit,
                                                          size: 25,
                                                          color: Colors.black,
                                                        )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                    ),
                  )
                      : const Text(
                    'No Category found',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}