import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class FormulairPage extends StatefulWidget {
  const FormulairPage({Key? key}) : super(key: key);

  @override
  _FormulairPageState createState() => _FormulairPageState();
}

class _FormulairPageState extends State<FormulairPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _formulaireDataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFormulaireData();
  }

  Future<void> _fetchFormulaireData() async {
    try {
      User? user = _auth.currentUser;
      String? formateurEmail = user != null ? user.email : null;

      if (formateurEmail != null) {
        QuerySnapshot formationsSnapshot = await _firestore
            .collection('formations')
            .where('formateurPoster', isEqualTo: formateurEmail)
            .get();

        Set<Map<String, dynamic>> formulaireDataSet = {};

        for (var formationDoc in formationsSnapshot.docs) {
          QuerySnapshot mesFormulairesSnapshot =
              await formationDoc.reference.collection('mes_formulaires').get();

          for (var formulaireDoc in mesFormulairesSnapshot.docs) {
            formulaireDataSet.add(formulaireDoc.data() as Map<String, dynamic>);
          }
        }

        setState(() {
          _formulaireDataList = formulaireDataSet.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateFormulaireStatus(String formationId, String formulaireId, String status) async {
    try {
      await _firestore
          .collection('formations')
          .doc(formationId)
          .collection('mes_formulaires')
          .doc(formulaireId)
          .update({'status': status});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Future<void> _deleteFormulaire(String formationId, String formulaireId) async {
    try {
      await _firestore
          .collection('formations')
          .doc(formationId)
          .collection('mes_formulaires')
          .doc(formulaireId)
          .delete();
    } catch (e) {
      print('Error deleting formulaire: $e');
    }
  }

  void _showOptionsDialog(BuildContext context, Map<String, dynamic> formulaireData) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Choisissez une option', style: GoogleFonts.lora(color: Colors.blue.shade900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
              onPressed: () {
                if (formulaireData['formationId'] != null && formulaireData['id'] != null) {
                  _updateFormulaireStatus(formulaireData['formationId'], formulaireData['id'], 'accepted');
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog(context, 'Données manquantes', 'Impossible de traiter la demande car certaines données sont manquantes.');
                }
              },
              child: Text('Accepter', style: GoogleFonts.lora(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: () {
                if (formulaireData['formationId'] != null && formulaireData['id'] != null) {
                  _updateFormulaireStatus(formulaireData['formationId'], formulaireData['id'], 'rejected');
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog(context, 'Données manquantes', 'Impossible de traiter la demande car certaines données sont manquantes.');
                }
              },
              child: Text('Refuser', style: GoogleFonts.lora(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
              onPressed: () {
                if (formulaireData['formationId'] != null && formulaireData['id'] != null) {
                  _deleteFormulaire(formulaireData['formationId'], formulaireData['id']);
                  setState(() {
                    _formulaireDataList.remove(formulaireData);
                  });
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog(context, 'Données manquantes', 'Impossible de traiter la demande car certaines données sont manquantes.');
                }
              },
              child: Text('Supprimer', style: GoogleFonts.lora(color: Colors.white)),
            ),
          ],
        ),
      );
    },
  );
}

void _showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: GoogleFonts.lora(color: Colors.red)),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK', style: GoogleFonts.lora(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _formulaireDataList.isEmpty
              ? const Center(
                  child: Text(
                    'No One Apply for your Formations',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.separated(
                    itemCount: _formulaireDataList.length,
                    itemBuilder: (context, index) {
                      final formulaireData = _formulaireDataList[index];
                      return GestureDetector(
                        onTap: () => _showOptionsDialog(context, formulaireData),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          shadowColor: Colors.grey.shade300,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    '${formulaireData['formationTitle']}',
                                    style: GoogleFonts.notoSerif(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromRGBO(5, 44, 90, 0.808),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildInfoRow('Nom', '${formulaireData['nom']}'),
                                _buildInfoRow('Email', '${formulaireData['email']}'),
                                _buildInfoRow('Niveau', '${formulaireData['niveau']}'),
                                _buildInfoRow('Compétences', '${formulaireData['competences']}'),
                                _buildInfoRow('Numéro', '${formulaireData['numero']}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getIconForLabel(label),
            color: const Color.fromRGBO(5, 44, 90, 0.808),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.lora(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lora(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Nom':
        return Icons.person;
      case 'Email':
        return Icons.email;
      case 'Niveau':
        return Icons.school;
      case 'Compétences':
        return Icons.build;
      case 'Numéro':
        return Icons.phone;
      default:
        return Icons.info;
    }
  }
}
