import 'package:shared_preferences/shared_preferences.dart';
//import '../models/user.dart';
import 'mysql_database_service.dart';

class AuthService {
  final ApiDatabaseService _databaseService;

  AuthService(this._databaseService);

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') != null;
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Call database service
      Map<String, dynamic> result =
          await _databaseService.signInWithEmailAndPassword(email, password);

      if (result['success']) {
        // Save user ID to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', "${result['user']['id']}");
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Send OTP to phone number
  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      // Call database service
      return await _databaseService.sendOTP(phoneNumber);
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      // Call database service
      Map<String, dynamic> result =
          await _databaseService.verifyOTP(phoneNumber, otp);

      if (result['success']) {
        // Save user data to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', result['userData']['id']);
        await prefs.setString(
            'userRole', result['userData']['role'] ?? 'driver');
        await prefs.setString('userName', result['userData']['name'] ?? '');

        if (result['userData']['driverId'] != null) {
          await prefs.setString('driverId', result['userData']['driverId']);
        }
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Get current driver ID
  Future<String?> getCurrentDriverId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('driverId');
  }
}
