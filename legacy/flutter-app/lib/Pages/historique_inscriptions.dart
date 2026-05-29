import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class Historique extends StatefulWidget {
  const Historique({Key? key});

  @override
  State<Historique> createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _formulaireDataList = [];

  @override
  void initState() {
    super.initState();
    _fetchFormulaireData();
  }

  Future<void> _fetchFormulaireData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      QuerySnapshot mesFormulairesSnapshot = await _firestore
          .collectionGroup('mes_formulaires')
          .where('email', isEqualTo: user.email)
          .get();

      mesFormulairesSnapshot.docs.forEach((formulaireDoc) {
        Map<String, dynamic> formulaireData =
            formulaireDoc.data() as Map<String, dynamic>;
        setState(() {
          _formulaireDataList.add(formulaireData);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
          title: const Text(
            'Historique',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20.0, 
              fontWeight: FontWeight.bold, 
            ),
          ),
          backgroundColor: Color.fromARGB(166, 33, 149, 243),
          centerTitle: true, 
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), 
          ),
        ),

      body: _formulaireDataList.isEmpty
          ? Center(
              child: Text(
                "Vous n'êtes pas encore inscrit dans une formation",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            )
          : ListView.builder(
              itemCount: _formulaireDataList.length,
              itemBuilder: (context, index) {
                final formulaireData = _formulaireDataList[index];
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formulaireData['formationTitle'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nom : ${formulaireData['nom']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Email : ${formulaireData['email']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Niveau : ${formulaireData['niveau']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Competences : ${formulaireData['competences']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Numero : ${formulaireData['numero']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
