import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddFormation extends StatefulWidget {
  const AddFormation({Key? key}) : super(key: key);

  @override
  _AddFormationState createState() => _AddFormationState();
}

class _AddFormationState extends State<AddFormation> {
  final TextEditingController formationTitleController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController dureeController = TextEditingController();
  final TextEditingController prerequisController = TextEditingController();
  final TextEditingController nomInstitutController = TextEditingController();
  final TextEditingController categorieController = TextEditingController();
  final TextEditingController programeController = TextEditingController();
  final TextEditingController localisationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final List<String> _categories = ['Présentiel', 'En ligne'];
  String? _selectedCategory;
  final List<String> _etats = ['Ouvert', 'Fermé'];
  String? _selectedetat;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool spinner = false;
  final formateur = FirebaseAuth.instance.currentUser;

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _sendFormationData() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userEmail != null) {
        final imageRef = FirebaseStorage.instance
            .ref()
            .child('FormationsImages')
            .child('${DateTime.now()}.jpg');

        // Upload de l'image
        if (_image != null) {
          await imageRef.putFile(_image!);
          final imageUrl = await imageRef.getDownloadURL();

          // Ajout des données de la formation dans Firestore
          setState(() {
            spinner = true;
          });
          await FirebaseFirestore.instance.collection('formations').add({
            'title': formationTitleController.text,
            'prix': prixController.text,
            'about': aboutController.text,
            'duree': dureeController.text,
            'prerequis': prerequisController.text,
            'nomInstitut': nomInstitutController.text,
            'categorie': categorieController.text,
            'imageUrl': imageUrl,
            'formateurPoster': userEmail,
            'type': _selectedCategory,
            'etat': _selectedetat,
            'localisation': localisationController.text,
            'Programe': programeController.text,
            'date': dateController.text,
          });

          formationTitleController.clear();
          prixController.clear();
          aboutController.clear();
          dureeController.clear();
          prerequisController.clear();
          nomInstitutController.clear();
          categorieController.clear();
          setState(() {
            _image = null;
            spinner = false;
          });

          Navigator.pop(context);
        } else {
          // Gérer l'absence d'image
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Erreur', style: GoogleFonts.lora()),
                content: Text('Veuillez sélectionner une image.', style: GoogleFonts.lora()),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Utilisateur non connecté');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de la formation: $e');
      // Gérer les erreurs d'ajout de formation
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une Formation', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color.fromRGBO(5, 44, 90, 0.808),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GestureDetector(
                    onTap: _getImage,
                    child: _image == null
                        ? Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_a_photo, size: 100.0, color: Colors.grey),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_image!, height: 200.0, fit: BoxFit.cover),
                          ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: formationTitleController,
                    decoration: InputDecoration(
                      labelText: 'Titre de la formation',
                      labelStyle: GoogleFonts.lora(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: prixController,
                    decoration: InputDecoration(
                      labelText: 'Prix',
                      labelStyle: GoogleFonts.lora(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: GoogleFonts.lora(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      _selectDate(context);
                    },
                  ),
                  const SizedBox(height: 20.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    value: _selectedCategory,
                    hint: Text("Sélectionnez l'etat", style: TextStyle(fontSize: 17)),
                    items: _etats.map((etat) {
                      return DropdownMenuItem<String>(
                        value: etat,
                        child: Text(etat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedetat = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    value: _selectedCategory,
                    hint: Text("Sélectionnez le type", style: TextStyle(fontSize: 17)),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: dureeController,
                    decoration: InputDecoration(
                      labelText: 'Durée',
                      labelStyle: GoogleFonts.lora(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: prerequisController,
                    decoration: InputDecoration(
                      labelText: 'Prérequis',
                      labelStyle: GoogleFonts.lora(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: nomInstitutController,
                    decoration: InputDecoration(
                      labelText: 'Nom de l\'institut',
                      labelStyle: GoogleFonts.lora(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: categorieController,
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      labelStyle: GoogleFonts.lora(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: localisationController,
                    decoration: InputDecoration(
                      labelText: 'Localisation',
                      labelStyle: GoogleFonts.lora(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: aboutController,
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'Description de votre formation',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                      labelText: 'À propos',
                      labelStyle: GoogleFonts.lora(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: programeController,
                    maxLength: 400,
                    decoration: InputDecoration(
                      labelText: 'Votre Programme',
                      labelStyle: GoogleFonts.lora(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  
                 
                  const SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: _sendFormationData,
                    child: Text('Ajouter cette formation', style: GoogleFonts.lora(fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(5, 44, 90, 0.808),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
            if (spinner)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
