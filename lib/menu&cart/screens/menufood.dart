import 'dart:io';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../common/drawer/custom_drawer.dart';
import '../../common/prodcateg/categs.dart';
import '../cartprovider/cartprovider.dart';
import '../database/cartdbhelper.dart';
import '../database/menudbhelper.dart';
import '../models/cartmodel.dart';
import '../models/item_model.dart';
import 'package:flutter/material.dart';

class ShoppingMenu extends StatefulWidget {
  const ShoppingMenu({Key? key}) : super(key: key);

  @override
  State<ShoppingMenu> createState() => _ShoppingMenuState();
}

class _ShoppingMenuState extends State<ShoppingMenu> {
  int _presscount = 0;
  void _onPressed() {
    setState(() {
      _presscount++;
    });
    if (_presscount > 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Item already added to cart!!'),
      ));
    }
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _searchQuery = '';
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Widget Items(String name, String category, imgUrl, String price, int index) {
    final cart = Provider.of<CartProvider>(context);
    void saveData(int index) async {
      DatabaseHelper dbmenu = DatabaseHelper();
      CartDBHelper dbHelper = CartDBHelper();
      List<Item> foodItems = await dbmenu.getFoodItems(_searchQuery);
      Item item = foodItems[index];
      dbHelper
          .insert(
        Cart(
          productId: index,
          menuId: await dbmenu.getMenuItemId(item.name),
          productName: item.name,
          productPrice: item.price.toDouble(),
          quantity: ValueNotifier(1),
          unitTag: item.unit,
          image: item.image,
        ),
      )
          .then((value) {
        cart.addTotalPrice(item.price.toDouble());
        cart.addCounter();
        print('Product Added to cart');
      }).onError((error, stackTrace) {
        print(error.toString());
      });
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        // this widget will make your container clickable
        onTap: () {},
        child: Container(
          width: 180.0,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.file(
                File(imgUrl),
                width: 190.0,
                height: 160.0,
                alignment: Alignment.center,
              ),
              Text(
                name,
                style: const TextStyle(fontSize: 16.0, color: Colors.blue),
              ),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey,
                ),
              ),
              Text(
                "₹. $price",
                style: const TextStyle(
                    fontSize: 22.0,
                    color: Color(
                      0xFFFF9900,
                    )),
              ),
              const SizedBox(
                height: 3,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      _onPressed();
                      saveData(index);
                      HapticFeedback.vibrate();
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8)),
                      height: 27,
                      width: 140,
                      child: const Center(
                          child: Text(
                        'Add to Cart',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const CustomDrawer(),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8, top: 10, bottom: 10, right: 8),
                  child: TextField(
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      contentPadding: const EdgeInsets.all(15.0),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.blue,
                        size: 20,
                      ),
                      hintText: "Search food from menu",
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
                Categories(
                  onCategorySelected: (String) {},
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Menu",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 28.0,
                    ),
                  ),
                ),
                //Now we will add the items list
                SizedBox(
                  width: double.infinity,
                  // this line will make the container take the full width of the device
                  height: 280.0,
                  // when you want to create a list view you should precise the height and width of it's container
                  child: FutureBuilder<List<Item>>(
                    future: _dbHelper.getFoodItems(_searchQuery),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final List<Item> items = snapshot.data!;
                        if (items.isEmpty) {
                          return Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Image(
                                  height: MediaQuery.of(context).size.height*0.2,
                                  width: MediaQuery.of(context).size.width*0.4,
                                  image: AssetImage(
                                      "assets/em2.jpg"),
                                ),
                              ),
                              Center(child: Text('No items in menu.',style: TextStyle(color: Colors.red,
                                  fontSize:15,fontWeight: FontWeight.bold),),),
                            ],
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Items(
                              item.name,
                              item.unit,
                              item.image,
                              item.price.toString(),
                              index,
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ),

                const SizedBox(
                  height: 20.0,
                ),

                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Popular Foods",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  // this line will make the container take the full width of the device
                  height: 280.0,
                  // when you want to create a list view you should precise the height and width of it's container
                  child: FutureBuilder<List<Item>>(
                    future: _dbHelper.getFoodItems(_searchQuery),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final List<Item> items = snapshot.data!;
                        if (items.isEmpty) {
                          return Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Image(
                                  height: MediaQuery.of(context).size.height*0.2,
                                  width: MediaQuery.of(context).size.width*0.4,
                                  image: AssetImage(
                                      "assets/em2.jpg"),
                                ),
                              ),
                              Center(child: Text('No items in menu.',style: TextStyle(color: Colors.red,
                                  fontSize:15,fontWeight: FontWeight.bold),),),
                            ],
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Items(
                              item.name,
                              item.unit,
                              item.image,
                              item.price.toString(),
                              index,
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
