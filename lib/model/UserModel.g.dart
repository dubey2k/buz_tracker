// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as int,
      email: fields[1] as String,
      createdAt: fields[2] as String,
      updatedAt: fields[3] as String,
      rwp: (fields[9] as List?)?.cast<RoleWithPermission>(),
      name: fields[4] as String?,
      phoneNumber: fields[5] as String?,
      organisationId: fields[6] as int?,
      addedBy: fields[7] as int?,
      accStatus: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.organisationId)
      ..writeByte(7)
      ..write(obj.addedBy)
      ..writeByte(8)
      ..write(obj.accStatus)
      ..writeByte(9)
      ..write(obj.rwp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoleWithPermissionAdapter extends TypeAdapter<RoleWithPermission> {
  @override
  final int typeId = 2;

  @override
  RoleWithPermission read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoleWithPermission(
      role: fields[0] as String,
      permission: fields[1] as String,
      isDisabled: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RoleWithPermission obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.role)
      ..writeByte(1)
      ..write(obj.permission)
      ..writeByte(2)
      ..write(obj.isDisabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleWithPermissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
