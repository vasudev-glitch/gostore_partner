import 'package:flutter/services.dart';
import 'package:local_plugins/local_auth/lib/src/types/auth_messages.dart';
import 'package:local_plugins/local_auth/lib/src/types/biometric_type.dart';
import 'package:local_plugins/local_auth/lib/src/types/authentication_options.dart';

class MethodChannelLocalAuth {
  static const MethodChannel _channel = MethodChannel('local_auth');

  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
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

  Future<List<BiometricType>> getAvailableBiometrics() async {
    final List<dynamic> result = await _channel.invokeMethod('getAvailableBiometrics');
    return result.map((e) => BiometricType.values.byName(e)).toList();
  }

  Future<bool> stopAuthentication() async {
    final result = await _channel.invokeMethod('stopAuthentication');
    return result as bool;
  }
}
