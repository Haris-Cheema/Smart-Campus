import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_campus/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _googleInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkAuthState();
  }

  // Initialize Google Sign-In (must be called once)
  Future<void> _ensureGoogleInitialized() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize(
        clientId: '84042858582-psgrj7f0n9ipjl62dttq73bcrkunihih.apps.googleusercontent.com',
        serverClientId: '84042858582-psgrj7f0n9ipjl62dttq73bcrkunihih.apps.googleusercontent.com',
      );
      _googleInitialized = true;
    }
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

  // Build user model from Firestore (Ground Truth) or Local Prefs
  Future<void> _loadOrCreateUserModel(User firebaseUser) async {
    try {
      // 1. Load Local Data first (Immediate fallback)
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('user_data');
      if (savedData != null) {
        final localUser = UserModel.fromJson(json.decode(savedData));
        if (localUser.id == firebaseUser.uid) {
          _currentUser = localUser;
          notifyListeners();
        }
      }

      // 2. Attempt to sync with Firestore
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (doc.exists) {
          _currentUser = UserModel.fromJson(doc.data()!);
          
          // Get best available photo from providers
          String? bestPhotoURL = firebaseUser.photoURL;
          if (bestPhotoURL == null || bestPhotoURL.isEmpty) {
            for (final profile in firebaseUser.providerData) {
              if (profile.photoURL != null && profile.photoURL!.isNotEmpty) {
                bestPhotoURL = profile.photoURL;
                break;
              }
            }
          }

          if ((_currentUser!.avatarUrl.isEmpty) && 
              (bestPhotoURL != null && bestPhotoURL.isNotEmpty)) {
            _currentUser = _currentUser!.copyWith(avatarUrl: bestPhotoURL);
            await _firestore.collection('users').doc(firebaseUser.uid).set(_currentUser!.toJson(), SetOptions(merge: true));
          }
        } else if (_currentUser == null) {
          // No local data and no Firestore doc — create new
          _currentUser = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Student',
            email: firebaseUser.email ?? '',
            studentId: '19-NTU-CS-0000',
            department: 'Computer Science',
            avatarUrl: firebaseUser.photoURL ?? '',
          );
          await _firestore.collection('users').doc(firebaseUser.uid).set(_currentUser!.toJson());
        }
      } catch (firestoreError) {
        debugPrint('Firestore Sync Warning: $firestoreError. Using local data fallback.');
        // If firestore fails but we still don't have a user, create a minimal local one
        _currentUser ??= UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Student',
          email: firebaseUser.email ?? '',
          studentId: '19-NTU-CS-0000',
          department: 'Computer Science',
          avatarUrl: firebaseUser.photoURL ?? '',
        );
      }

      await _saveSession(_currentUser!);
      notifyListeners();
    } catch (e) {
      debugPrint('Critical Load user error: $e');
      _error = 'Failed to load profile. Please check Firebase Console.';
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
        // Update Firebase Auth profile
        await credential.user!.updateDisplayName(name);

        // Create user model
        _currentUser = UserModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          studentId: studentId,
          department: department,
        );

        // Save to Firestore
        await _firestore.collection('users').doc(_currentUser!.id).set(_currentUser!.toJson());

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

  // ─── GOOGLE SIGN-IN ──────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _ensureGoogleInitialized();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _loadOrCreateUserModel(userCredential.user!);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Google Sign-In failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _error = 'Google Sign-In failed: ${e.code}';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _firebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Google Sign-In failed: $e';
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
    String? avatarUrl,
  }) async {
    if (_currentUser == null) {
      _error = 'No user logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String? finalAvatarUrl = avatarUrl;

      // 1. Image Handling (Skip Storage upload if on Free Plan without Storage enabled)
      if (avatarUrl != null && !avatarUrl.startsWith('http')) {
        try {
          final File file = File(avatarUrl);
          if (await file.exists()) {
            // Attempt upload but fallback to local path if it fails
            try {
              final String fileName = '${_currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
              final Reference ref = _storage.ref().child('avatars').child(fileName);
              await ref.putFile(file);
              finalAvatarUrl = await ref.getDownloadURL();
            } catch (storageError) {
              debugPrint('Storage disabled or failed: $storageError. Using local path instead.');
              // Keep finalAvatarUrl as the local path (avatarUrl)
              finalAvatarUrl = avatarUrl;
            }
          }
        } catch (e) {
          debugPrint('Image access error: $e');
        }
      }

      // 2. Update Firebase Auth profile (Best effort)
      try {
        if (name != null) await _firebaseAuth.currentUser?.updateDisplayName(name);
        if (finalAvatarUrl != null && finalAvatarUrl.startsWith('http')) {
          await _firebaseAuth.currentUser?.updatePhotoURL(finalAvatarUrl);
        }
      } catch (e) {
        debugPrint('Auth Sync Warning: $e');
      }

      // 3. Update User Model
      _currentUser = _currentUser!.copyWith(
        name: name,
        department: department,
        studentId: studentId,
        avatarUrl: finalAvatarUrl,
      );

      // 4. Save to Firestore (Ground Truth)
      try {
        await _firestore
            .collection('users')
            .doc(_currentUser!.id)
            .set(_currentUser!.toJson(), SetOptions(merge: true));
      } catch (firestoreError) {
        debugPrint('Firestore Sync Failed: $firestoreError');
        // We continue because local session will still work
      }

      // 5. Save local session (This ensures it works on this device)
      await _saveSession(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      _error = 'Failed to update profile locally';
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
      if (_googleInitialized) await _googleSignIn.disconnect();
      await _firebaseAuth.signOut();
    } catch (e) {}

    await _clearSession();
    _currentUser = null;
    _isLoggedIn = false;
    _error = null;

    _isLoading = false;
    notifyListeners();
  }

  void clearError() => { _error = null, notifyListeners() };

  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'invalid-credential': return 'Invalid email or password.';
      case 'email-already-in-use': return 'This email is already registered.';
      case 'weak-password': return 'Password is too weak.';
      case 'invalid-email': return 'Invalid email format.';
      case 'too-many-requests': return 'Too many attempts. Try later.';
      case 'network-request-failed': return 'Network error.';
      default: return 'Authentication error: $code';
    }
  }
}
