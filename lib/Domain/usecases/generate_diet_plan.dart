import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../presentation/screens/dashboard_screen.dart';

class PreparingPlanScreen extends StatefulWidget {
  const PreparingPlanScreen({super.key});

  @override
  State<PreparingPlanScreen> createState() => _PreparingPlanScreenState();
}

class _PreparingPlanScreenState extends State<PreparingPlanScreen> {
  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    final success = await _createPlan();
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  Future<bool> _createPlan() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showCenterSnackBar('Please login first', isError: true);
        return false;
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final age = (profile['age'] ?? 0) as int;
      final height = (profile['height_cm'] ?? 0).toDouble();
      final weight = (profile['current_weight_kg'] ?? 0).toDouble();

      final gender = (profile['gender'] as String?)?.toLowerCase();
      final activity = (profile['activity_level'] as String?)?.toLowerCase();
      final goal = (profile['goal_type'] as String?)?.toLowerCase();

      if (age == 0 || height == 0 || weight == 0) {
        _showCenterSnackBar('Please complete profile details', isError: true);
        return false;
      }

      if (gender == null || activity == null || goal == null) {
        _showCenterSnackBar('Missing gender/activity/goal', isError: true);
        return false;
      }

      double bmr;
      if (gender == 'male') {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
      } else {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
      }

      double factor = 1.2;
      if (activity == 'moderate') factor = 1.55;
      if (activity == 'high') factor = 1.725;

      final tdee = bmr * factor;

      double targetCalories = tdee;
      if (goal == 'lose') targetCalories = tdee - 500;
      if (goal == 'gain') targetCalories = tdee + 300;

      await Supabase.instance.client.from('profiles').update({
        'daily_calorie_target': targetCalories,
      }).eq('id', user.id);

      await Supabase.instance.client.from('diet_plans').upsert({
        'user_id': user.id,
        'goal_type': goal,
        'activity_level': activity,
        'target_calories': targetCalories,
        'is_active': true,
      });

      await Supabase.instance.client.from('bmr_calculations').insert({
        'user_id': user.id,
        'bmr': bmr,
        'tdee': tdee,
        'weight_kg': weight,
        'height_cm': height,
        'age': age,
        'gender': gender,
      });

      return true;
    } catch (e) {
      _showCenterSnackBar('Plan failed: $e', isError: true);
      return false;
    }
  }

  void _showCenterSnackBar(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade600 : const Color(0xFF77DD77),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF77DD77)),
              ),
              SizedBox(height: 16),
              Text(
                "Preparing your plan...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Please wait a moment",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}