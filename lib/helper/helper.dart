import 'dart:math' as math;

import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Color primaryDarkColor = Color.fromARGB(255, 144, 0, 170);
const Color primaryColor = Color.fromARGB(255, 212, 81, 235);
const Color secondaryColor = Color.fromARGB(255, 176, 133, 184);
const Color backgroundColor = Color.fromARGB(255, 253, 242, 255);
const Color textBackColor = Color.fromARGB(255, 236, 236, 236);
const Color elevationColor = Color.fromARGB(255, 213, 213, 213);
const Color pWhiteColor = Colors.white;
const Color hintTextColor = Colors.grey;

showSnakbar(String msg, BuildContext context) {
  final snackbar =
      SnackBar(content: TextWidget(size: 14, text: msg, color: pWhiteColor));
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

bool roleResolver(RoleWithPermission? data, String? reqRole) {
  if (data == null || reqRole == null) return false;
  if (data.role == UserType.Owner.name || data.role == UserType.Admin.name)
    return true;
  String permision = data.permission;
  final rIndex = reqRole.indexOf("1");

  if (permision.characters.characterAt(rIndex).toString() == "1") return true;
  return false;
}

String generateOrgCode(String orgName) {
  String orgCode = orgName
      .split(" ")
      .map((ele) => ele.characters.first)
      .toString()
      .toUpperCase();
  final restCode = generateRandomString(8 - orgCode.length);
  return orgCode + restCode;
}

Color randomColor() {
  return Color.fromARGB(
    255,
    math.Random().nextInt(156) + 100,
    math.Random().nextInt(156) + 100,
    math.Random().nextInt(156) + 100,
  );
}

String generateRandomString(int length) {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = math.Random();
  return List.generate(
      length, (index) => characters[random.nextInt(characters.length)]).join();
}

int diffInMinutes(DateTime d1, DateTime d2) {
  return d1.difference(d2).inMinutes;
}

enum SortBy { ASC, DESC }

enum AccStatus { ADDED, CREATED, ONBOARDED }

enum UserType { Owner, Admin, Supervisor, Worker }

const Map<String, dynamic> PermissionMap = {
  "ViewOtherExpenses": {
    "code": "1000",
    "description": "View Others Expense",
    "enabled": ["Admin"],
  },
  "ViewOtherProjects": {
    "code": "0100",
    "description": "View All Projects",
    "enabled": ["Admin", "Supervisor", "Worker"],
  },
  "ViewProjectExpense": {
    "code": "0010",
    "description": "View Project Expense",
    "enabled": ["Admin"],
  },
  "ViewOtherMembers": {
    "code": "0001",
    "description": "View Other Members",
    "enabled": ["Admin"],
  }
};

enum ProjectStatus { Pending, Ongoing, Completed }

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

extension NameValidator on String {
  bool isValidName() {
    return this != "" && length > 3;
  }
}

extension OrgCodeValidator on String {
  bool isValidOrgCode() {
    return RegExp(r'^[A-Z0-9]{8,}$').hasMatch(this);
  }
}

extension PhoneValidator on String {
  bool isValidPhone() {
    return RegExp(r'^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$')
        .hasMatch(this);
  }
}

extension PasswordValidator on String {
  bool isValidPassword() {
    return length > 6;
  }
}
