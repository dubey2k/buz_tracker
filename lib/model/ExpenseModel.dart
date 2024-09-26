// To parse this JSON data, do
//
//     final expenseModel = expenseModelFromJson(jsonString);

import 'dart:convert';

ExpenseModel expenseModelFromJson(String str) =>
    ExpenseModel.fromJson(json.decode(str));

String expenseModelToJson(ExpenseModel data) => json.encode(data.toJson());

class ExpenseModel {
  int id;
  String title;
  String description;
  double amount;
  String createdBy;
  String projectName;
  int noOfEdits;
  String createdAt;
  String forDate;
  String updatedAt;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.createdBy,
    required this.projectName,
    required this.createdAt,
    required this.forDate,
    required this.updatedAt,
    required this.noOfEdits,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      amount: json["amount"]?.toDouble(),
      createdBy: json["created_by"],
      noOfEdits: json["no_of_edits"],
      projectName: json["project_name"],
      forDate: json["for_date"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "amount": amount,
        "created_by": createdBy,
        "project_id": projectName,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "no_of_edits": noOfEdits,
        "for_date": forDate
      };
}
