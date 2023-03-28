class Menu_Category_Mapping {
  int? ItemCategoryMappingId;
  String? MenuCategoryId;
  String? MenuItemId;


  Menu_Category_Mapping({
    this.ItemCategoryMappingId,
    required this.MenuCategoryId,
    required this.MenuItemId,
  });

  factory Menu_Category_Mapping.fromSQLite(Map map) {
    return Menu_Category_Mapping(MenuCategoryId: map['MenuCategoryId'], MenuItemId: map['MenuItemId']
    );
  }

  static List<Menu_Category_Mapping> fromSQLiteList(List<Map> listMap) {
    List<Menu_Category_Mapping> x = [];
    for (Map item in listMap) {
      x.add(Menu_Category_Mapping.fromSQLite(item));
    }
    return x;
  }


  factory Menu_Category_Mapping.empty() {
    return Menu_Category_Mapping(MenuCategoryId: '', MenuItemId: '');
  }
}
