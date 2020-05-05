import 'package:flutter/material.dart';
import 'package:flutter_flame_demo/utils/styles.dart';

class CustomBackButton extends StatelessWidget {
  CustomBackButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 10,
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.white, size: 32.0),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
