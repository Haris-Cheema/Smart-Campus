import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_campus/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkAuthState();
  }

  // Listen to Firebase auth state changes
  void _checkAuthState() {
    _isLoading = true;
    notifyListeners();

    _firebaseAuth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // User is signed in — load or create user model
        await _loadOrCreateUserModel(user);
        _isLoggedIn = true;
      } else {
        _currentUser = null;
        _isLoggedIn = false;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  // Build user model from Firebase user + saved preferences
  Future<void> _loadOrCreateUserModel(User firebaseUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('user_data');

      if (savedData != null) {
        _currentUser = UserModel.fromJson(json.decode(savedData));
        // Ensure email stays in sync
        _currentUser = _currentUser!.copyWith(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? _currentUser!.email,
        );
      } else {
        _currentUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Student',
          email: firebaseUser.email ?? '',
          studentId: '19-NTU-CS-0000',
          department: 'Computer Science',
        );
      }
      await _saveSession(_currentUser!);
    } catch (e) {
      _error = 'Failed to load user data';
    }
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

  // ─── LOGIN with Firebase ─────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await _loadOrCreateUserModel(credential.user!);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Login failed — no user returned';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _firebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── REGISTER with Firebase ──────────────────────────────────────
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
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user model
        _currentUser = UserModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          studentId: studentId,
          department: department,
        );

        _isLoggedIn = true;
        await _saveSession(_currentUser!);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Registration failed — no user returned';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _firebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── UPDATE PROFILE ──────────────────────────────────────────────
  Future<bool> updateProfile({
    String? name,
    String? department,
    String? studentId,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Update Firebase display name if name changed
      if (name != null && _firebaseAuth.currentUser != null) {
        await _firebaseAuth.currentUser!.updateDisplayName(name);
      }

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

  // ─── LOGOUT ──────────────────────────────────────────────────────
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      // Continue even if sign out fails
    }

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

  // ─── User-friendly error messages ────────────────────────────────
  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'Authentication error: $code';
    }
  }
}
