import 'package:flutter/material.dart';

class textfield extends StatelessWidget {
  textfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    this.controlleer, 
  });

  final String hintText;
  final bool obscureText;
  final controlleer;
 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        obscureText: obscureText,
        controller: controlleer,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: Colors.grey[500]),
          hintText: hintText,
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400)),
          fillColor: Colors.grey.shade200,
          filled: true,
        ),
      ),
    );
  }
}
