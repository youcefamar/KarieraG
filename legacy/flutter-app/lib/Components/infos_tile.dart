import 'package:flutter/material.dart';

class InfosTile extends StatelessWidget {
   InfosTile({super.key, required this.icon, required this.info, required this.details,}) {
   }
  final Icon icon;
  final String info;
  final String details;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(info),
    );
  }
}