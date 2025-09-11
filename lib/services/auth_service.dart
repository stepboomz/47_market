import 'dart:async';

class AuthService {
  // Simple in-memory authentication state
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  /// Signs up a user with email and password.
  Future<void> signUp(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simple validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required.');
      }
      
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }
      
      // Simulate successful signup
      _isLoggedIn = true;
      _currentUserEmail = email;
      _authStateController.add(true);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Logs in a user with email and password.
  Future<void> signIn(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simple validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required.');
      }
      
      // Simulate successful login
      _isLoggedIn = true;
      _currentUserEmail = email;
      _authStateController.add(true);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Sends a password reset email to the user.
  Future<void> resetPassword(String email) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      if (email.isEmpty) {
        throw Exception('Email is required.');
      }
      
      // Simulate successful password reset
      // In a real app, this would send an email
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Logs out the currently signed-in user.
  Future<void> signOut() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      _isLoggedIn = false;
      _currentUserEmail = null;
      _authStateController.add(false);
    } catch (e) {
      throw Exception('Failed to log out. Please try again.');
    }
  }

  /// Checks if a user is currently logged in.
  bool get isLoggedIn => _isLoggedIn;
  
  /// Gets the current user email.
  String? get currentUserEmail => _currentUserEmail;

  /// Stream to listen for authentication state changes.
  Stream<bool> authStateChanges() => _authStateController.stream;
  
  /// Dispose the stream controller
  void dispose() {
    _authStateController.close();
  }
}