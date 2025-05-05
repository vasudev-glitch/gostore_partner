import 'package:flutter/services.dart';

enum SignInOption {
  standard,
  games,
}

abstract class GoogleSignInInterface {
  Future<void> init({
    String? clientId,
    String? hostedDomain,
    List<String> scopes,
    SignInOption signInOption,
  });

  Future<Map<String, dynamic>?> signIn();
  Future<Map<String, dynamic>?> signInSilently();
  Future<void> signOut();
}
