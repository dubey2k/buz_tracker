import 'package:buz_tracker/Service/SupabaseClient.dart';
import 'package:buz_tracker/helper/DBConfig.dart';
import 'package:buz_tracker/model/UserModel.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserService {
  static final UserService _user = UserService._internal();
  factory UserService() {
    return _user;
  }

  UserService._internal();

  static UserModel? _userModel;

  Future<UserModel?> getUserInit() async {
    if (_userModel == null) {
      final userBox = await Hive.openBox<UserModel>("UserBox");
      _userModel = userBox.get("primary_user");

      if (_userModel == null) return null;

      final fetchedUser = await SupabaseInstance()
          .client
          .from(TableNames.users)
          .select(
              'id, created_at, updated_at, name, email, phone, organisation_id, added_by, acc_status, ${TableNames.role_with_permissions}(role, permission, is_disabled)')
          .eq("email", _userModel?.email ?? "NOT_EMAIL");

      if (fetchedUser.isNotEmpty) {
        final user = UserModel.fromJson(fetchedUser.first);
        await setUser(user);
        _userModel = user;
      } else {
        _userModel = null;
      }
      await userBox.close();
    }
    return _userModel;
  }

  static UserModel? getUser() {
    return _userModel;
  }

  Future setUser(UserModel user) async {
    _userModel = user;
    final userBox = await Hive.openBox<UserModel>("UserBox");
    await userBox.put("primary_user", user);
    await userBox.close();
  }

  logOut() async {
    final userBox = await Hive.openBox<UserModel>("UserBox");
    await userBox.clear();
    await userBox.close();
  }
}
