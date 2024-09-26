import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/ElevationButton.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/UserModel.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  ScreenStatus _status = OkStatus();

  late final TextEditingController _nameCon, _phoneCon, _roleCon, _emailCon;
  final user = UserService.getUser();

  @override
  void initState() {
    super.initState();
    _nameCon = TextEditingController();
    _phoneCon = TextEditingController();
    _roleCon = TextEditingController();
    _emailCon = TextEditingController();

    _nameCon.text = user!.name ?? "";
    _phoneCon.text = user!.phoneNumber ?? "";
    _roleCon.text = user!.rwp?.first.role ?? "";
    _emailCon.text = user!.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pWhiteColor,
      appBar: AppBar(
        title: const TextWidget(
          size: 18,
          text: "User Profile",
          wt: FontWeight.w700,
        ),
      ),
      body: ScreenWrapper(
        status: _status,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            child: Column(
              children: [
                TextInput(
                    readOnly: true, controller: _emailCon, title: "Email"),
                TextInput(readOnly: true, controller: _roleCon, title: "Role"),
                TextInput(controller: _nameCon, title: "User Name"),
                TextInput(controller: _phoneCon, title: "Phone Number"),
                const Spacer(),
                ElevationButton(
                  onTap: () async {
                    setState(() {
                      _status = LoadingStatus(toBlur: true);
                    });
                    try {
                      final name = _nameCon.text.trim();
                      final phone = _phoneCon.text.trim();

                      if (user == null) {
                        throw ErrorDescription("Error while updating profile");
                      }

                      final updatedUser = await DBService().updateUser(
                          user!.email,
                          username: name != user!.name && name.isValidName()
                              ? name
                              : null,
                          phone:
                              phone != user!.phoneNumber && phone.isValidPhone()
                                  ? phone
                                  : null);

                      await UserService()
                          .setUser(UserModel.fromJson(updatedUser.first));

                      showSnakbar("User profile Updated!!", context);
                    } catch (e) {
                      showSnakbar(e.toString(), context);
                      _status = OkStatus();
                      setState(() {});
                    }
                  },
                  backgroundColor: primaryColor,
                  text: const TextWidget(
                    size: 20,
                    text: "Update",
                    wt: FontWeight.bold,
                    color: pWhiteColor,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
