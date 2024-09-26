// To parse this JSON data, do
//
//     final monthlyExpenseModel = monthlyExpenseModelFromJson(jsonString);

import 'dart:convert';

DailyExpenseModel monthlyExpenseModelFromJson(String str) =>
    DailyExpenseModel.fromJson(json.decode(str));

String monthlyExpenseModelToJson(DailyExpenseModel data) =>
    json.encode(data.toJson());

class DailyExpenseModel {
  double userExpense;
  double orgExpense;

  DailyExpenseModel({
    required this.userExpense,
    required this.orgExpense,
  });

  factory DailyExpenseModel.fromJson(Map<String, dynamic> json) =>
      DailyExpenseModel(
        userExpense: double.parse(json["total_user_expense"] != null
            ? json["total_user_expense"].toString()
            : "0"),
        orgExpense: double.parse(json["total_org_expense"] != null
            ? json["total_org_expense"].toString()
            : "0"),
      );

  Map<String, dynamic> toJson() => {
        "total_user_expense": userExpense,
        "total_org_expense": orgExpense,
      };
}
