import 'package:buz_tracker/Service/SupabaseClient.dart';
import 'package:buz_tracker/helper/CustomTheme.dart';
import 'package:buz_tracker/model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buz_tracker/UI/SplashScreen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final themeProvider = Provider<CustomTheme>((ref) => CustomTheme());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Supabase.initialize(
      url: 'https://qahhhrfvquiwcucrxiey.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFhaGhocmZ2cXVpd2N1Y3J4aWV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkxMTg5MzUsImV4cCI6MjAzNDY5NDkzNX0.DlRaySMxVTaYLyhfHP9Q-VQlWKpRW7kZ13jS-2WgKEo');

  SupabaseInstance();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(RoleWithPermissionAdapter());

  runApp(
    ProviderScope(
      child: Consumer(builder: (context, ref, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ref.watch(themeProvider).curTheme,
          home: const SplashScreen(),
        );
      }),
    ),
  );
}
