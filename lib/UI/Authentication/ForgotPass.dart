import 'package:buz_tracker/UI/Authentication/SignInPage.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/ElevationButton.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:buz_tracker/Service/AuthService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({Key? key}) : super(key: key);

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();
  AuthService authClass = AuthService();

  int state = 0; // 0 = get email, 1 = enter token, 2 = reset password

  ScreenStatus _status = OkStatus();
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      status: _status,
      child: Scaffold(
        backgroundColor: pWhiteColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Reset your Password",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  if (state == 0) ...[
                    TextInput(
                      controller: _emailController,
                      obsecureText: false,
                      title: "Email",
                      hint: "Enter your email",
                    ),
                  ],
                  if (state == 1) ...[
                    TextInput(
                      controller: _tokenController,
                      obsecureText: true,
                      title: "Token",
                      hint: "Enter token received on mail",
                    ),
                  ],
                  if (state == 2) ...[
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
                  ],
                  const SizedBox(
                    height: 40,
                  ),
                  ElevationButton(
                    onTap: () async {
                      try {
                        setState(() {
                          _status = LoadingStatus(toBlur: true);
                        });
                        if (state == 0) {
                          if (_emailController.text.isValidEmail()) {
                            await Supabase.instance.client.auth
                                .resetPasswordForEmail(
                                    _emailController.text.trim());
                            setState(() {
                              state = 1;
                            });
                            showSnakbar(
                                "Token has been sent to your mail!", context);
                          } else {
                            showSnakbar("Enter valid email", context);
                          }
                        } else if (state == 1) {
                          await Supabase.instance.client.auth.verifyOTP(
                              type: OtpType.recovery,
                              email: _emailController.text.trim(),
                              token: _tokenController.text.trim());
                          setState(() {
                            state = 2;
                          });
                        } else if (state == 2) {
                          if (_passwordController.text.trim() ==
                              _cpasswordController.text.trim()) {
                            throw ErrorDescription("Passwords aren't matching");
                          }
                          if (_passwordController.text
                              .trim()
                              .isValidPassword()) {
                            await Supabase.instance.client.auth.updateUser(
                                UserAttributes(
                                    password: _passwordController.text.trim()));
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => const SignInPage()),
                                (route) => false);
                          } else {
                            showSnakbar("Enter valid password", context);
                          }
                        }
                      } catch (e) {
                        showSnakbar(e.toString(), context);
                      }
                      setState(() {
                        _status = OkStatus();
                      });
                    },
                    backgroundColor: primaryColor,
                    text: TextWidget(
                      size: 20,
                      text: state == 0
                          ? "Find Email"
                          : state == 1
                              ? "Verify Token"
                              : "Reset Password",
                      wt: FontWeight.bold,
                      color: pWhiteColor,
                    ),
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
