import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:flutter/material.dart';

typedef CustomButtonValidator = bool Function();

class CustomButtonColors {
  CustomButtonColors({
    required this.activeButtonColor,
    required this.activeTextColor,
    this.inActiveButtonColor,
    this.inAciveTextColor,
  }) {
    inAciveTextColor ??= activeTextColor;
    inActiveButtonColor ??= activeButtonColor;
  }
  Color activeButtonColor, activeTextColor;
  Color? inActiveButtonColor, inAciveTextColor;
}

class CustomButton extends StatelessWidget {
  final String text;
  final Function onTap;
  final double iconDis;
  final Widget? icon;
  final double size;
  final double horiPad;
  final double verPad;
  final double horiMar;
  final double verMar;
  final double elevation;
  final FontWeight wt;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final double radius;
  final CustomButtonValidator? buttonStateValidator;
  final CustomButtonColors colors;
  final Color loaderColor;

  ///paas ValueNotifier(false) to make this button async
  final ValueNotifier<bool>? asyncNotifier;

  const CustomButton({
    required this.text,
    required this.onTap,
    required this.colors,
    this.icon,
    this.size = 18,
    this.horiMar = 8,
    this.horiPad = 15,
    this.verMar = 8,
    this.verPad = 15,
    this.elevation = 0,
    this.asyncNotifier,
    this.wt = FontWeight.w600,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.borderRadius,
    this.radius = 10,
    this.iconDis = 20,
    this.buttonStateValidator,
    this.loaderColor = Colors.white,
  });
  @override
  Widget build(BuildContext context) {
    return asyncNotifier != null && asyncNotifier?.value != null
        ? ValueListenableBuilder(
            valueListenable: asyncNotifier ?? ValueNotifier(false),
            builder: (context, val, child) {
              return button();
            })
        : button();
  }

  Widget button() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horiMar,
        vertical: verMar,
      ),
      child: MaterialButton(
        elevation: elevation,
        color: buttonStateValidator?.call() ?? true
            ? colors.activeButtonColor
            : colors.inActiveButtonColor,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        padding: EdgeInsets.symmetric(horizontal: horiPad, vertical: verPad),
        onPressed: () async {
          if (asyncNotifier != null && asyncNotifier?.value != null) {
            if (!asyncNotifier!.value) {
              asyncNotifier?.value = true;
              await onTap();
              asyncNotifier?.value = false;
            }
          } else {
            await onTap();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ?? Container(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: iconDis),
              child: asyncNotifier != null &&
                      asyncNotifier?.value != null &&
                      asyncNotifier!.value
                  ? Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(loaderColor),
                        ),
                      ),
                    )
                  : TextWidget(
                      size: size,
                      text: text,
                      align: TextAlign.center,
                      color: buttonStateValidator?.call() ?? true
                          ? colors.activeTextColor
                          : colors.inAciveTextColor,
                      wt: wt,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
