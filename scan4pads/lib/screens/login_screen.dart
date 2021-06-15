import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:pad_app/screens/home_screen.dart';
import 'package:pad_app/services/auth.dart';
import 'package:pad_app/widgets/circular_material_spinner.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final AuthService authentication = AuthService();
  bool obscurePassword = true;
  bool loading = false;

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    Colors.pink[800],
                    Colors.pink[400],
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 36.0, horizontal: 110.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Scan4pads",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 46.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 4,
                        child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.elliptical(100, 40),
                                topRight: Radius.elliptical(100, 40),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: loginFormKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Text(
                                      "Welcome to scan for pads",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 70.0,
                                    ),
                                    TextFormField(
                                      controller: emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) {
                                        if (value.isEmpty)
                                          return 'Email is required';
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFFe7edeb),
                                        hintText: "Email",
                                        prefixIcon: Icon(Icons.email_rounded,
                                            color: Colors.grey[600]),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    TextFormField(
                                      controller: passwordCtrl,
                                      keyboardType: TextInputType.text,
                                      obscureText: obscurePassword,
                                      validator: (value) {
                                        if (value.isEmpty)
                                          return 'Password is required';
                                        if (value.length < 4)
                                          return 'Password has to be more than 4 characters long';
                                        return null;
                                      },
                                      decoration: new InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Color(0xFFe7edeb),
                                          hintText: "Password",
                                          prefixIcon: Icon(Icons.lock,
                                              color: Colors.grey[600]),
                                          suffixIcon: new GestureDetector(
                                              onTap: togglePasswordVisibility,
                                              child: Icon(
                                                obscurePassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                size: 20.0,
                                                color: Colors.grey[600],
                                              ))),
                                    ),
                                    SizedBox(height: 25),
                                    CircularMaterialSpinner(
                                      loading: loading,
                                      color: Colors.blue[800],
                                      child: Container(
                                        width: double.infinity,
                                        child: RaisedButton(
                                            onPressed: () async {
                                              if (loginFormKey.currentState
                                                  .validate()) {
                                                setState(() {
                                                  loading = true;
                                                });
                                                dynamic result =
                                                    await authentication.signIn(
                                                        emailCtrl.text,
                                                        passwordCtrl.text);
                                                if (result == null) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                } else {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            HomeScreen()),
                                                  );
                                                }
                                              }
                                            },
                                            color: Colors.blue[800],
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16.0),
                                              child: Text(
                                                'Login',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ],
                ))));
  }
}
