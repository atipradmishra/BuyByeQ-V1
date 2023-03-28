import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../../common/appBar/apbar.dart';
import '../../database/connections.dart';


class QR extends StatelessWidget {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  final Image image;
   QR({ Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {

      return Scaffold(
        appBar: appbar,
        body:
        Center(child: image),
    );
  }
}

Future<void> createDatabase() async {
  final database = await ConnectionSQLiteService.instance.db;
  // Check if the table exists, and create it if it doesn't.
  final List<Map<String, dynamic>> tables = await database.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='QRTable'",
  );

}

Future<String?> getImage() async {
  // Get the image from the gallery.
  final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
  if (pickedFile == null) {
    return null;
  }
  // Get the application documents directory.
  final Directory appDir = await getApplicationDocumentsDirectory();
  // Create a new file in the documents directory with a unique name.
  final String fileName = basename(pickedFile.path);
  final File newImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
  // Save the file path as a string in sqflite.
  final Database database = await openDatabase(join(await getDatabasesPath(), 'buybyeq.db'));
  final List<Map<String, dynamic>> maps = await database.query('QRTable');
  if (maps.length >= 2) {
    return null;
  }
  final int id = await database.insert('QRTable', {'image_path': newImage.path});
  return newImage.path;
}


Future<List<String>> getAllImages() async {
  final Database database =
  await openDatabase(join(await getDatabasesPath(), 'buybyeq.db'));
  final List<Map<String, dynamic>> maps = await database.query('QRTable');
  return List.generate(maps.length, (i) => maps[i]['image_path'] as String);
}


Future<Image> loadImage(String imagePath) async {
  // Use the path string to load the image.
  final File imageFile = File(imagePath);
  final Uint8List imageBytes = await imageFile.readAsBytes();
  final Image imageWidget = Image.memory(imageBytes);
  return imageWidget;
}
Future<void> deleteImage(String id) async {
  final Database database =
  await openDatabase(join(await getDatabasesPath(), 'buybyeq.db'));
  await database.delete('qrtable', where: 'id = ?', whereArgs: [id]);
}
