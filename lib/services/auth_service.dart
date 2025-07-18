import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _userKey = 'user_data';
  static const String _guestKey = 'guest_user';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      String firstName = '';
      String lastName = '';
      
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        final nameParts = user.displayName!.split(' ');
        firstName = nameParts.isNotEmpty ? nameParts.first : '';
        lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
      }
      
      DateTime? createdAt;
      DateTime? lastLoginAt;
      
      try {
        createdAt = user.metadata.creationTime;
        lastLoginAt = user.metadata.lastSignInTime;
      } catch (e) {
        createdAt = DateTime.now();
        lastLoginAt = DateTime.now();
      }
      
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        firstName: firstName,
        lastName: lastName,
        photoURL: user.photoURL,
        isEmailVerified: user.emailVerified,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
      );
    }
    
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool(_guestKey) ?? false;
    if (isGuest) {
      return AppUser.guest();
    }
    
    try {
      final storedUserData = prefs.getString(_userKey);
      if (storedUserData != null) {
        final userData = jsonDecode(storedUserData) as Map<String, dynamic>;
        return AppUser.fromJson(userData);
      }
    } catch (e) {
      await _clearUserData();
    }
    
    return null;
  }

  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        
        await user.updateDisplayName('$firstName $lastName');
        
        await user.sendEmailVerification();

        DateTime? createdAt;
        DateTime? lastLoginAt;
        
        try {
          createdAt = user.metadata.creationTime;
          lastLoginAt = user.metadata.lastSignInTime;
        } catch (e) {
          createdAt = DateTime.now();
          lastLoginAt = DateTime.now();
        }

        final appUser = AppUser(
          id: user.uid,
          email: user.email ?? '',
          firstName: firstName,
          lastName: lastName,
          photoURL: user.photoURL,
          isEmailVerified: user.emailVerified,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
        );

        await _saveUserData(appUser);

        return appUser;
      } else {
        throw AuthException('Failed to create user - no user returned from Firebase');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthException('An account with this email already exists. Please sign in instead.');
        case 'weak-password':
          throw AuthException('The password is too weak. Please choose a stronger password.');
        case 'invalid-email':
          throw AuthException('The email address is not valid.');
        case 'operation-not-allowed':
          throw AuthException('Email/password accounts are not enabled. Please contact support.');
        case 'network-request-failed':
          throw AuthException('Network error. Please check your internet connection.');
        default:
          throw AuthException(_getErrorMessage(e));
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      
      throw AuthException('An unexpected error occurred during sign up. Please try again.');
    }
  }

  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      
      final user = credential.user;
      if (user != null) {
        
        String firstName = '';
        String lastName = '';
        
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          final nameParts = user.displayName!.split(' ');
          firstName = nameParts.isNotEmpty ? nameParts.first : '';
          lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
        }
        
        DateTime? createdAt;
        DateTime? lastLoginAt;
        
        try {
          createdAt = user.metadata.creationTime;
          lastLoginAt = user.metadata.lastSignInTime;
        } catch (e) {
          createdAt = DateTime.now();
          lastLoginAt = DateTime.now();
        }
        
        final appUser = AppUser(
          id: user.uid,
          email: user.email ?? '',
          firstName: firstName,
          lastName: lastName,
          photoURL: user.photoURL,
          isEmailVerified: user.emailVerified,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
        );
        
        try {
          await _saveUserData(appUser);
        } catch (e) {
        }
        
        return appUser;
      } else {
        throw AuthException('Failed to sign in - no user returned from Firebase');
      }
    } on FirebaseAuthException catch (e) {    
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('No account found with this email address. Please sign up first.');
        case 'wrong-password':
          throw AuthException('Incorrect password. Please try again.');
        case 'invalid-email':
          throw AuthException('The email address is not valid.');
        case 'user-disabled':
          throw AuthException('This account has been disabled. Please contact support.');
        case 'too-many-requests':
          throw AuthException('Too many failed attempts. Please try again later.');
        case 'network-request-failed':
          throw AuthException('Network error. Please check your internet connection.');
        default:
          throw AuthException(_getErrorMessage(e));
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      
      throw AuthException('An unexpected error occurred during sign in. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearUserData();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e));
    } catch (e) {
      throw AuthException('Failed to reset password: $e');
    }
  }

  Future<AppUser> signInAsGuest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestKey, true);
      
      final guestUser = AppUser.guest();
      await _saveUserData(guestUser);
      return guestUser;
    } catch (e) {
      throw AuthException('Failed to sign in as guest: $e');
    }
  }

  Future<AppUser> convertGuestToUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      await signOut();
      
      return await signUpWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
    } catch (e) {
      throw AuthException('Failed to convert guest to user: $e');
    }
  }

  Future<AppUser> updateUserProfile({
    String? firstName,
    String? lastName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }

      final currentAppUser = await getCurrentAppUser();
      if (currentAppUser == null) {
        throw AuthException('No app user found');
      }

      String? displayName;
      if (firstName != null || lastName != null) {
        final newFirstName = firstName ?? currentAppUser.firstName;
        final newLastName = lastName ?? currentAppUser.lastName;
        displayName = '$newFirstName $newLastName';
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      final updatedUser = currentAppUser.copyWith(
        firstName: firstName,
        lastName: lastName,
        photoURL: photoURL,
      );

      await _saveUserData(updatedUser);
      return updatedUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e));
    } catch (e) {
      throw AuthException('Failed to update profile: $e');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e));
    } catch (e) {
      throw AuthException('Failed to change password: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e));
    } catch (e) {
      throw AuthException('Failed to send email verification: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }

      await user.delete();
      await _clearUserData();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e));
    } catch (e) {
      throw AuthException('Failed to delete account: $e');
    }
  }

  Future<void> clearAllAuthData() async {
    try {
      await _auth.signOut();
      await _clearUserData();
    } catch (e) {
      throw AuthException('Failed to clear authentication data: $e');
    }
  }

  bool get isAuthenticated => _auth.currentUser != null;

  Future<bool> get isGuest async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestKey) ?? false;
  }

  Future<void> initialize() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {}
    } catch (e) {}
  }

  Future<void> _saveUserData(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_guestKey);
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
} 