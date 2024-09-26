import 'dart:developer';

import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/Authentication/ProfilePage.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/ElevationButton.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:buz_tracker/Service/AuthService.dart';
import 'package:buz_tracker/UI/Authentication/SignInPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();

  AuthService authClass = AuthService();
  ScreenStatus _status = OkStatus();

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      status: _status,
      child: Scaffold(
        backgroundColor: pWhiteColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const Image(
                    image: AssetImage("assets/logo/logo.png"),
                    height: 100,
                  ),
                  const TextWidget(
                      size: 22, text: "Let's Go", wt: FontWeight.bold),
                  const TextWidget(size: 28, text: "Start your journey"),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevationButton(
                    onTap: () async {
                      try {
                        setState(() {
                          _status = LoadingStatus(toBlur: true);
                        });
                        final res = await authClass.googleSignIn();

                        if (res.user == null || res.user?.email == null) {
                          throw ErrorDescription("Error while registering!");
                        }

                        final userExists =
                            await DBService().findUserByEmail(res.user!.email!);

                        List<Map<String, dynamic>> result;

                        if (userExists.isEmpty) {
                          result =
                              await DBService().addUserToDB(res.user!.email!);
                        } else {
                          result = userExists;
                        }

                        UserModel user = UserModel.fromJson(result.first);

                        if (user.accStatus != null &&
                            user.accStatus != AccStatus.ADDED.name &&
                            userExists.isNotEmpty) {
                          throw ErrorDescription(
                              "User already exists! Try logging in");
                        }

                        if (user.accStatus != null &&
                            user.accStatus == AccStatus.ADDED.name) {
                          //making user marked as created here, as it's been created
                          result = await DBService()
                              .markCreatedUserToDB(res.user!.email!);
                          user = UserModel.fromJson(result.first);
                        }

                        await UserService().setUser(user);

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfilePage()),
                            (_) => false);
                      } catch (e) {
                        showSnakbar(e.toString(), context);
                      }
                      setState(() {
                        _status = OkStatus();
                      });
                    },
                    backgroundColor: backgroundColor,
                    icon: SvgPicture.asset(
                      "assets/svgs/google.svg",
                      height: 24,
                      width: 24,
                    ),
                    text: const TextWidget(
                      size: 16,
                      text: "Continue with Google",
                      wt: FontWeight.w600,
                      color: Color.fromARGB(255, 77, 77, 77),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const TextWidget(
                    size: 18,
                    text: "Or",
                    wt: FontWeight.w600,
                  ),
                  TextInput(
                    controller: _emailController,
                    obsecureText: false,
                    title: "Email",
                    hint: "Enter your email",
                  ),
                  TextInput(
                    controller: _passwordController,
                    obsecureText: true,
                    title: "Password",
                    hint: "Enter your Password",
                  ),
                  TextInput(
                    controller: _cpasswordController,
                    obsecureText: true,
                    title: "Confirm Password",
                    hint: "Re-Enter your Password",
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevationButton(
                    onTap: () async {
                      setState(() {
                        _status = LoadingStatus(toBlur: true);
                      });
                      try {
                        if (!_emailController.text.isValidEmail()) {
                          throw ErrorDescription("Invalid email");
                        }
                        if (!_passwordController.text.isValidPassword()) {
                          throw ErrorDescription("Invalid password");
                        }
                        if (_passwordController.text !=
                            _cpasswordController.text) {
                          throw ErrorDescription("Passwords aren't matching");
                        }

                        final res = await authClass.emailSignUp(
                            _emailController.text, _passwordController.text);

                        if (res.user == null || res.user?.email == null) {
                          throw ErrorDescription("Error while registering!");
                        }

                        final userExists =
                            await DBService().findUserByEmail(res.user!.email!);

                        List<Map<String, dynamic>> result;

                        if (userExists.isEmpty) {
                          result =
                              await DBService().addUserToDB(res.user!.email!);
                        } else {
                          result = userExists;
                        }

                        UserModel user = UserModel.fromJson(result.first);

                        if (user.accStatus != null &&
                            user.accStatus != AccStatus.ADDED.name &&
                            userExists.isNotEmpty) {
                          throw ErrorDescription(
                              "User already exists! Try logging in");
                        }

                        if (user.accStatus != null &&
                            user.accStatus == AccStatus.ADDED.name) {
                          //making user marked as created here, as it's been created
                          result = await DBService()
                              .markCreatedUserToDB(res.user!.email!);
                          user = UserModel.fromJson(result.first);
                        }

                        await UserService().setUser(user);

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => const ProfilePage()),
                            (route) => false);
                      } catch (e) {
                        log("ERROR SIGNUP:: ${e.toString()}");
                        showSnakbar(e.toString(), context);
                        setState(() {
                          _status = OkStatus();
                        });
                      }
                    },
                    backgroundColor: primaryColor,
                    text: const TextWidget(
                      size: 20,
                      text: "Sign Up",
                      wt: FontWeight.bold,
                      color: pWhiteColor,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TextWidget(
                          size: 15, text: "Already have an Account?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => const SignInPage()),
                              (route) => false);
                        },
                        child: const TextWidget(
                            size: 15, text: " Sign In", wt: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
