import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _pendingUsername;
  bool _isSignUp = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      _isAuthenticated = session.isSignedIn;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  // Unified Phone Auth: Send OTP (Sign In)
  Future<void> signInWithPhone(
    String phoneNumber, {
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();
    _pendingUsername = phoneNumber;

    try {
      final result = await Amplify.Auth.signIn(
        username: phoneNumber,
        password: "DummyPassword123!",
      );

      if (result.isSignedIn) {
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
      } else if (result.nextStep.signInStep == AuthSignInStep.confirmSignInWithCustomChallenge ||
                 result.nextStep.signInStep == AuthSignInStep.confirmSignInWithSmsMfaCode) {
        _isSignUp = false;
        _isLoading = false;
        notifyListeners();
        onCodeSent("signin");
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e is AuthException) {
        onError(e.message);
      } else {
        onError(e.toString());
      }
    }
  }

  // Phone Auth Sign Up
  Future<void> signUpWithPhone({
    required String phoneNumber,
    required String password,
    String? email,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();
    _pendingUsername = phoneNumber;

    try {
      final Map<AuthUserAttributeKey, String> userAttributes = {
        AuthUserAttributeKey.phoneNumber: phoneNumber,
      };
      if (email != null && email.isNotEmpty) {
        userAttributes[AuthUserAttributeKey.email] = email;
      }

      final res = await Amplify.Auth.signUp(
        username: phoneNumber,
        password: password,
        options: SignUpOptions(userAttributes: userAttributes),
      );

      if (res.nextStep.signUpStep == AuthSignUpStep.confirmSignUp) {
        _isSignUp = true;
        _isLoading = false;
        notifyListeners();
        onSuccess();
      }
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.message);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  // Verify OTP for both Sign In and Sign Up
  Future<void> verifyOtp(
    String otp, {
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    if (_pendingUsername == null) {
      onError("Session expired. Please try again.");
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      if (_isSignUp) {
        final res = await Amplify.Auth.confirmSignUp(
          username: _pendingUsername!,
          confirmationCode: otp,
        );
        if (res.isSignUpComplete) {
          final signInRes = await Amplify.Auth.signIn(
            username: _pendingUsername!,
            password: "DummyPassword123!",
          );
          if (signInRes.isSignedIn) {
            _isAuthenticated = true;
            _isLoading = false;
            notifyListeners();
            onSuccess();
          }
        }
      } else {
        final res = await Amplify.Auth.confirmSignIn(confirmationValue: otp);
        if (res.isSignedIn) {
          _isAuthenticated = true;
          _isLoading = false;
          notifyListeners();
          onSuccess();
        }
      }
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.message);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  // Email Auth: Sign In
  Future<void> signInWithEmail(
    String email,
    String password, {
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await Amplify.Auth.signIn(username: email, password: password);
      if (res.isSignedIn) {
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        onSuccess();
      }
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.message);
    }
  }

  Future<void> signOut() async {
    await Amplify.Auth.signOut();
    _isAuthenticated = false;
    notifyListeners();
  }
}
