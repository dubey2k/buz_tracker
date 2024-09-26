import 'dart:developer';

import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/Authentication/SignInPage.dart';
import 'package:buz_tracker/UI/Dashboard.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/ElevationButton.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/UserModel.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgEmailController = TextEditingController();
  final TextEditingController _orgAddressController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();

  ScreenStatus _status = OkStatus();
  late final UserModel? user = UserService.getUser();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: user?.organisationId == null ? 2 : 1, vsync: this);
    checkAndNavigate();
  }

  checkAndNavigate() async {
    if (user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInPage(),
        ),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pWhiteColor,
      body: ScreenWrapper(
        status: _status,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              const TextWidget(
                  size: 28, text: "BuzTracker", wt: FontWeight.bold),
              const TextWidget(
                  size: 22, text: "Create your Profile", wt: FontWeight.bold),
              const SizedBox(
                height: 30,
              ),
              TabBar(
                controller: _tabController,
                tabs: [
                  const Tab(
                    text: "As User",
                  ),
                  if (user?.organisationId == null)
                    const Tab(
                      text: "As Owner",
                    ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    createUserProfile(),
                    if (user?.organisationId == null) createOrganisation(),
                  ],
                ),
              ),
              ElevationButton(
                onTap: () async {
                  setState(() {
                    _status = LoadingStatus(toBlur: true);
                  });
                  try {
                    final name = _nameController.text.trim();
                    final phone = _phoneController.text.trim();
                    String orgCode = _orgController.text.trim();
                    final orgName = _orgNameController.text.trim();
                    final orgAddress = _orgAddressController.text.trim();
                    final orgEmail = _orgEmailController.text.trim();

                    if (user == null) {
                      throw ErrorDescription("Error while creating profile");
                    }

                    if (_tabController.index == 0) {
                      if (!name.isValidName() || !phone.isValidPhone()) {
                        throw ErrorDescription("Provide valid inputs");
                      }

                      final userEnabled = await DBService()
                          .checkUserForOrganisation(
                              user!.email, _orgController.text.trim());
                      log("USER_INFO:: $userEnabled, ${user!.email}, ${_orgController.text.trim()}");

                      if (userEnabled.isEmpty) {
                        throw ErrorDescription(
                            "You are not allowed to join this organisation!");
                      }

                      final updatedUser = await DBService()
                          .addUserToOrganisation(user!.email,
                              _nameController.text, _phoneController.text);

                      await UserService()
                          .setUser(UserModel.fromJson(updatedUser.first));
                    } else {
                      if (!name.isValidName() ||
                          !phone.isValidPhone() ||
                          !orgName.isValidName() ||
                          !orgEmail.isValidEmail() ||
                          orgAddress.isEmpty) {
                        throw ErrorDescription("Provide valid inputs");
                      }

                      if (orgCode == "") {
                        orgCode = generateOrgCode(orgName);
                      }

                      final userExists =
                          await DBService().findUserByEmail(user!.email);

                      if (userExists.isEmpty ||
                          userExists.first["organisation_id"] != null) {
                        throw ErrorDescription("Error while creating profile");
                      }

                      final updatedUser = await DBService().createOrganisation(
                          user!.email,
                          name,
                          phone,
                          orgName,
                          orgEmail,
                          orgAddress,
                          orgCode);

                      await UserService()
                          .setUser(UserModel.fromJson(updatedUser.first));
                    }

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const Dashboard()),
                        (route) => false);
                  } catch (e) {
                    log("Error:: ${e.toString()}");
                    showSnakbar(e.toString(), context);
                    _status = OkStatus();
                    setState(() {});
                  }
                },
                backgroundColor: primaryColor,
                text: const TextWidget(
                  size: 20,
                  text: "Continue",
                  wt: FontWeight.bold,
                  color: pWhiteColor,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createUserProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextInput(
            controller: _nameController,
            obsecureText: false,
            title: "Name",
            hint: "Enter your Name",
          ),
          TextInput(
            controller: _phoneController,
            obsecureText: false,
            title: "Phone",
            hint: "Enter your phone number",
          ),
          TextInput(
            controller: _orgController,
            obsecureText: false,
            title: "Organisation Code",
            hint: "Enter your Organisation Code",
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget createOrganisation() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            "User Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextInput(
            controller: _nameController,
            obsecureText: false,
            title: "Name",
            hint: "Enter your Name",
          ),
          TextInput(
            controller: _phoneController,
            obsecureText: false,
            title: "Phone",
            hint: "Enter your phone number",
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Organisation Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextInput(
            controller: _orgNameController,
            obsecureText: false,
            title: "Organisation Name",
            hint: "Enter your Organisation Name",
          ),
          TextInput(
            controller: _orgEmailController,
            obsecureText: false,
            title: "Organisation Email",
            hint: "Enter your Organisation Email",
          ),
          TextInput(
            controller: _orgAddressController,
            obsecureText: false,
            title: "Organisation Address",
            hint: "Enter your Organisation Address",
          ),
          TextInput(
            controller: _orgController,
            obsecureText: false,
            title: "Organisation Code",
            hint: "Enter your Organisation Code (Optional)",
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
