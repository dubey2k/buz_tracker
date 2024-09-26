// To parse this JSON data, do
//
//     final monthlyExpenseModel = monthlyExpenseModelFromJson(jsonString);

import 'dart:convert';

MonthlyExpenseModel monthlyExpenseModelFromJson(String str) =>
    MonthlyExpenseModel.fromJson(json.decode(str));

String monthlyExpenseModelToJson(MonthlyExpenseModel data) =>
    json.encode(data.toJson());

class MonthlyExpenseModel {
  DateTime forDate;
  double userExpense;
  double orgExpense;

  MonthlyExpenseModel({
    required this.forDate,
    required this.userExpense,
    required this.orgExpense,
  });

  factory MonthlyExpenseModel.fromJson(Map<String, dynamic> json) =>
      MonthlyExpenseModel(
        forDate: DateTime.parse(json["for_date"]),
        userExpense: double.parse(json["user_expense"].toString()),
        orgExpense: double.parse(json["org_expense"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "for_date": forDate.toIso8601String(),
        "user_expense": userExpense,
        "org_expense": orgExpense,
      };
}
