import 'package:flutter/material.dart';

import '../../common/appBar/apbar.dart';
import '../../database/connections.dart';
import '../pagesnav.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ConnectionSQLiteService _dbService = ConnectionSQLiteService.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isLoading = false;
  Future<int?> getUI() async {
    final db = await _dbService.db;
    final List<Map<String, dynamic>> users = await db.query(
      'User',
      columns: ['UserId'],
      where: 'IsActive = 1',
      limit: 1,
    );
    if (users.isEmpty) {
      return null; // user not found
    }
    return users[0]['UserId'];
  }

  Future<String?> getEM() async {
    final db = await _dbService.db;
    final List<Map<String, dynamic>> users = await db.query(
      'User',
      columns: ['Email'],
      where: 'IsActive = 1',
      limit: 1,
    );
    if (users.isEmpty) {
      return null; // user not found
    }
    return users[0]['Email'];
  }

  Future<void> _submitForm() async {
    final db = await _dbService.db;
    final String em = _passwordController.text.trim();
    var id = await getUI();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      if (em.isNotEmpty) {
        await db.update(
          'User',
          {'Password': em},
          where: 'UserId = ?',
          whereArgs: [id],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:appbar,
      body: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Center(
            child: Text(
              'Change Password',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Color(0xFFEF8739),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Fill out all fields correctly to change password',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email address';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter your new password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your new password';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your new password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please confirm your new password';
                        } else if (_passwordController.text != value) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else
                      ElevatedButton(
                        child: Text('Change Password'),
                        onPressed: () async {
                          var email=await getEM();
                          if(_emailController.text==email&&_passwordController.text==_confirmPasswordController.text) {
                          _submitForm;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password Changed Successfully...',
                                style: TextStyle(color: Colors.black),
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LetsNavi(),
                              ));
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Wrong Details, Please Check...',
                                  style: TextStyle(color: Colors.black),
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 1),
                              ),
                            );

                          }

                        }
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
