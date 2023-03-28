import 'package:flutter/material.dart';
import '../../menu&cart/database/menudbhelper.dart';
import '../../menu&cart/models/item_model.dart';

class Categories extends StatefulWidget {
  final Function (String)?onCategorySelected;

  const Categories({Key? key,required this.onCategorySelected}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}
class _CategoriesState extends State<Categories>{
  final DatabaseHelper _dbHelper=DatabaseHelper();
  String ? _selectedCategory;//category selected by on press on categ
  List <Item> _items=[];//items selected by the filter
  @override


  List<String> category = [];
  @override initState(){
    super.initState();
    getCategoryList();
    _loadItems();
  }
  Future <void> getCategoryList()async{
    List <String> categories=await _dbHelper.getCategories();
    setState((){category=categories;});
  }
  Future <void> _loadItems() async{
    List <Item> items=await _dbHelper.getFoodItems('');
    setState((){
      _items=items;
    });}
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      if (_selectedCategory != null) {
        _items = _items.where((item) => item.unit == _selectedCategory).toList();
      } else {
        _loadItems();
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Categor();
  }



  Widget Categor() {
    return
      SizedBox(
        width: double
            .infinity,
        // this line will make the container take the full width of the device
        height:
        27.0,
        // when you want to create a list view you should precise the height and width of it's container
        child: ListView(
          scrollDirection:
          Axis.horizontal, // this will make the list scroll horizontally
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
               category.map((cat) => TextCateg(cat,_selectedCategory ==cat)).toList(),

            ),
          ],
        ),
      );
  }

  Widget TextCateg(String cat, bool isSelected) {
    return InkWell(
      onTap: () async {
        _onCategorySelected(cat);
        if (widget.onCategorySelected != null) {
          widget.onCategorySelected!(cat);
          List<Item> items = await _dbHelper.getFoodItems(cat);

        }
      },

      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.only(right: 10),
        height: 60,
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrangeAccent : Colors.white60,
          border: isSelected ?Border.all(color: Colors.orange, width: 1):Border.all(color: Colors.green, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            cat,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

}