import 'package:flutter/material.dart';

class infosModel extends ChangeNotifier {
  final List _tileinfos=[
  Icon(Icons.email),"Email",
  Icon(Icons.phone),"Phone number",
  Icon(Icons.person),"Username",
  Icon(Icons.password_outlined),"Password",
  ];
  get tileinfos  => _tileinfos;
}