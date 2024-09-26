import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:flutter/material.dart';

class ErrorContainer extends StatelessWidget {
  final String errorMessage;
  const ErrorContainer({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextWidget(size: 20, text: errorMessage, wt: FontWeight.bold),
    );
  }
}
