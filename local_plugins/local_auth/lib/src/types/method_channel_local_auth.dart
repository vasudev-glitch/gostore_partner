import 'package:flutter/services.dart';
import 'authentication_options.dart';
import 'auth_messages.dart';
import 'biometric_type.dart';

class MethodChannelLocalAuth {
  static const MethodChannel _channel = MethodChannel('local_auth');

  /// Triggers biometric authentication with provided options
  Future<bool> authenticate({
    required String localizedReason,
    required List<AuthMessages> authMessages,
    required AuthenticationOptions options,
  }) async {
    final result = await _channel.invokeMethod('authenticateWithBiometrics', {
      'localizedReason': localizedReason,
      'useErrorDialogs': options.useErrorDialogs,
      'stickyAuth': options.stickyAuth,
      'sensitiveTransaction': options.sensitiveTransaction,
      'biometricOnly': options.biometricOnly,
    });

    return result as bool;
  }

  /// Returns available biometric types (e.g., fingerprint, face)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    final List<dynamic> result = await _channel.invokeMethod('getAvailableBiometrics');
    return result.map((e) => BiometricType.values.byName(e)).toList();
  }

  /// Stops any ongoing biometric authentication session
  Future<bool> stopAuthentication() async {
    final result = await _channel.invokeMethod('stopAuthentication');
    return result as bool;
  }
}
