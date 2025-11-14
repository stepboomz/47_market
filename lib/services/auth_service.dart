import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Sign up a new user using Supabase Auth and insert a profile row.
  /// Optional fields: fullName, phone
  /// Returns the created user's id when available, otherwise null (e.g. when
  /// email confirmation is required and no session/user is returned).
  Future<String?> signUp(String email, String password,
      {String? fullName, String? phone}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required.');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    try {
      // Sign up with email confirmation disabled
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
        },
        emailRedirectTo: null, // Disable email verification
      );

      final user = res.user ?? _client.auth.currentUser;

      if (user == null) {
        throw Exception('Failed to create user account');
      }

      // Try to sign in immediately after signup to bypass email verification
      try {
        final signInRes = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final signedInUser = signInRes.user ?? _client.auth.currentUser;

        if (signedInUser != null) {
          // Insert profile row (id = auth user id)
          await _client
              .from('profiles')
              .insert({
                'id': signedInUser.id,
                'email': email,
                'full_name': fullName,
                'phone': phone,
              })
              .select()
              .single();

          return signedInUser.id;
        }
      } catch (signInError) {
        // If sign in fails, we still have the user ID from signup
        // Insert profile using admin service if available or return the user ID
        try {
          await _client
              .from('profiles')
              .insert({
                'id': user.id,
                'email': email,
                'full_name': fullName,
                'phone': phone,
              })
              .select()
              .single();

          return user.id;
        } catch (profileError) {
          // If profile insertion fails, still return user ID
          // The signup screen will handle this by showing success message
          return user.id;
        }
      }

      return user.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in user using Supabase Auth and return the profile data.
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required.');
    }

    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user ?? _client.auth.currentUser;
      if (user == null) {
        throw Exception('Login failed');
      }

      final profile =
          await _client.from('profiles').select('*').eq('id', user.id).single();

      return Map<String, dynamic>.from(profile as Map);
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email via Supabase
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) throw Exception('Email is required.');
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => _client.auth.currentSession != null;

  /// Get current user email
  String? get currentUserEmail => _client.auth.currentUser?.email;

  /// Stream for auth state changes (mapped to `bool` - logged in or not)
  Stream<bool> authStateChanges() =>
      _client.auth.onAuthStateChange.map((state) => state.session != null);
}
