import 'package:flutter/material.dart';

class CustomDrawerHeader extends StatelessWidget {
  final bool isColapsed;

  const CustomDrawerHeader({
    Key? key,
    required this.isColapsed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: isColapsed
          ? MediaQuery.of(context).size.width * 0.450
          : MediaQuery.of(context).size.width * .2,
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isColapsed) Center(
                          child: Container(
                              width: MediaQuery.of(context).size.width * .12,
                              height: MediaQuery.of(context).size.width * .10,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80)),
                              child: Image.asset(
                                  fit: BoxFit.cover,
                                  'assets/biriyanibites-removebg-preview.png'))) else Center(
                          child: Container(
                              width: MediaQuery.of(context).size.width * .31,
                              height: MediaQuery.of(context).size.width * .4,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  Image.asset(
                                      fit: BoxFit.contain,
                                      'assets/biriyanibites-removebg-preview.png'),
                                  const Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        'Bites',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              )))
            ],
          ),
        ),
      ),
    );
  }
}
