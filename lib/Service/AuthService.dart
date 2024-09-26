import 'package:buz_tracker/Service/SupabaseClient.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _auth = AuthService._internal();
  factory AuthService() {
    return _auth;
  }

  AuthService._internal();

  final client = SupabaseInstance().client;

  static User? getUser() {
    return SupabaseInstance().client.auth.currentUser;
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "889767834962-l9dvkgnd2kipdci1otce86gqcjs1i2d9.apps.googleusercontent.com",
    scopes: ['email'],
  );

  Future<AuthResponse> googleSignIn() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found';
    }
    if (idToken == null) {
      throw 'No ID Token found';
    }

    final res = await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return res;
  }

  Future<AuthResponse> emailSignUp(String email, String pass) async {
    return await client.auth.signUp(
      email: email,
      password: pass,
    );
  }

  Future<AuthResponse> emailSignIn(String email, String pass) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: pass,
    );
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await client.auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
