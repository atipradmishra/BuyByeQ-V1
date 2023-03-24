class Menu {
  int? MenuItemId;
  String? MenuItemName;
  String? Description;
  String? Type;
  String? DiscountPercentage;
  String? Price;
  String? ImagePath;
  String? IsActive;
  String? UpdatedBy;
  String? UpdatedOn;


  Menu({
    required this.MenuItemId,
    required this.MenuItemName,
    required this.Description,
    required this.Type,
    required this.DiscountPercentage,
    required this.Price,
    required this.ImagePath,
    required this.IsActive,
    required this.UpdatedBy,
    required this.UpdatedOn,
  });

  factory Menu.fromSQLite(Map map) {
    return Menu(MenuItemId: map['MenuItemId'],
        MenuItemName: map['MenuItemName'],
        Description: map['Description'],
        Type: map['Type'],
        DiscountPercentage: map['DiscountPercentage'].toString(),
        Price: map['Price'].toString(),
        ImagePath: map['ImagePath'],
        IsActive: map['IsActive'],
        UpdatedBy:map['UpdatedBy'],
        UpdatedOn: map['UpdatedOn']
    );
  }

  static List<Menu> fromSQLiteList(List<Map> listMap) {
    List<Menu> menus = [];
    for (Map item in listMap) {
      menus.add(Menu.fromSQLite(item));
    }
    return menus;
  }


  factory Menu.empty() {
    return Menu(MenuItemName: '', Description: '', Type: '', DiscountPercentage: '', IsActive: '', UpdatedBy: '', UpdatedOn: '', ImagePath: '', Price: '', MenuItemId: null);
  }
}


