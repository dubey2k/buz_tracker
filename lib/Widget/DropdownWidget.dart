import 'package:buz_tracker/helper/helper.dart';
import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  final List<String> choices;
  final Function(String) onChange;
  const DropdownWidget({
    super.key,
    required this.choices,
    required this.onChange,
  });

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  late String selValue;

  @override
  void initState() {
    super.initState();
    selValue = widget.choices[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: textBackColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton(
        value: selValue,
        icon: const Icon(Icons.keyboard_arrow_down),
        isExpanded: true,
        items: widget.choices.map((String item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(10),
        onChanged: (String? newValue) {
          widget.onChange.call(newValue!);
          setState(() {
            selValue = newValue;
          });
        },
      ),
    );
  }
}
