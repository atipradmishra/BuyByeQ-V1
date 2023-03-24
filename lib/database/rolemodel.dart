class Role {
  int? RoleId;
  String? RoleName;


  Role({
    required this.RoleId,
    required this.RoleName
  });

  factory Role.fromSQLite(Map map) {
    return Role(
        RoleId: map['RoleId'],
        RoleName: map['RoleName']
    );
  }

  static List<Role> fromSQLiteList(List<Map> listMap) {
    List<Role> menus = [];
    for (Map item in listMap) {
      menus.add(Role.fromSQLite(item));
    }
    return menus;
  }


  factory Role.empty() {
    return Role(RoleName: '', RoleId: null);
  }
}

