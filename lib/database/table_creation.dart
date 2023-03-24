import 'package:buybyeq/database/resturantdetail.dart';
import 'package:buybyeq/database/rolemodel.dart';
import 'package:buybyeq/database/usemodel.dart';
import 'catagorymodel.dart';
import 'item_category_mapping.dart';
import 'menumodel.dart';

class UserTableCreate {
  static const CREATE_TABLE = '''
        CREATE TABLE User (
          UserId INTEGER PRIMARY KEY AUTOINCREMENT,
          UserFirstName VARCHAR(100) ,
          UserLastName VARCHAR(100) ,
          UserName VARCHAR(100) ,
          Gender VARCHAR(10) ,
          Email VARCHAR(50) ,
          PhoneNo VARCHAR(10) ,
          Address TEXT ,
          StreetNo VARCHAR(100) ,
          ZipCode VARCHAR(10) ,
          LoginID VARCHAR(50),
          Password VARCHAR(30) ,
          ImagePath TEXT,
          IsActive BIT ,
          UpdatedOn TIMESTAMP
        )
        ''';

  static String selectallusers() {
    return 'select * from User;';
  }

  static String adduser(User x) {
    return '''
    insert into User (UserFirstName,UserLastName,UserName,Gender,Email,PhoneNo,Address,StreetNo,ZipCode,LoginID,Password,ImagePath,UpdatedOn)
    values ('${x.UserFirstName}',
            '${x.UserLastName}',
            '${x.UserName}',
            '${x.Gender}',
            '${x.Email}',
            '${x.PhoneNo}',
            '${x.Address}',
            '${x.StreetNo}',
            '${x.ZipCode}',
            '${x.LoginID}',
            '${x.Password}',
            '${x.ImagePath}',
            '${x.UpdatedOn}'
    );
    ''';
  }

  static String updateuser(User x) {
    return '''
    UPDATE User
    SET UserFirstName = '${x.UserFirstName}',
    UserLastNam = '${x.UserLastName}'
    WHERE UserId = ${x.UserId};
    ''';
  }
}

class MenuCategoryTableCreate {
  static final CREATE_TABLE = '''
        CREATE TABLE MenuCategory (
          MenuCategoryId INTEGER PRIMARY KEY AUTOINCREMENT,
          MenuCategoryName VARCHAR(100) ,
          Description TEXT ,
          IsActive BIT,
          UpdatedBy INTEGER,
          UpdatedOn TIMESTAMP,
          FOREIGN KEY(UpdatedBy) REFERENCES User(UserId)
        )
        ''';

  static String selectallcatagorys() {
    return 'select * from MenuCategory;';
  }

  static String addcategory(MenuCategory x) {
    return '''
    insert into MenuCategory (MenuCategoryName,Description)
    values ('${x.MenuCategoryName}',
            '${x.Description}'
    );
    ''';
  }

  static String updatecategory(MenuCategory x) {
    return '''
    UPDATE MenuCategory
    SET MenuCategoryName = '${x.MenuCategoryName}',
    Description = '${x.Description}'
    WHERE MenuCategoryId = ${x.MenuCategoryId};
    ''';
  }
}

class MenuItemTableCreate {
  static final CREATE_TABLE = '''
        CREATE TABLE MenuItem (
          MenuItemId INTEGER PRIMARY KEY AUTOINCREMENT,
          MenuItemName VARCHAR(100),
          Description TEXT,
          Type VARCHAR(20),
          DiscountPercentage REAL,
          Price REAL,
          ImagePath TEXT,
          IsActive BIT ,
          UpdatedBy INTEGER,
          UpdatedOn TIMESTAMP,
          FOREIGN KEY(UpdatedBy) REFERENCES User(UserId)
          )
        ''';
  static String selectallmenus() {
    return 'select * from MenuItem;';
  }

  static String addmenu(Menu x) {
    return '''
    insert into MenuItem (MenuItemName,Description,Type,DiscountPercentage,Price,ImagePath,IsActive,UpdatedBy,UpdatedOn)
    values ('${x.MenuItemName}',
            '${x.Description}',
            '${x.Type}',
            '${x.DiscountPercentage}',
            '${x.Price}',
            '${x.ImagePath}',
            '${x.IsActive}',
            '${x.UpdatedBy}',
            '${x.UpdatedOn}'
    );
    ''';
  }

