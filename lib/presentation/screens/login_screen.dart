import 'package:diet_app/presentation/screens/forget_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:diet_app/presentation/screens/register_screen.dart';
import 'package:diet_app/main.dart' show HomePage;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // v7: use the singleton, not a constructor
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      // v7: initialize() must be called exactly once before any other method
      await _googleSignIn.initialize();
      if (mounted) setState(() => _googleSignInInitialized = true);
    } catch (e) {
      debugPrint('GoogleSignIn.initialize() failed: $e');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // Ensure initialized before proceeding
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize();
        _googleSignInInitialized = true;
      }

      // v7: authenticate() replaces signIn() — throws GoogleSignInException on cancel/error
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // v7: authentication is now SYNCHRONOUS (no await)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to retrieve ID token from Google.');
      }

      // v7: access token is obtained via authorizationClient separately
      String? accessToken;
      try {
        final authorization = await _googleSignIn.authorizationClient
            .authorizationForScopes(['email', 'profile']);
        accessToken = authorization?.accessToken;
      } catch (_) {
        // accessToken is optional for Supabase — safe to continue without it
      }

      final AuthResponse response =
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In Successful!'),
            backgroundColor: Color(0xFF77DD77),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on GoogleSignInException catch (e) {
      // Silently ignore user-cancelled sign-in
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Google Sign-In Failed: ${e.description ?? e.code.name}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Successful!'),
            backgroundColor: Color(0xFF77DD77),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
                  ),
                ),
              ],
            ),
            SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.only(top: 230),
                  child: Form(
                    key: _isFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back!",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Email Address",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: email,
                          cursorErrorColor: Colors.red,
                          cursorRadius: const Radius.circular(20),
                          cursorColor: const Color(0xFF77DD77),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              labelText: "Enter Your Email",
                              labelStyle: const TextStyle(color: Colors.grey),
                              floatingLabelStyle: TextStyle(
                                  color: emailHasError
                                      ? Colors.red
                                      : const Color(0xFF77DD77)),
                              prefixIcon: Icon(Icons.email,
                                  color: emailHasError
                                      ? Colors.red
                                      : const Color(0xFF77DD77)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                const BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: Color(0xFF77DD77), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2)),
                              errorStyle: const TextStyle(color: Colors.red)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() => emailHasError = true);
                              return "Enter Email";
                            }
                            if (!value.contains("@")) {
                              setState(() => emailHasError = true);
                              return "Enter Valid Email";
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
                            labelStyle: const TextStyle(color: Colors.grey),
                            floatingLabelStyle: TextStyle(
                                color: passwordHasError
                                    ? Colors.red
                                    : const Color(0xFF77DD77)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                              const BorderSide(color: Colors.black26),
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
                            errorStyle: const TextStyle(color: Colors.red),
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
                            onPressed: _isLoading ? null : _handleEmailLogin,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF77DD77),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                            Expanded(child: Divider(color: Color(0xFF77DD77))),
                            SizedBox(width: 15),
                            Text(
                              "Sign In With",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF77DD77)),
                            ),
                            SizedBox(width: 15),
                            Expanded(child: Divider(color: Color(0xFF77DD77))),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: _isLoading ? null : _handleGoogleSignIn,
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
                                foregroundColor: const Color(0xFF77DD77),
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