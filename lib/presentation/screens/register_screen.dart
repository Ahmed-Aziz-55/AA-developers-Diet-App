import 'package:flutter/material.dart';
import 'package:diet_app/presentation/screens/login_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _isFormKey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool emailHasError = false;
  bool passwordHasError = false;
  bool confirmPasswordHasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                  height: 200,
                  width: 200,
                  child: Image(
                    image: const AssetImage("assets/logo1.png"),
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.fitness_center_outlined,
                      size: 100,
                      color: Color(0xFF77DD77),
                    ),
                  )),
              const SizedBox(height: 10),
              Form(
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
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        labelText: "Enter Your Email",
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(
                            color:
                                emailHasError ? Colors.red : Color(0xFF77DD77)),
                        prefixIcon: Icon(Icons.email,
                            color:
                                emailHasError ? Colors.red : Color(0xFF77DD77)),
                        errorStyle: const TextStyle(color: Colors.red),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Color(0xFF77DD77), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            emailHasError = true;
                          });
                          return "Enter Email";
                        }
                        if (!value.contains("@") || !value.contains(".")) {
                          setState(() {
                            emailHasError = true;
                          });
                          return "Enter valid email";
                        }
                        setState(() {
                          emailHasError = false;
                        });
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Password",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        labelText: "Enter Your Password",
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(
                          color:
                              passwordHasError ? Colors.red : Color(0xFF77DD77),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color:
                              passwordHasError ? Colors.red : Color(0xFF77DD77),
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Color(0xFF77DD77), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
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
                          return "Password must be at least 6 characters";
                        }
                        setState(() {
                          passwordHasError = false;
                        });
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Confirm Password",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: confirmPassword,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleRegister(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        labelText: "Confirm Your Password",
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(
                          color: confirmPasswordHasError
                              ? Colors.red
                              : Color(0xFF77DD77),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_reset,
                          color: confirmPasswordHasError
                              ? Colors.red
                              : Color(0xFF77DD77),
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Color(0xFF77DD77), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            confirmPasswordHasError = true;
                          });
                          return "Confirm Password";
                        }
                        if (value != password.text) {
                          setState(() {
                            confirmPasswordHasError = true;
                          });
                          return "Passwords do not match";
                        }
                        setState(() {
                          confirmPasswordHasError = false;
                        });
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF77DD77),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            )),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
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
                    const SizedBox(height: 20),
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
                            backgroundImage: AssetImage("assets/insta.jpeg"),
                          ),
                        ),
                        const SizedBox(width: 15),
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(25),
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage("assets/google.png"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFF77DD77),
                          ),
                          child: const Text(
                            "Login",
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
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (_isFormKey.currentState!.validate()) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }
}
