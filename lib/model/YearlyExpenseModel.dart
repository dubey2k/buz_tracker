// To parse this JSON data, do
//
//     final yearlyExpenseModel = yearlyExpenseModelFromJson(jsonString);

import 'dart:convert';

YearlyExpenseModel yearlyExpenseModelFromJson(String str) =>
    YearlyExpenseModel.fromJson(json.decode(str));

String yearlyExpenseModelToJson(YearlyExpenseModel data) =>
    json.encode(data.toJson());

class YearlyExpenseModel {
  DateTime yearMonth;
  double userExpense;
  double orgExpense;

  YearlyExpenseModel({
    required this.yearMonth,
    required this.userExpense,
    required this.orgExpense,
  });

  factory YearlyExpenseModel.fromJson(Map<String, dynamic> json) =>
      YearlyExpenseModel(
        yearMonth: DateTime.parse(json["year_month"] + "-01"),
        userExpense: double.parse(json["user_expense"].toString()),
        orgExpense: double.parse(json["org_expense"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "year_month": yearMonth.toIso8601String(),
        "user_expense": userExpense,
        "org_expense": orgExpense,
      };
}
