class Resturant {
  int? RestaurantID;
  String? RestaurantName;
  String? PhoneNo;
  String? Email;
  String? Address;
  String? GSTNumber;
  String? CGST;
  String? SGST;
  String? PanNumber;
  String? Image;


  Resturant({
    required this.RestaurantID,
    required this.RestaurantName,
    required this.PhoneNo,
    required this.Email,
    required this.Address,
    required this.GSTNumber,
    required this.CGST,
    required this.SGST,
    required this.PanNumber,
    required this.Image,
  });

  factory Resturant.fromSQLite(Map map) {
    return Resturant(
        RestaurantID: map['RestaurantID'],
        RestaurantName: map['RestaurantName'],
        PhoneNo: map['PhoneNo'],
        Email: map['Email'],
        Address: map['Address'],
        GSTNumber: map['GSTNumber'],
        PanNumber: map['PanNumber'],
        Image: map['Image'],
        CGST: map['CGSTNumber'],
        SGST: map['SGSTNumber']
    );
  }

  static List<Resturant> fromSQLiteList(List<Map> listMap) {
    List<Resturant> x = [];
    for (Map item in listMap) {
      x.add(Resturant.fromSQLite(item));
    }
    return x;
  }


  factory Resturant.empty() {
    return Resturant(RestaurantID: null, RestaurantName: '', PhoneNo: '', Email: '', Address: '', GSTNumber: '', PanNumber: '', Image: '', CGST: '', SGST: '');
  }
}

