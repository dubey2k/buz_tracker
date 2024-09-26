import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInstance {
  static final SupabaseInstance _supa = SupabaseInstance._internal();

  factory SupabaseInstance() {
    return _supa;
  }

  SupabaseInstance._internal();

  final client = Supabase.instance.client;

  getUser() {
    return client.auth.currentUser;
  }
}
