import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({
    Key? key,
    required this.size,
    required this.text,
    this.color,
    this.wt,
    this.align,
    this.maxLine,
    this.style = FontStyle.normal,
  }) : super(key: key);

  final double size;
  final String text;
  final Color? color;
  final FontWeight? wt;
  final TextAlign? align;
  final int? maxLine;
  final FontStyle? style;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLine,
      overflow: maxLine != null ? TextOverflow.ellipsis : TextOverflow.visible,
      style: GoogleFonts.montserrat(
        fontWeight: wt,
        fontSize: size,
        color: color ?? Colors.black,
        fontStyle: style,
      ),
    );
  }
}
