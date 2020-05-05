import 'package:flutter/material.dart';
import 'package:flutter_flame_demo/utils/constants.dart';
import 'package:flutter_flame_demo/widgets/color_button.dart';

class ColorChooser extends StatefulWidget {
  final String activeColor;
  final bool disabled;
  final Function onSelection;

  ColorChooser(
      {Key key,
      this.activeColor = '',
      this.disabled = false,
      @required this.onSelection})
      : super(key: key);

  _ColorChooserState createState() => _ColorChooserState();
}

class _ColorChooserState extends State<ColorChooser> {
  List<String> colors = PlayerColors;
  String selectedColor = '';

  @override
  void didUpdateWidget(ColorChooser oldWidget) {
    selectedColor =
        widget.activeColor != '' ? widget.activeColor : selectedColor;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: colors.map((color) {
          return ColorButton(
              color: color,
              width: (MediaQuery.of(context).size.width / 5) - 8,
              height: 60.0,
              isSelected: selectedColor == color,
              onPressed: () {
                if (widget.onSelection != null && !widget.disabled) {
                  setState(() {
                    selectedColor = color;
                  });
                  widget.onSelection(selectedColor);
                }
              });
        }).toList(),
      ),
    );
  }
}
