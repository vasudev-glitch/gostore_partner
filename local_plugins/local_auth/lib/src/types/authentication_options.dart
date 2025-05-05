class AuthenticationOptions {
  final bool useErrorDialogs;
  final bool stickyAuth;
  final bool sensitiveTransaction;
  final bool biometricOnly;

  const AuthenticationOptions({
    this.useErrorDialogs = true,
    this.stickyAuth = false,
    this.sensitiveTransaction = false,
    this.biometricOnly = false,
  });

  Map<String, dynamic> toMap() => {
    'useErrorDialogs': useErrorDialogs,
    'stickyAuth': stickyAuth,
    'sensitiveTransaction': sensitiveTransaction,
    'biometricOnly': biometricOnly,
  };
}
