import 'package:buz_tracker/Service/SupabaseClient.dart';
import 'package:buz_tracker/helper/CustomTheme.dart';
import 'package:buz_tracker/helper/api-keys.dart';
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
      url: apiKeys["SUPABASE_URL"] ?? "",
      anonKey: apiKeys["SUPABASE_ANON_KEY"] ?? "");

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
