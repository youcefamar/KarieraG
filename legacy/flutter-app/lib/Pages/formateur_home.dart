import 'package:Kariera/Pages/formateurProfile.dart';
import 'package:Kariera/Pages/formateur_homepage.dart';
import 'package:Kariera/Pages/formulairPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


class formateurhome extends StatefulWidget {
  formateurhome({super.key});

  @override
  State<formateurhome> createState() => _formateurhomeState();
}

class _formateurhomeState extends State<formateurhome> {
  int _selectedIndex = 0;
  int _numberOfForms = 0; // Variable to hold the number of forms

  void Navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    FormateurHomepage(),
    FormulairPage(),
    FormateurProfile(),
  ];
 
  @override
  void initState() {
    super.initState();

    _updateNumberOfForms();
  }

  Future<int> getNumberOfForms(String formateurEmail) async {
    int totalForms = 0;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('formations')
        .where('formateurPoster', isEqualTo: formateurEmail)
        .get();

    for (DocumentSnapshot formationDocument in querySnapshot.docs) {
      QuerySnapshot formsSnapshot =
          await formationDocument.reference.collection('mes_formulaires').get();
      totalForms += formsSnapshot.size;
    }

    return totalForms;
  }

  Future<void> _updateNumberOfForms() async {
    String? formateurEmail = FirebaseAuth.instance.currentUser?.email;

    if (formateurEmail != null) {
      int numberOfForms = await getNumberOfForms(formateurEmail);
      setState(() {
        _numberOfForms = numberOfForms;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          child: AppBar(
            title: Text(
              'K A R I E R A',
              style: GoogleFonts.lora(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Color.fromRGBO(5, 44, 90, 0.808),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
           
          
          ),
        ),
      ),
      bottomNavigationBar:  ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(5, 44, 90, 0.808),
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: GNav(
                backgroundColor: Color.fromARGB(0, 255, 255, 255),
                color: Colors.white,
                activeColor: Color.fromARGB(255, 108, 182, 224),
                iconSize: 24,
                textStyle: TextStyle(fontSize: 14, color: Colors.white),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                tabs: [
                  GButton(icon: Icons.home, text: "Home"),
                  GButton(icon: Icons.format_align_center, text: "Formulaires"),
                  GButton(icon: Icons.person, text: "Profile"),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: Navigate,
              ),
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}