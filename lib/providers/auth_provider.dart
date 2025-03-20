import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? _user;

  AuthProvider(this._authService);

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      Map<String, dynamic> result =
          await _authService.signInWithEmailAndPassword(email, password);

      if (result['success']) {
        _user = result['user'];
        _isLoading = false;
        // notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        // notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();

    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  // Send OTP
  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      Map<String, dynamic> result = await _authService.sendOTP(phoneNumber);

      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      Map<String, dynamic> result =
          await _authService.verifyOTP(phoneNumber, otp);

      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
