import 'package:diet_app/main.dart';
import 'package:flutter/material.dart';
import 'package:diet_app/presentation/screens/register_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _isFormKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool emailHasError = false;
  bool passwordHasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Color(0xFF77DD77),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Color(0xFF77DD77),
                    child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Image(
                          image: const AssetImage("assets/logo.png"),
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
                          cursorColor: Color(0xFF77DD77),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              labelText: "Enter Your Email",
                              labelStyle: const TextStyle(color: Colors.grey),
                              floatingLabelStyle: TextStyle(
                                  color: emailHasError
                                      ? Colors.red
                                      : Color(0xFF77DD77)),
                              prefixIcon: Icon(Icons.email,
                                  color: emailHasError
                                      ? Colors.red
                                      : Color(0xFF77DD77)),
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
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2)),
                              errorStyle: const TextStyle(color: Colors.red)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() {
                                emailHasError = true;
                              });
                              return "Enter Email";
                            }
                            if (!value.contains("@")) {
                              setState(() {
                                emailHasError = true;
                              });
                              return "Enter Valid Email";
                            }
                            setState(() {
                              emailHasError = false;
                            });
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
                          onFieldSubmitted: (_) => _handleLogin(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: Icon(Icons.lock,
                                color: passwordHasError
                                    ? Colors.red
                                    : Color(0xFF77DD77)),
                            labelText: "Enter Your Password",
                            labelStyle: const TextStyle(color: Colors.grey),
                            floatingLabelStyle: TextStyle(
                                color: passwordHasError
                                    ? Colors.red
                                    : Color(0xFF77DD77)),
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
                              setState(() {
                                passwordHasError = true;
                              });
                              return "Enter Password";
                            }
                            if (value.length < 6) {
                              setState(() {
                                passwordHasError = true;
                              });
                              return "Password must be 6 characters";
                            }
                            setState(() {
                              passwordHasError = false;
                            });
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Forget Password ?",
                              style: TextStyle(
                                  color: Color(0xFF77DD77),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF77DD77),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                            child: const Text(
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
                              onTap: () {},
                              borderRadius: BorderRadius.circular(25),
                              child: const CircleAvatar(
                                radius: 25,
                                backgroundImage: AssetImage("assets/fb.png"),
                              ),
                            ),
                            const SizedBox(width: 15),
                            InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(25),
                              child: const CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                AssetImage("assets/insta.jpeg"),
                              ),
                            ),
                            const SizedBox(width: 15),
                            InkWell(
                              onTap: () {},
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
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const RegisterPage()));
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFF77DD77),
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

  void _handleLogin() {
    if (_isFormKey.currentState!.validate()) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }
}
