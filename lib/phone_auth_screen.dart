import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:next_one/screens/home/home_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  bool otpSent = false;
  bool _isLoading = false;
  // Differentiates between a new user signing up vs. an existing user signing in.
  bool _isSignUp = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.redAccent, content: Text(message)),
    );
  }

  Future<void> sendOTP() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final username = phoneController.text.trim();

    try {
      // First, try to sign in. This will send an OTP if the user already exists.
      await Amplify.Auth.signIn(
        username: username,
        password: "DummyPassword123!",
      );
      setState(() {
        otpSent = true;
        _isSignUp = false; // This is a sign-in flow
      });
    } on UserNotFoundException {
      // If user is not found, this is a new user. Proceed with sign up.
      try {
        await Amplify.Auth.signUp(
          username: username,
          password:
              "DummyPassword123!", // Cognito requires a password for this flow
          options: SignUpOptions(
            userAttributes: {AuthUserAttributeKey.phoneNumber: username},
          ),
        );
        setState(() {
          otpSent = true;
          _isSignUp = true; // This is a sign-up flow
        });
      } on AuthException catch (e) {
        _showError(e.message);
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> verifyOTP() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        // Verifying a new user's sign-up
        final result = await Amplify.Auth.confirmSignUp(
          username: phoneController.text.trim(),
          confirmationCode: otpController.text.trim(),
        );
        if (result.isSignUpComplete) {
          // After confirming sign-up, sign them in
          await _signInAfterSignUp();
        }
      } else {
        // Verifying an existing user's sign-in
        final result = await Amplify.Auth.confirmSignIn(
          confirmationValue: otpController.text.trim(),
        );
        if (result.isSignedIn) {
          _navigateToHome();
        }
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInAfterSignUp() async {
    try {
      final result = await Amplify.Auth.signIn(
        username: phoneController.text.trim(),
        password: "DummyPassword123!",
      );
      if (result.isSignedIn) {
        _navigateToHome();
      }
    } on AuthException catch (e) {
      _showError(e.message);
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone OTP Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number (+91xxxxxxxxxx)",
              ),
              keyboardType: TextInputType.phone,
              enabled: !_isLoading, // Disable when loading
            ),
            if (otpSent)
              TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: "Enter OTP"),
                keyboardType: TextInputType.number,
                enabled: !_isLoading, // Disable when loading
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : (otpSent ? verifyOTP : sendOTP),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(otpSent ? "Verify OTP" : "Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
