import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Kariera/Components/helper_function.dart';
import 'package:Kariera/Components/textfield.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String? _selectedCategory;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();
  bool spinner = false;
  final List<String> _categories = [
    'Development',
    'Marketing',
    'Business',
    'Design',
    'Finance',
  ];

  Future<void> signup() async {
    setState(() {
      spinner = true;
    });

    if (pwController.text != confirmPwController.text) {
      displayMessageToUser("Passwords don't match", context);
      setState(() {
        spinner = false;
      });
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: pwController.text);
      _sendInfo(emailController.text, pwController.text);
      setState(() {
        spinner = false;
      });
      Navigator.pushReplacementNamed(context, "homepage");
    } on FirebaseAuthException catch (e) {
      displayMessageToUser(e.code, context);
      setState(() {
        spinner = false;
      });
    }
  }

  void _sendInfo(String email, String password) async {
    if (usernameController.text.trim().isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        'username': usernameController.text,
        'password': password,
        'userId': currentUser.uid,
        'email': email,
        'objectif': _selectedCategory
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                   
                    const Icon(
                      Icons.app_registration_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 25),
                    
                    const Text(
                      'Fill this below',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: textfield(
                        hintText: 'Email',
                        obscureText: false,
                        controlleer: emailController,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: textfield(
                        hintText: 'Username',
                        obscureText: false,
                        controlleer: usernameController,
                      ),
                    ),
                    const SizedBox(height: 20),
                   
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: textfield(
                        hintText: 'Password',
                        obscureText: true,
                        controlleer: pwController,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: textfield(
                        hintText: 'Confirm Password',
                        obscureText: true,
                        controlleer: confirmPwController,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        alignment: Alignment.center,
                        value: _selectedCategory,
                        hint: const Text(
                          'Select your goal',
                          style: TextStyle(fontSize: 17),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    GestureDetector(
                      onTap: signup,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 35),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                   
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Have an account?",
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, "login");
                          },
                          child: const Text(
                            " Sign In",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
