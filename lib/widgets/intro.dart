import 'package:avatar_glow/avatar_glow.dart';
import 'package:buybyeq/screens/loginpage.dart';
import 'package:buybyeq/screens/pagesnav.dart';
import 'package:flutter/material.dart';
import 'delayed_animation.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> with SingleTickerProviderStateMixin {
  final int delayedAmount = 2000;
  late double _scale;
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1000,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;
    _scale = 1 - _controller.value;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.deepOrange,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AvatarGlow(
                    endRadius: 90,
                    duration: const Duration(seconds: 2),
                    glowColor: Colors.white60,
                    repeat: true,
                    repeatPauseDuration: const Duration(seconds: 1),
                    startDelay: const Duration(seconds: 1),
                    child: Material(
                      shadowColor: Colors.deepPurple,
                      elevation: 18.0,
                      color: Colors.tealAccent,
                      shape: const CircleBorder(),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50,
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                              fit: BoxFit.cover,
                              'assets/buybyeq_logo.png'),
                        ),
                      ),
                    )),
                DelayedAnimation(
                  delay: delayedAmount + 2000,
                  child: const Text(
                    "Hi There",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 50.0,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 15),
                DelayedAnimation(
                  delay: delayedAmount + 4000,
                  child: Text(
                    "I'm BuyByeQ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0,
                        color: color),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                DelayedAnimation(
                  delay: delayedAmount + 6000,
                  child: Text(
                    " One stop solution",
                    style: TextStyle(fontSize: 20.0, color: color),
                  ),
                ),
                DelayedAnimation(
                  delay: delayedAmount + 6000,
                  child: Text(
                    "For restaurant management",
                    style: TextStyle(fontSize: 20.0, color: color),
                  ),
                ),
                const SizedBox(
                  height: 100.0,
                ),
                DelayedAnimation(
                  delay: delayedAmount + 8000,
                  child: GestureDetector(
                    onTap:() {Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));},
                      child: _animatedButtonUI,
                  ),
                ),
                const SizedBox(
                  height: 50.0,
                ),
              ],
            ),
          )),
    );
  }

  Widget get _animatedButtonUI => Container(
          height: 60,
          width: 270,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0),
            color: Colors.white,
          ),
          child: const Center(
                  child: Text(
                'Explore BuyByeQ',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8185E2),
                ),
              ),

            ),
            );
}
