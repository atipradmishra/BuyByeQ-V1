class User {
  int? UserId;
  String? UserFirstName;
  String? UserLastName;
  String? UserName;
  String? Gender;
  String? Email;
  String? PhoneNo;
  String? Address;
  String? StreetNo;
  String? ZipCode;
  String? LoginID;
  String? Password;
  String? ImagePath;
  String? UpdatedOn;


  User({
    required this.UserId,
    required this.UserFirstName,
    required this.UserLastName,
    required this.UserName,
    required this.Gender,
    required this.Email,
    required this.PhoneNo,
    required this.Address,
    required this.StreetNo,
    required this.ZipCode,
    required this.LoginID,
    required this.Password,
    required this.ImagePath,
    required this.UpdatedOn,
  });

  factory User.fromSQLite(Map map) {
    return User(
        UserId: map['UserId'],
        UserFirstName: map['UserFirstName'],
        UserLastName: map['UserLastName'],
        UserName: map['UserName'],
        Gender: map['Gender'],
        Email: map['Email'],
        PhoneNo: map['PhoneNo'],
        Address: map['Address'],
        StreetNo: map['StreetNo'],
        ZipCode: map['ZipCode'],
        LoginID: map['LoginID'],
        Password: map['Password'],
        ImagePath: map['ImagePat'],
        UpdatedOn: map['UpdatedOn']
    );
  }

  static List<User> fromSQLiteList(List<Map> listMap) {
    List<User> users = [];
    for (Map item in listMap) {
      users.add(User.fromSQLite(item));
    }
    return users;
  }


  factory User.empty() {
    return User(UserId: null, UserFirstName: '', UserLastName: '', UserName: '', Gender: '', Email: '', PhoneNo: '', Address: '', StreetNo: '', ZipCode: '', LoginID: '', Password: '', UpdatedOn: '', ImagePath: '');
  }
}