  static String updatemenu(Menu x) {
    return '''
    UPDATE MenuItem
    SET MenuItemName = '${x.MenuItemName}',
    DiscountPercentage = '${x.DiscountPercentage}',
    Price = '${x.Price}',
    Type = '${x.Type}',
    ImagePath = '${x.ImagePath}'
    WHERE MenuItemId = ${x.MenuItemId};
    ''';
  }
}

class ItemCategoryMappingTableCreate {
  static final CREATE_TABLE = '''
        CREATE TABLE ItemCategoryMapping (
          ItemCategoryMappingId INTEGER PRIMARY KEY AUTOINCREMENT,
          MenuCategoryId INTEGER,
          MenuItemId INTEGER,
          FOREIGN KEY(MenuCategoryId) REFERENCES MenuCategory(MenuCategoryId),
          FOREIGN KEY(MenuItemId) REFERENCES MenuItem(MenuItemId)
          )
        ''';

  static String addmaping(Menu_Category_Mapping x) {
    return '''
    insert into ItemCategoryMapping (MenuCategoryId,MenuItemId)
    values ('${x.MenuCategoryId}',
            '${x.MenuItemId}'
    );
    ''';
  }

}

class OrderTableCreate {
  static const CREATE_TABLE = '''
        CREATE TABLE CartOrder (
          OrderId INTEGER PRIMARY KEY AUTOINCREMENT,
          OrderDate TIMESTAMP,
          OrderTime TIMESTAMP,
          OrderType VARCHAR(100),
          TableNo VARCHAR(100),
          TokenNo VARCHAR(100),
          OrderAmount DECIMAL,
          DiscountPCT INTEGER,
          CGST_PCT INTEGER,
          IGST_PCT INTEGER,
          ParcelCharges DECIMAL,
          DeliveryCharges DECIMAL,
          OtherCharges DECIMAL,
          RoundOffAmount DECIMAL,
          TotalPaybleAmount NUMERIC,
          AmountDue DECIMAL,
          PaymentMode VARCHAR(100),
          PaymentInCash DECIMAL,
          PaymentInCard INTEGER,
          CardRefNo VARCHAR(100),
          PaymentInUPI DECIMAL,
          UPIRefNo VARCHAR(100),
          CustomerID INTEGER,
          HeadCount INTEGER,
          WaiterID INTEGER,
          OrderStatus VARCHAR,
          PaymentStatus VARCHAR,
          UpdatedBy INTEGER,
          UpdatedOn TIMESTAMP,
          FOREIGN KEY(UpdatedBy) REFERENCES User(UserId),
          FOREIGN KEY(CustomerID) REFERENCES Customer(CustomerID),
          FOREIGN KEY(WaiterID) REFERENCES Role(RoleId)
          )
        ''';
}

class OrderDetailTableCreate {
  static const CREATE_TABLE = '''
        CREATE TABLE OrderDetail (
          OrderDetailId INTEGER PRIMARY KEY AUTOINCREMENT,
          OrderId INTEGER,
          MenuItemId INTEGER,
          Quantity VARCHAR(100),
          Price VARCHAR(100),
          UpdatedBy INTEGER, 
          UpdatedOn TIMESTAMP,
          FOREIGN KEY(OrderId) REFERENCES CartOrder(OrderId),
          FOREIGN KEY(MenuItemId) REFERENCES MenuItem(MenuItemId),
          FOREIGN KEY(UpdatedBy) REFERENCES User(UserId)
          )
        ''';
}

class PaymentTableCreate {
  static const CREATE_TABLE = '''
        CREATE TABLE Payment (
          Payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
          Customer_id INTEGER,
          Order_id INTEGER,
          Payment_date Datetime,
          Payment_time VARCHAR(100),
          Amount VARCHAR(100),
          Payment_type VARCHAR(100),
          Payment_status VARCHAR(100),
          UpdatedBy INTEGER,
          UpdatedOn TIMESTAMP,
          FOREIGN KEY(Customer_id) REFERENCES Customer(CustomerID),
          FOREIGN KEY(Order_id) REFERENCES MenuItem(MenuItemId),
          FOREIGN KEY(UpdatedBy) REFERENCES User(UserId)
          )
        ''';
}

