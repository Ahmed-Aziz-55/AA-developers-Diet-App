import 'package:diet_app/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:diet_app/presentation/screens/login_screen.dart';
import 'package:diet_app/presentation/screens/register_screen.dart';
import 'package:diet_app/presentation/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xfkhhukxaqzlavuufkiy.supabase.co',
    anonKey: 'sb_publishable_p136t8aQPfw2V4F0_9tM0g_oKiNOFN-',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diet App',
      initialRoute: '/',
      routes: {
        '/': (context) => const IntroSplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const DashboardScreen(),
      },
    );
  }
}


