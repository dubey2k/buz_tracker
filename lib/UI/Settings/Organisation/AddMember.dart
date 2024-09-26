import 'dart:developer';

import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/DropdownWidget.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:flutter/material.dart';

class AddMember extends StatefulWidget {
  const AddMember({super.key});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  ScreenStatus _status = OkStatus();

  late final TextEditingController _nameCon, _emailCon, _phoneCon;

  UserType _selRole = UserType.Admin;

  Map<String, bool> permissions = {};

  @override
  void initState() {
    super.initState();
    _nameCon = TextEditingController();
    _emailCon = TextEditingController();
    _phoneCon = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameCon.dispose();
    _emailCon.dispose();
    _phoneCon.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      status: _status,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const TextWidget(
            size: 18,
            text: "Add Member",
            wt: FontWeight.w700,
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  try {
                    final user = UserService.getUser();
                    final name = _nameCon.text.trim();
                    final email = _emailCon.text.trim();
                    final phone = _phoneCon.text.trim();

                    log("email: $email, name: $name, phone: $phone");

                    if (!name.isValidName() ||
                        !email.isValidEmail() ||
                        !phone.isValidPhone()) {
                      throw ErrorDescription("Invalid inputs");
                    }

                    setState(() {
                      _status = LoadingStatus(toBlur: true);
                    });

                    List<String> perm = ['0', '0', '0', '0'];

                    permissions.forEach((key, value) {
                      String code = PermissionMap[key]["code"];
                      if (value) {
                        int index = code.indexOf("1");
                        if (index != -1) {
                          perm[index] = "1";
                        }
                      }
                    });

                    String permString = perm.join();

                    await DBService().registerUserToOrganisation(
                      name: name,
                      email: email,
                      phone: phone,
                      orgId: user!.organisationId!,
                      userId: user.id,
                      role: _selRole,
                      permission: permString,
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    log("ERror:: ${e.toString()}");
                    showSnakbar(e.toString(), context);
                  }
                  setState(() {
                    _status = OkStatus();
                  });
                },
                icon: const Icon(Icons.check))
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextInput(controller: _nameCon, title: "Name"),
                const SizedBox(height: 10),
                TextInput(controller: _emailCon, title: "Email"),
                const SizedBox(height: 10),
                TextInput(controller: _phoneCon, title: "Phone"),
                const SizedBox(height: 30),
                const TextWidget(size: 16, text: "Role", wt: FontWeight.w600),
                const SizedBox(height: 5),
                DropdownWidget(
                  choices: UserType.values
                      .where((test) => test.name != "Owner")
                      .map((toElement) => toElement.name)
                      .toList(),
                  onChange: (String value) {
                    _selRole = UserType.values.byName(value);
                    Map<String, bool> temp = {};
                    permissions.forEach((name, allow) {
                      temp.putIfAbsent(
                          name,
                          () => PermissionMap[name]["enabled"]
                              .contains(_selRole.name));
                    });
                    permissions = temp;
                    setState(() {});
                  },
                ),
                const SizedBox(height: 30),
                const TextWidget(
                    size: 16, text: "Permissions", wt: FontWeight.w600),
                const SizedBox(height: 5),
                Column(
                  children: PermissionMap.entries.map(
                    (entry) {
                      permissions.putIfAbsent(entry.key,
                          () => entry.value["enabled"].contains(_selRole.name));
                      return CheckboxListTile(
                        title: TextWidget(
                            size: 16, text: entry.value["description"]),
                        value: permissions[entry.key],
                        onChanged: (data) {
                          if (data != null) {
                            setState(() {
                              permissions[entry.key] = data;
                            });
                          }
                        },
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
