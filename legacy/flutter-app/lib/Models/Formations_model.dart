import 'package:flutter/material.dart';

class FormationModel extends ChangeNotifier {
  final List formations = [
    [
      "Programmation pour les débutants avec python ",
      "BrainerX",
      'assets/python.jpeg',
      "4.5"
    ],
    ["Social média marketing ", "Dahlias Institut", 'assets/Network.jpeg', "4"],
    [
      "La création d'entreprise ou bureau d'étude spécialise en décoration d'intérieur ",
      "BrainerX",
      "assets/creation d'entreprise.jpeg",
      "3.9"
    ],
    ["Bootcamp data scientitst", "Gomycode", "assets/Bootcamp.jpg", "4.2"],
    ["Ux et UI Design", "Gomycode", "assets/UI-UX.jpg", "5"],
  ];
}
