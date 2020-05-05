import 'package:flutter/material.dart';

class FullBackground extends StatelessWidget {
  FullBackground({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
    );
  }
}
