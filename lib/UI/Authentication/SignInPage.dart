import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/Authentication/ForgotPass.dart';
import 'package:buz_tracker/UI/Authentication/ProfilePage.dart';
import 'package:buz_tracker/UI/Dashboard.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/ElevationButton.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:buz_tracker/Service/AuthService.dart';
import 'package:buz_tracker/UI/Authentication/SignUpPage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AuthService authClass = AuthService();

  ScreenStatus _status = OkStatus();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pWhiteColor,
      resizeToAvoidBottomInset: false,
      body: ScreenWrapper(
        status: _status,
        child: SafeArea(
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
                      size: 22, text: "Welcome back,", wt: FontWeight.bold),
                  const TextWidget(size: 28, text: "Continue to our app"),
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

                        if (userExists.isEmpty) {
                          throw ErrorDescription("No user exists");
                        }

                        final user = UserModel.fromJson(userExists.first);

                        if (user.rwp == null ||
                            user.rwp!.isEmpty ||
                            user.rwp!.first.isDisabled) {
                          throw ErrorDescription(
                              "You're not associated with any organisation yet");
                        }

                        await UserService().setUser(user);

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  user.phoneNumber == null || user.name == null
                                      ? const ProfilePage()
                                      : const Dashboard(),
                            ),
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
                  const SizedBox(
                    height: 40,
                  ),
                  ElevationButton(
                    onTap: () async {
                      try {
                        setState(() {
                          _status = LoadingStatus(toBlur: true);
                        });
                        if (!_emailController.text.isValidEmail()) {
                          throw ErrorDescription("Invalid email");
                        }
                        if (!_passwordController.text.isValidPassword()) {
                          throw ErrorDescription("Invalid password");
                        }

                        final res = await authClass.emailSignIn(
                            _emailController.text, _passwordController.text);

                        if (res.user == null || res.user?.email == null) {
                          throw ErrorDescription("Error while registering!");
                        }

                        final userExists =
                            await DBService().findUserByEmail(res.user!.email!);

                        if (userExists.isEmpty) {
                          throw ErrorDescription("No user exists");
                        }

                        final user = UserModel.fromJson(userExists.first);

                        if (user.rwp == null ||
                            user.rwp!.isEmpty ||
                            user.rwp!.first.isDisabled) {
                          throw ErrorDescription(
                              "You're not associated with any organisation yet");
                        }

                        await UserService().setUser(user);

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => const Dashboard()),
                            (route) => false);
                      } catch (e) {
                        showSnakbar(e.toString(), context);
                      }
                      setState(() {
                        _status = OkStatus();
                      });
                    },
                    backgroundColor: primaryColor,
                    text: const TextWidget(
                      size: 20,
                      text: "Sign In",
                      wt: FontWeight.bold,
                      color: pWhiteColor,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TextWidget(
                          size: 15, text: "If you don't have an Account?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => const SignUpPage()),
                              (route) => false);
                        },
                        child: const TextWidget(
                            size: 15, text: " Sign Up", wt: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const ForgotPass()),
                      );
                    },
                    child: const TextWidget(
                        size: 15,
                        text: "Forgot Password?",
                        wt: FontWeight.bold),
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
