import 'package:Kariera/Components/textfield.dart';
import 'package:Kariera/Pages/Homepage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class FormulaireEtudiant extends StatefulWidget {
  final String formationTitle;
  final String formationPoster;
  
  const FormulaireEtudiant({
    Key? key, 
    required this.formationTitle, 
    required this.formationPoster
  }) : super(key: key);

  @override
  _FormulaireEtudiantState createState() => _FormulaireEtudiantState();
}

class _FormulaireEtudiantState extends State<FormulaireEtudiant> {
  final TextEditingController nomEtPrenomController = TextEditingController();
  final TextEditingController niveauController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController competencesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      emailController.text = currentUser.email ?? '';
    }
  }

  Future<void> _sendInfo() async {
    try {
      final formationCollection =
          FirebaseFirestore.instance.collection('formations');
      final userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userEmail != null) {
        final QuerySnapshot querySnapshot = await formationCollection
            .where('formateurPoster', isEqualTo: widget.formationPoster)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          final DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          final formData = {
            'nom': nomEtPrenomController.text,
            'niveau': niveauController.text,
            'email': emailController.text,
            'numero': numeroController.text,
            'competences': competencesController.text,
            'formationTitle': widget.formationTitle,
          };

          await documentSnapshot.reference
              .collection('mes_formulaires')
              .add(formData);

          nomEtPrenomController.clear();
          niveauController.clear();
          emailController.clear();
          numeroController.clear();
          competencesController.clear();

          Navigator.pop(context);

          AwesomeDialog(
            context: context,
            title: 'Succès',
            dialogType: DialogType.success,
            animType: AnimType.leftSlide,
            desc: 'Votre formulaire a été soumis avec succès. Nous vous enverrons un message sur votre e-mail.',
          ).show();
        } else {
          print('Formation non trouvée');
        }
      }
    } catch (e) {
      print('Erreur lors de l\'envoi du formulaire: $e');
      AwesomeDialog(
        context: context,
        title: 'Erreur',
        dialogType: DialogType.error,
        animType: AnimType.leftSlide,
        desc: 'Une erreur s\'est produite lors de la soumission du formulaire. Veuillez réessayer.',
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height:1),
                Lottie.asset(
                  'assets/write.json',
                  height: 200,
                ),
                const SizedBox(height: 25),
                Text(
                  'Remplir ce Formulaire',
                  style: GoogleFonts.lora(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                textfield(
                  hintText: 'Email',
                  obscureText: false,
                  controlleer: emailController,
                ),
                const SizedBox(height: 20),
                textfield(
                  hintText: 'Nom et Prenom',
                  obscureText: false,
                  controlleer: nomEtPrenomController,
                ),
                const SizedBox(height: 20),
                textfield(
                  hintText: 'Niveau',
                  obscureText: false,
                  controlleer: niveauController,
                ),
                const SizedBox(height: 20),
                textfield(
                  hintText: 'Numero de telephone',
                  obscureText: false,
                  controlleer: numeroController,
                ),
                const SizedBox(height: 20),
                textfield(
                  hintText: 'Competences',
                  obscureText: false,
                  controlleer: competencesController,
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _sendInfo,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 35),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(39, 76, 119, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Envoyer',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
