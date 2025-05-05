class AuthMessages {
  const AuthMessages();
}

class AndroidAuthMessages extends AuthMessages {
  final String signInTitle;
  final String cancelButton;
  final String biometricHint;

  const AndroidAuthMessages({
    this.signInTitle = 'Authenticate',
    this.cancelButton = 'Cancel',
    this.biometricHint = 'Touch sensor',
  });

  Map<String, String> toMap() => {
    'signInTitle': signInTitle,
    'cancelButton': cancelButton,
    'biometricHint': biometricHint,
  };
}
