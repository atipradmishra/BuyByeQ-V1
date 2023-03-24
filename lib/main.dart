import 'package:buybyeq/screens/loginpage.dart';
import 'package:buybyeq/screens/pagesnav.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:buybyeq/widgets/intro.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'customerdetails/customerProvider.dart';
import 'menu&cart/cartprovider/cartprovider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  await ScreenUtil.ensureScreenSize();

  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => CustomerProvider())],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showIntroScreen = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkIntroScreen();
    _checkLoggedIn();
  }

  _checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('logged_in') ?? false;
    if (isLoggedIn) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  _checkIntroScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('intro_screen_shown') ?? false;
    if (shown) {
      setState(() {
        _showIntroScreen = false;
      });
    } else {
      prefs.setBool('intro_screen_shown', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        color: Colors.orange,
        debugShowCheckedModeBanner: false,
        title: 'BUYBYEQ',
        theme: ThemeData(
          primaryColor: Colors.black,
          primarySwatch: Colors.orange,
        ),
        home: _showIntroScreen
            ? Intro()
            : _isLoggedIn
            ? const LetsNavi()
            : LoginScreen(),
      ),
    );
  }
}
