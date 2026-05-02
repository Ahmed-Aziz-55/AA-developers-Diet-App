import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> handleDeepLink(Uri deepLink) async {
    if (deepLink.path.contains('reset-password')) {
      final code = deepLink.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        try {
          await Supabase.instance.client.auth.exchangeCodeForSession(code);
          debugPrint('Password reset session established');
        } catch (e) {
          debugPrint('Error exchanging code: $e');
        }
      }
    }
  }
}