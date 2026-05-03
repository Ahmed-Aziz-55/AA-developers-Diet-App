import 'dart:async';
import 'package:diet_app/Domain/usecases/bmi_calculator.dart';
import 'package:diet_app/presentation/screens/dashboard_screen.dart';
import 'package:diet_app/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IntroSplashScreen extends StatefulWidget {
  const IntroSplashScreen({super.key});

  @override
  State<IntroSplashScreen> createState() => _IntroSplashScreenState();
}

class _IntroSplashScreenState extends State<IntroSplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Zoom In Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // After 2 seconds, check session and navigate accordingly
    Timer(const Duration(seconds: 2), () {
      if (mounted) _checkSessionAndNavigate();
    });
  }

  /// Checks if a Supabase session exists.
  /// If yes → checks if the user has completed their profile.
  ///   - Profile complete   → DashboardScreen
  ///   - Profile incomplete → BmiCalculator (profile setup)
  /// If no  → LoginPage
  Future<void> _checkSessionAndNavigate() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      // No active session → go to login
      _navigateTo(const LoginPage());
      return;
    }

    // Session exists → check profile completeness
    try {
      final userId = session.user.id;
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('full_name, height_cm, current_weight_kg, gender, activity_level, goal_type')
          .eq('id', userId)
          .maybeSingle(); // returns null if row doesn't exist

      final bool profileComplete = profile != null &&
          (profile['full_name'] as String?)?.isNotEmpty == true &&
          profile['height_cm'] != null &&
          profile['current_weight_kg'] != null &&
          profile['gender'] != null &&
          profile['activity_level'] != null &&
          profile['goal_type'] != null;

      if (profileComplete) {
        _navigateTo(const DashboardScreen());
      } else {
        _navigateTo(const BmiCalculator());
      }
    } catch (_) {
      // On any error fall back to login
      _navigateTo(const LoginPage());
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/IntroSplashScreen.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}