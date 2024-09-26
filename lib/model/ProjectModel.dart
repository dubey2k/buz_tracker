// To parse this JSON data, do
//
//     final projectModel = projectModelFromJson(jsonString);

import 'dart:convert';

ProjectModel projectModelFromJson(String str) =>
    ProjectModel.fromJson(json.decode(str));

String projectModelToJson(ProjectModel data) => json.encode(data.toJson());

class ProjectModel {
  int id;
  String name;
  String status;
  String createdAt;
  String updatedAt;
  String? description;
  String? completedOn;
  double? totalExpense;

  ProjectModel(
      {required this.id,
      required this.name,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.description,
      this.completedOn,
      this.totalExpense});

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        status: json["status"],
        completedOn: json["completed_on"],
        totalExpense: json["total_expense"]?.toDouble(),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "status": status,
        "completed_on": completedOn,
        "total_expense": totalExpense,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
