import 'dart:developer';

import 'package:buz_tracker/Service/AuthService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/Authentication/SignInPage.dart';
import 'package:buz_tracker/UI/Settings/Organisation/ManageMembers.dart';
import 'package:buz_tracker/UI/Settings/Organisation/OrganisationDetail.dart';
import 'package:buz_tracker/UI/Settings/Profile/UserProfile.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _settingItem(
          "Account",
          Icons.person,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const UserProfile()));
          },
        ),
        const Divider(),
        _settingItem(
          "Organisation Details",
          Icons.business,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OrganisationDetail()));
          },
        ),
        if (roleResolver(UserService.getUser()?.rwp?.first,
            PermissionMap["ViewOtherMembers"]["code"])) ...[
          const Divider(),
          _settingItem(
            "Manage Members",
            Icons.manage_accounts,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageMembers()));
            },
          ),
        ],
        const Divider(),
        _settingItem("Log Out", Icons.logout, onTap: () async {
          final bool? res = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const TextWidget(
                    size: 20, text: "Logout", wt: FontWeight.w600),
                content: const TextWidget(
                    size: 16,
                    text: "Are you sure you want to logout?",
                    wt: FontWeight.w600),
                actions: [
                  TextButton(
                    child: const TextWidget(
                        size: 16, text: "Logout", wt: FontWeight.bold),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  TextButton(
                    child: const TextWidget(
                        size: 16, text: "cancel", wt: FontWeight.w600),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              );
            },
          );
          log("RES:: $res");
          if (res != null && res) {
            await AuthService().logout();
            await UserService().logOut();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => const SignInPage()),
                (route) => false);
          }
        }),
        const Divider(),
      ],
    );
  }

  Widget _settingItem(String title, IconData icon, {Function? onTap}) {
    return GestureDetector(
      onTap: () async {
        await onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            TextWidget(
              size: 16,
              text: title,
              wt: FontWeight.w600,
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }
}
