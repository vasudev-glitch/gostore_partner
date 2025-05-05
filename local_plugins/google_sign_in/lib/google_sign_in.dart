library google_sign_in;

import 'src/google_sign_in_interface.dart';
import 'src/google_sign_in_user_data.dart';

export 'src/google_sign_in_user_data.dart';

class GoogleSignIn {
  static final GoogleSignIn _instance = GoogleSignIn._internal();
  static GoogleSignIn get instance => _instance;

  late final GoogleSignInInterface _delegate;

  GoogleSignIn._internal();

  void configure(GoogleSignInInterface delegate) {
    _delegate = delegate;
  }

  Future<void> init({
    String? clientId,
    String? hostedDomain,
    List<String> scopes = const <String>[],
    SignInOption signInOption = SignInOption.standard,
  }) {
    return _delegate.init(
      clientId: clientId,
      hostedDomain: hostedDomain,
      scopes: scopes,
      signInOption: signInOption,
    );
  }

  Future<GoogleSignInUserData?> signIn() async {
    final Map<String, dynamic>? data = await _delegate.signIn();
    return data == null ? null : GoogleSignInUserData.fromJson(data);
  }

  Future<GoogleSignInUserData?> signInSilently() async {
    final Map<String, dynamic>? data = await _delegate.signInSilently();
    return data == null ? null : GoogleSignInUserData.fromJson(data);
  }

  Future<void> signOut() => _delegate.signOut();
}
