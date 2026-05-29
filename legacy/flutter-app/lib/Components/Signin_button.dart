
import 'package:flutter/material.dart';
import 'package:Kariera/Pages/Homepage.dart';
import 'package:Kariera/Pages/login_page.dart';
class Signin extends StatelessWidget {
Signin({super.key,required this.ontapfunction});
final void ontapfunction;

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: () => ontapfunction,
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 35),
        decoration: BoxDecoration(
          color: Colors.black,
           borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text('Sign In',style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),)),
      ),
    );
  }
}