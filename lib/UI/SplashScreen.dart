import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/Authentication/SignInPage.dart';
import 'package:buz_tracker/UI/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:buz_tracker/helper/SizeConfig.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => navigate(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage("assets/logo/logo.png"),
          height: 300,
        ),
      ),
    );
  }

  void navigate(context) async {
    SizeConfig.init(context);
    final user = await UserService().getUserInit();
    await Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              user == null ? const SignInPage() : const Dashboard(),
        ),
      );
    });
  }
}