class RoleTableCreate {
  static const CREATE_TABLE = '''
        CREATE TABLE Role (
          RoleId INTEGER PRIMARY KEY AUTOINCREMENT,
          RoleName VARCHAR(100)
          )
        ''';

  static String selectallroles() {
    return 'select * from Role;';
  }

  static String addrole(Role x) {
    return '''
    insert into Role (RoleName)
    values (
    '${x.RoleName}'
    );
    ''';
  }

  static String updaterole(Role x) {
    return '''
    UPDATE Role
    SET RoleName = '${x.RoleName}'
    WHERE RoleId = ${x.RoleId};
    ''';
  }
}

class UserRoleMappingTableCreate {
  static const CREATE_TABLE = '''
        CREATE TABLE UserRoleMapping (
          UserRoleMappingId INTEGER PRIMARY KEY AUTOINCREMENT,
          UserId INTEGER,
          RoleId INTEGER,
          FOREIGN KEY(UserId) REFERENCES Customer(CustomerID),
          FOREIGN KEY(RoleId) REFERENCES Role(RoleId)
          )
        ''';
}

class RestaurantTableCreate {
  static const CREATE_TABLE = '''
        CREATE TABLE Restaurant (
          RestaurantID INTEGER PRIMARY KEY AUTOINCREMENT,
          RestaurantName VARCHAR(100),
          PhoneNo VARCHAR(12),
          Email VARCHAR(100),
          Address TEXT,
          CityID INTEGER,
          StateID INTEGER,
          RestaurantCode VARCHAR(50),
          AdminUserID VARCHAR(50),
          Password VARCHAR(50),
          GSTNumber VARCHAR(100),
          CGST VARCHAR(100),
          SGST VARCHAR(100),
          PanNumber VARCHAR(100),
          RestaurantType VARCHAR(100),
          Image TEXT,
          IsActive BIT,
          UpdatedBy INTEGER,
          UpdatedOn TIMESTAMP,
          FOREIGN KEY(UpdatedBy) REFERENCES User(UserId)
          )
        ''';
  static String addresturant(Resturant x) {
    return '''
    insert into Restaurant (RestaurantName,PhoneNo,Email,Address,GSTNumber,CGST,SGST,PanNumber,Image)
    values ('${x.RestaurantName}',
            '${x.PhoneNo}',
            '${x.Email}',
            '${x.Address}',
            '${x.GSTNumber}',
            '${x.CGST}',
            '${x.SGST}',
            '${x.PanNumber}',
            '${x.Image}'
    );
    ''';
  }

  static String updateresturant(Resturant x) {
    return '''
    update Restaurant
    set RestaurantName = '${x.RestaurantName}',
    PhoneNo = '${x.PhoneNo}',
    Email = '${x.Email}',
    Address = '${x.Address}',
    GSTNumber = '${x.GSTNumber}',
    CGST = '${x.CGST}',
    SGST = '${x.SGST}',
    PanNumber = '${x.PanNumber}',
    Image = '${x.Image}'
    where RestaurantID = ${x.RestaurantID};
    ''';
  }
}

class QRTableCreate{
  static const CREATE_TABLE= '''
        CREATE TABLE qrtable (
          id INTEGER PRIMARY KEY,
          image_path TEXT
        )
      ''';
}

class CustomerTableCreate {
  static const CREATE_TABLE = '''
        CREATE TABLE CustomerTable (
          CustomerID INTEGER PRIMARY KEY AUTOINCREMENT,
          FirstName VARCHAR(100),
          LastName VARCHAR(100),
          Gender VARCHAR(10),
          Email VARCHAR(50),
          PhoneNo VARCHAR(12),
          Address TEXT,
          DOB DATETIME,
          DOA DATETIME,
          IsActive BIT,
          UpdatedBy INTEGER,
          UpdatedOn TIMESTAMP,
          FOREIGN KEY(UpdatedBy) REFERENCES User(UserId)
          )
        ''';
}


