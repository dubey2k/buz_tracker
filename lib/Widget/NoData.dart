import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  final String? message;
  const NoData({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextWidget(
          size: 20, text: message ?? "Looks there's no data right now!"),
    );
  }
}
