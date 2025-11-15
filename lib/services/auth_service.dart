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

      // Insert profile row first (even if email not confirmed)
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
      } catch (profileError) {
        // Profile might already exist, ignore error
        print('Profile insert error (might already exist): $profileError');
      }

      // Try to auto-confirm user via database function if email confirmation is enabled
      // This will work if you have a database function to auto-confirm users
      // Note: This requires the disable_email_confirmation.sql to be run in Supabase
      try {
        await _client.rpc('auto_confirm_user', params: {'user_id': user.id});
        // Wait a bit for the confirmation to process
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (rpcError) {
        // RPC function might not exist, that's okay - user will need to confirm email
        // or you need to disable email confirmation in Supabase Dashboard
        print('Auto-confirm RPC not available: $rpcError');
      }

      // Try to sign in immediately after signup
      // If email confirmation is required, this will fail but user is still created
      try {
        final signInRes = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final signedInUser = signInRes.user ?? _client.auth.currentUser;
        if (signedInUser != null) {
          return signedInUser.id;
        }
      } catch (signInError) {
        // If sign in fails due to email not confirmed, we need to handle it
        final errorString = signInError.toString();
        if (errorString.contains('email_not_confirmed') || 
            errorString.contains('Email not confirmed')) {
          // User created but email not confirmed
          // We'll return the user ID anyway, but the signup screen needs to handle this
          throw Exception(
            'Account created but email confirmation is required. '
            'Please disable email confirmation in Supabase Dashboard > Authentication > Settings > Email Auth > "Enable email confirmations"'
          );
        }
        // Other sign in errors, rethrow
        throw signInError;
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

  /// Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final profile = await _client
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single();
      return Map<String, dynamic>.from(profile as Map);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? address,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;

      if (updateData.isEmpty) {
        return true; // Nothing to update
      }

      await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Stream for auth state changes (mapped to `bool` - logged in or not)
  Stream<bool> authStateChanges() =>
      _client.auth.onAuthStateChange.map((state) => state.session != null);
}
