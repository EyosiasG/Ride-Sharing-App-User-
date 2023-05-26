// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class TextFieldForm extends StatelessWidget {
  String text;
  TextEditingController controller;
  TextCapitalization capitalization;
  TextInputType textInputType;
  TextInputAction textInputAction;

  TextFieldForm({
    Key? key,
    required this.text,
    required this.controller,
    required this.capitalization,
    required this.textInputType,
    required this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      textCapitalization: capitalization,
      decoration: InputDecoration(
          enabledBorder:  UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent),
          ),
          focusedBorder:  const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent)
          ),
          label: Text(text),
          labelStyle: const TextStyle(
            color:Colors.grey,
            fontSize: 16,
          ),
          hintStyle: const TextStyle(
            color:Colors.grey,
            fontSize: 16,
          )),
      style: const TextStyle(fontSize: 17.0),
    );
  }
}
