class MenuCategory {
  int? MenuCategoryId;
  String? MenuCategoryName;
  String? Description;


  MenuCategory({
    required this.MenuCategoryId,
    required this.MenuCategoryName,
    required this.Description,
  });

  factory MenuCategory.fromSQLite(Map map) {
    return MenuCategory(MenuCategoryId: map['MenuCategoryId'],MenuCategoryName: map['MenuCategoryName'], Description: map['Description']
    );
  }

  static List<MenuCategory> fromSQLiteList(List<Map> listMap) {
    List<MenuCategory> menus = [];
    for (Map item in listMap) {
      menus.add(MenuCategory.fromSQLite(item));
    }
    return menus;
  }


  factory MenuCategory.empty() {
    return MenuCategory(MenuCategoryId: null, MenuCategoryName: '', Description: '');
  }
}

