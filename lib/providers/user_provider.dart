import 'package:flutter/material.dart';
import 'package:next_one/data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> fetchUser() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock user data
    _user = UserModel(
      id: '1',
      fullName: 'John Doe',
      phoneNumber: '+1234567890',
    );

    _isLoading = false;
    notifyListeners();
  }
}
