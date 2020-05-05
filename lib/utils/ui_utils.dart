import 'package:flutter/material.dart';
import 'package:flutter_flame_demo/utils/styles.dart';
import 'package:flutter_flame_demo/widgets/custom_dialog.dart';
import 'package:flutter_flame_demo/widgets/game_rules_modal.dart';

class UiUtils {
  static Future<bool> confirmDialog(
      {BuildContext context,
      Icon icon = const Icon(Icons.info, size: 30.0, color: AppColors.white),
      Color iconBackgroundColor = AppColors.cardinal,
      String title = '',
      String message = ''}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64.0,
              height: 64.0,
              child: Image.asset('assets/images/stop.png'),
            ),
            SizedBox(height: 20.0),
            Text(title, style: AppTextStyles.confirmationTitle),
            SizedBox(height: 10.0),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.confirmationMessage),
            SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  color: AppColors.whiteLight,
                  child: Text('No', style: AppTextStyles.confirmationButton),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                SizedBox(width: 10.0),
                new RaisedButton(
                  color: AppColors.cardinal,
                  child: Text('Yes',
                      style: AppTextStyles.confirmationButton
                          .copyWith(color: AppColors.white)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            )
          ],
        ));
      },
    );
  }

  static void showGameRulesDialog(BuildContext context) {
    var _dialog = CustomDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: GameRulesDialog(),
    );

    showDialog(context: context, builder: (BuildContext context) => _dialog);
  }
}
