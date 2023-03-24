import 'dart:math';
import 'package:buybyeq/screens/pagesnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../database/connections.dart';

class LoginScreen extends StatelessWidget {
  Duration get loginTime => const Duration(milliseconds: 1000);

  Future<String?> _authUser(LoginData data) async {
    final db = await ConnectionSQLiteService.instance.db;
    final result = await db.query('User',
        where: 'Email = ? and Password = ?', whereArgs: [data.name, data.password]);
    if (result.length == 0) {
      return 'User not found or password does not match';
    }
    return null;
  }

  Future<String?> _signupUser(SignupData data) async {
    final db = await ConnectionSQLiteService.instance.db;
    final result = await db.insert('User', {
      'UserFirstName': data.name,
      'UserName': data.name,
      'Email': data.name,
      'Password': data.password,
      'IsActive': 1
    });
    return null;
  }
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
  }


  Future<String> _recoverPassword(String email) async {
    final database = await _getDatabase();
    final result = await database.query('User', where: 'Email = ?', whereArgs: [email]);
    if (result.length == 0) {
      return 'User not found';
    }
    final password = _generatePassword();
    await database.update(
      'User',
      {'Password': password},
      where: 'Email = ?',
      whereArgs: [email],
    );
    return "Use  $password as your password";
  }

  String _generatePassword() {
    final random = Random();
    final passwordDigits = List.generate(4, (_) => random.nextInt(10));
    return passwordDigits.join();
  }



  Future<Database> _getDatabase() async {
    return await ConnectionSQLiteService.instance.db;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      messages:LoginMessages( ) ,
        theme: LoginTheme(primaryColor: Colors.orange),
        title: 'BuyByeQ',
        logo: const AssetImage("assets/buybyeq_logo.png"),
      onLogin: _authUser,
      onSignup: _signupUser,
      loginAfterSignUp: false,
      onSubmitAnimationCompleted: () async {
        await _saveSession();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LetsNavi(),
        ));
      },

      onRecoverPassword: _recoverPassword,

    );
  }
}
