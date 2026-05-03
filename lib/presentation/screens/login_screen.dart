import 'package:diet_app/Domain/usecases/bmi_calculator.dart';
import 'package:diet_app/presentation/screens/dashboard_screen.dart';
import 'package:diet_app/presentation/screens/forget_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:diet_app/presentation/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _isFormKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _isLoading = false;
  bool emailHasError = false;
  bool passwordHasError = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    if (_googleSignInInitialized) return;

    try {
      await _googleSignIn.initialize();

      if (mounted) {
        setState(() {
          _googleSignInInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('GoogleSignIn.initialize() failed: $e');
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

  Future<void> _handleGoogleSignIn() async {
    if (kIsWeb) {
      if (mounted) {
        _showCenterSnackBar(
          'Google Sign-In on web requires renderButton()',
          isError: true,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // remaining code...
    } catch (e) {
      _showCenterSnackBar('Google Sign-In Failed', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// After successful login, check if the user has completed their profile.
  /// Profile complete   → DashboardScreen (skip BmiCalculator)
  /// Profile incomplete → BmiCalculator
  Future<void> _navigateAfterLogin(String userId) async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('full_name, height_cm, current_weight_kg, gender, activity_level, goal_type')
          .eq('id', userId)
          .maybeSingle();

      final bool profileComplete = profile != null &&
          (profile['full_name'] as String?)?.isNotEmpty == true &&
          profile['height_cm'] != null &&
          profile['current_weight_kg'] != null &&
          profile['gender'] != null &&
          profile['activity_level'] != null &&
          profile['goal_type'] != null;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          profileComplete ? const DashboardScreen() : const BmiCalculator(),
        ),
      );
    } catch (_) {
      // On error, send to BmiCalculator as safe fallback
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BmiCalculator()),
      );
    }
  }

  Future<void> _handleEmailLogin() async {
    if (!_isFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      if (response.user != null && mounted) {
        _showCenterSnackBar('Log In Successful', isError: false);
        // Small delay so snackbar is visible before navigation
        await Future.delayed(const Duration(milliseconds: 800));
        await _navigateAfterLogin(response.user!.id);
      }
    } catch (e) {
      if (mounted) {
        _showCenterSnackBar('Login Failed: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: const Color(0xFF77DD77),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: const Color(0xFF77DD77),
                    child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Image(
                          image: const AssetImage("assets/WhiteLogo.png"),
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                            Icons.fitness_center_outlined,
                            size: 100,
                            color: Colors.white,
                          ),
                        )),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 30),
                      child: Form(
                        key: _isFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Email Address",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                prefixIcon: Icon(Icons.email,
                                    color: emailHasError
                                        ? Colors.red
                                        : const Color(0xFF77DD77)),
                                labelText: "Enter Your Email",
                                labelStyle:
                                const TextStyle(color: Colors.grey),
                                floatingLabelStyle: TextStyle(
                                    color: emailHasError
                                        ? Colors.red
                                        : const Color(0xFF77DD77)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.black26),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF77DD77), width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                    const BorderSide(color: Colors.red)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2)),
                                errorStyle:
                                const TextStyle(color: Colors.red),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() => emailHasError = true);
                                  return "Enter Email";
                                }
                                if (!value.contains("@") ||
                                    !value.contains(".")) {
                                  setState(() => emailHasError = true);
                                  return "Enter valid email";
                                }
                                setState(() => emailHasError = false);
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Password",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: password,
                              cursorRadius: const Radius.circular(20),
                              cursorErrorColor: Colors.red,
                              cursorColor: Colors.black,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              enabled: !_isLoading,
                              onFieldSubmitted: (_) => _handleEmailLogin(),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                prefixIcon: Icon(Icons.lock,
                                    color: passwordHasError
                                        ? Colors.red
                                        : const Color(0xFF77DD77)),
                                labelText: "Enter Your Password",
                                labelStyle:
                                const TextStyle(color: Colors.grey),
                                floatingLabelStyle: TextStyle(
                                    color: passwordHasError
                                        ? Colors.red
                                        : const Color(0xFF77DD77)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.black26),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF77DD77), width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                    const BorderSide(color: Colors.red)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2)),
                                errorStyle:
                                const TextStyle(color: Colors.red),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() => passwordHasError = true);
                                  return "Enter Password";
                                }
                                if (value.length < 6) {
                                  setState(() => passwordHasError = true);
                                  return "Password must be 6 characters";
                                }
                                setState(() => passwordHasError = false);
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const ForgetPasswordScreen()));
                                  },
                                  child: const Text(
                                    "Forget Password ?",
                                    style: TextStyle(
                                      color: Color(0xFF77DD77),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                onPressed:
                                _isLoading ? null : _handleEmailLogin,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFF77DD77),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    )),
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                                    : const Text(
                                  "Sign In",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: Color(0xFF77DD77))),
                                SizedBox(width: 15),
                                Text(
                                  "Sign In With",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF77DD77)),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                    child: Divider(
                                        color: Color(0xFF77DD77))),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: _isLoading
                                      ? null
                                      : _handleGoogleSignIn,
                                  borderRadius: BorderRadius.circular(25),
                                  child: const CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                    AssetImage("assets/google.png"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: Colors.black54),
                                ),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const RegisterPage()));
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                    const Color(0xFF77DD77),
                                  ),
                                  child: const Text(
                                    "Register",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF77DD77),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}