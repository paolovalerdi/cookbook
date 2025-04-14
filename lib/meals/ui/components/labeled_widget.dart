import 'package:flutter/material.dart';

class LabeledWidget extends StatelessWidget {
  const LabeledWidget({
    super.key,
    required this.icon,
    required this.text,
    this.gap = 4,
    this.textStyle = const TextStyle(fontSize: 12),
  });

  final Widget icon;

  final String text;

  final double gap;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            child: Padding(padding: EdgeInsets.only(right: gap), child: icon),
            alignment: PlaceholderAlignment.middle,
          ),
          TextSpan(text: text),
        ],
      ),
      style: textStyle,
    );
  }
}
