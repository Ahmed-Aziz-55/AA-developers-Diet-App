import 'package:flutter/material.dart';
class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}
class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.black,
              backgroundImage: AssetImage("assets/apple.png"),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Form(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                          ),
              ),
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: (){},
            child: Text('Continue',
              style: TextStyle(
                  color: Colors.white,fontWeight: FontWeight.bold),
            ),
            style: ButtonStyle(

            ),
          ),
        ],
      ),
    );
  }
}
