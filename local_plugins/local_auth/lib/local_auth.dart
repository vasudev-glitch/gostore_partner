library local_auth;

export 'src/types/biometric_type.dart';
export 'src/types/auth_messages.dart';
export 'src/types/authentication_options.dart';

import 'src//types/method_channel_local_auth.dart';
import 'src/types/authentication_options.dart';
import 'src/types/auth_messages.dart';
import 'src/types/biometric_type.dart';

/// ✅ Public API used in your app
class LocalAuthentication {
  final _auth = MethodChannelLocalAuth();

  /// Starts biometric authentication with options
  Future<bool> authenticate({
    required String localizedReason,
    List<AuthMessages> authMessages = const <AuthMessages>[],
    AuthenticationOptions options = const AuthenticationOptions(),
  }) {
    return _auth.authenticate(
      localizedReason: localizedReason,
      authMessages: authMessages,
      options: options,
    );
  }

  /// Checks available biometric types (Face ID, Fingerprint)
  Future<List<BiometricType>> getAvailableBiometrics() {
    return _auth.getAvailableBiometrics();
  }

  /// Cancels any ongoing biometric prompt
  Future<bool> stopAuthentication() {
    return _auth.stopAuthentication();
  }

  /// Whether device supports any biometric methods
  Future<bool> get canCheckBiometrics async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.isNotEmpty;
  }
}
