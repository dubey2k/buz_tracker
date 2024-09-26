import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final TextEditingController? controller;
  final bool? obsecureText;
  final String title;
  final String? hint;
  final Function? onTap;
  final bool readOnly;
  final String? text;

  const TextInput(
      {Key? key,
      required this.title,
      this.controller,
      this.obsecureText,
      this.hint,
      this.onTap,
      this.readOnly = false,
      this.text})
      : super(key: key);

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  bool visible = false;
  @override
  void initState() {
    super.initState();
    if (widget.obsecureText != null) {
      visible = !widget.obsecureText!;
    } else {
      visible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 20),
          child: TextWidget(
            size: 16,
            text: widget.title,
            wt: FontWeight.w600,
          ),
        ),
        TextField(
          controller: widget.controller,
          readOnly: widget.readOnly,
          obscureText: widget.obsecureText != null ? !visible : false,
          onTap: () async {
            if (widget.readOnly) {
              await widget.onTap?.call();
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: textBackColor,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            hintText: widget.hint,
            suffixIcon: widget.obsecureText != null && widget.obsecureText!
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        visible = !visible;
                      });
                    },
                    icon: visible
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        )
      ],
    );
  }
}
