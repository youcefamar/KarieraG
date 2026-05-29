import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Kariera/Pages/formulaire_aremplir.dart';

class FormationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> formationData;

  const FormationDetailsPage({Key? key, required this.formationData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la formation', style: GoogleFonts.lora(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(5, 44, 90, 0.808),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              formationData['imageUrl'] ?? '',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 26),
            Text(
              formationData['title'] ?? '',
              style: GoogleFonts.dmSerifDisplay(fontSize: 28),
            ),
            const SizedBox(height: 25),
            const Text(
              "About",
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                '${formationData['about']}',
                style: GoogleFonts.notoSerif(fontSize: 14, color: Colors.grey[600], height: 2),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Text(
                  'Créé Par ',
                  style: GoogleFonts.notoSerif(fontSize: 12, color: Colors.black),
                ),
                const SizedBox(width: 3),
                Text(
                  '${formationData['nomInstitut']}',
                  style: GoogleFonts.lora(fontSize: 13, color: const Color.fromARGB(255, 150, 38, 170), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              "Ce que vous apprendrez",
              style: GoogleFonts.notoSerif(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.check, size: 22),
                const SizedBox(width: 10),
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    '${formationData['Programe']}',
                    style: GoogleFonts.notoSerif(fontSize: 14, color: Colors.black, height: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Icon(Icons.access_time_filled_rounded, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Durée :',
                  style: GoogleFonts.notoSerif(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(
                  '${formationData['duree']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Icon(Icons.school, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Prerequis :',
                  style: GoogleFonts.notoSerif(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Container(
                  constraints: const BoxConstraints(maxWidth: 190),
                  child: Text(
                    '${formationData['prerequis']}',
                    style: GoogleFonts.lora(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.category, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Catégorie :',
                  style: GoogleFonts.notoSerif(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(
                  '${formationData['categorie']}',
                  style: GoogleFonts.lora(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Icon(Icons.place, size: 18, color: Color.fromARGB(255, 68, 67, 67)),
                const SizedBox(width: 10),
                Text(
                  '${formationData['localisation']}',
                  style: GoogleFonts.lora(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Icon(Icons.local_activity, size: 18, color: Color.fromARGB(255, 68, 67, 67)),
                const SizedBox(width: 10),
                Text(
                  '${formationData['type']}',
                  style: GoogleFonts.lora(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (formationData['etat'] == 'Ouvert')
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormulaireEtudiant(
                        formationTitle: formationData['title'],
                        formationPoster: formationData['formateurPoster'],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(9),
                  margin: const EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(39, 76, 119, 50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "S'inscrire",
                      style: GoogleFonts.lora(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  "Cette formation est fermée",
                  style: GoogleFonts.lora(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
