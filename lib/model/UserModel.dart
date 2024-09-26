import 'dart:convert';
import 'dart:developer';
import 'package:hive/hive.dart';
part 'UserModel.g.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String createdAt;

  @HiveField(3)
  final String updatedAt;

  @HiveField(4)
  final String? name;

  @HiveField(5)
  final String? phoneNumber;

  @HiveField(6)
  final int? organisationId;

  @HiveField(7)
  final int? addedBy;

  @HiveField(8)
  final String? accStatus;

  @HiveField(9)
  final List<RoleWithPermission>? rwp;

  UserModel({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.rwp,
    this.name,
    this.phoneNumber,
    this.organisationId,
    this.addedBy,
    this.accStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    log("USER JSON:: $json");
    return UserModel(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      phoneNumber: json["phone"],
      organisationId: json["organisation_id"],
      addedBy: json["added_by"],
      accStatus: json["acc_status"],
      rwp: json["Role_With_Permissions"] != null
          ? List<RoleWithPermission>.from(json["Role_With_Permissions"]
              .map((x) => RoleWithPermission.fromJson(x)))
          : null,
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phoneNumber,
        "organisation_id": organisationId,
        "added_by": addedBy,
        "acc_status": accStatus,
        "Role_With_Permissions":
            rwp == null ? [] : List<dynamic>.from(rwp!.map((x) => x.toJson())),
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

@HiveType(typeId: 2)
class RoleWithPermission {
  @HiveField(0)
  String role;

  @HiveField(1)
  String permission;

  @HiveField(2)
  bool isDisabled;

  RoleWithPermission(
      {required this.role, required this.permission, required this.isDisabled});

  factory RoleWithPermission.fromJson(Map<String, dynamic> json) =>
      RoleWithPermission(
        role: json["role"],
        permission: json["permission"],
        isDisabled: json["is_disabled"],
      );

  Map<String, dynamic> toJson() => {
        "role": role,
        "permission": permission,
        "is_disabled": isDisabled,
      };
}
