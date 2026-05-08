import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_campus/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _loadSession();
  }

  // Load saved session from SharedPreferences
  Future<void> _loadSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        _currentUser = UserModel.fromJson(json.decode(userData));
        _isLoggedIn = true;
      }
    } catch (e) {
      _error = 'Failed to load session';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save session to SharedPreferences
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }

  // Clear session
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  // Validate student ID
  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) return 'Student ID is required';
    if (value.length < 4) return 'Enter a valid student ID';
    return null;
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      if (email.isEmpty || password.isEmpty) {
        _error = 'Please fill in all fields';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Simulated authentication — in production this would call a real API
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: email.split('@').first.replaceAll('.', ' '),
        email: email,
        studentId: '19-NTU-CS-1122',
        department: 'Computer Science',
      );

      _currentUser = user;
      _isLoggedIn = true;
      await _saveSession(user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String studentId,
    String department = 'Computer Science',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        studentId: studentId,
        department: department,
      );

      _currentUser = user;
      _isLoggedIn = true;
      await _saveSession(user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? department,
    String? studentId,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = _currentUser!.copyWith(
        name: name,
        department: department,
        studentId: studentId,
      );
      await _saveSession(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _clearSession();
    _currentUser = null;
    _isLoggedIn = false;
    _error = null;

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
