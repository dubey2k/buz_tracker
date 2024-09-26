import 'package:buz_tracker/helper/helper.dart';
import 'package:flutter/material.dart';

class ElevationButton extends StatelessWidget {
  final Function() onTap;
  final Color backgroundColor;
  final Widget? icon;
  final Widget text;
  final bool makeAsync;
  const ElevationButton(
      {super.key,
      required this.onTap,
      required this.backgroundColor,
      required this.text,
      this.icon,
      this.makeAsync = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                offset: Offset(2, 2),
                color: elevationColor,
                blurRadius: 5,
                spreadRadius: 0,
              )
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(
                width: 15,
              )
            ],
            text
          ],
        ),
      ),
    );
  }
}
