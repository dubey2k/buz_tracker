// To parse this JSON data, do
//
//     final organisationModel = organisationModelFromJson(jsonString);

import 'dart:convert';

OrganisationModel organisationModelFromJson(String str) =>
    OrganisationModel.fromJson(json.decode(str));

String organisationModelToJson(OrganisationModel data) =>
    json.encode(data.toJson());

class OrganisationModel {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  String name;
  String email;
  String address;
  String code;

  OrganisationModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.email,
    required this.address,
    required this.code,
  });

  factory OrganisationModel.fromJson(Map<String, dynamic> json) =>
      OrganisationModel(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        name: json["name"],
        email: json["email"],
        address: json["address"],
        code: json["org_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "name": name,
        "email": email,
        "address": address,
        "org_code": code,
      };
}
