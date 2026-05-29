import 'package:flutter/material.dart';
import 'package:Kariera/Pages/Formateur.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 128, 138, 156), Color.fromARGB(255, 128, 138, 156)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Text(
                  "Bienvenue à Kariera",
                  style: GoogleFonts.notoSerif(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Choisissez votre espace",
                  style: GoogleFonts.lora(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),
              buildOption(
                context,
                'assets/student.png',
                'Etudiant',
                'login',
              ),
              const SizedBox(height: 40),
              buildOption(
                context,
                'assets/formateur.png',
                'Formateur',
                MaterialPageRoute(builder: (context) => const FormateurPage()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOption(BuildContext context, String imagePath, String label, dynamic route) {
    return GestureDetector(
      onTap: () {
        if (route is String) {
          Navigator.pushNamed(context, route);
        } else if (route is MaterialPageRoute) {
          Navigator.push(context, route);
        }
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(
                imagePath,
                width: 100,
                semanticLabel: label,
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
