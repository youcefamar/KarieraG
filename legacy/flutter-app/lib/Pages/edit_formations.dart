import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditFormationPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> formation;

  const EditFormationPage({Key? key, required this.formation}) : super(key: key);

  @override
  _EditFormationPageState createState() => _EditFormationPageState();
}

class _EditFormationPageState extends State<EditFormationPage> {
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

  @override
  void initState() {
    super.initState();
    _loadFormationData();
  }

  void _loadFormationData() {
    formationTitleController.text = widget.formation['title'];
    prixController.text = widget.formation['prix'];
    aboutController.text = widget.formation['about'];
    dureeController.text = widget.formation['duree'];
    prerequisController.text = widget.formation['prerequis'];
    nomInstitutController.text = widget.formation['nomInstitut'];
    categorieController.text = widget.formation['categorie'];
    programeController.text = widget.formation['Programe'];
    localisationController.text = widget.formation['localisation'];
    _selectedCategory = widget.formation['type'];
    _selectedetat = widget.formation['etat'];
    dateController.text = widget.formation['date'];
  }

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateFormationData() async {
    try {
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('FormationsImages')
          .child('${DateTime.now()}.jpg');

      // Upload de l'image si une nouvelle image est sélectionnée
      String imageUrl = widget.formation['imageUrl'];
      if (_image != null) {
        await imageRef.putFile(_image!);
        imageUrl = await imageRef.getDownloadURL();
      }

      // Mise à jour des données de la formation dans Firestore
      setState(() {
        spinner = true;
      });
      await FirebaseFirestore.instance.collection('formations').doc(widget.formation.id).update({
        'title': formationTitleController.text,
        'prix': prixController.text,
        'about': aboutController.text,
        'duree': dureeController.text,
        'prerequis': prerequisController.text,
        'nomInstitut': nomInstitutController.text,
        'categorie': categorieController.text,
        'imageUrl': imageUrl,
        'type': _selectedCategory,
        'localisation': localisationController.text,
        'Programe': programeController.text,
        'etat':_selectedetat,
      });

      setState(() {
        spinner = false;
      });

      Navigator.pop(context);
    } catch (e) {
      print('Erreur lors de la mise à jour de la formation: $e');
      // Gérer les erreurs de mise à jour de formation
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
        title: Center(child: Text('Modifier Formation', style: GoogleFonts.lora(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold))),
        backgroundColor: Color.fromRGBO(5, 44, 90, 0.808),
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back),color: Colors.white,),
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
                        ? Image.network(widget.formation['imageUrl'], height: 200.0, fit: BoxFit.cover)
                        : Image.file(_image!, height: 200.0, fit: BoxFit.cover),
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
                  const SizedBox(height: 20.0),
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
                  SizedBox(height: 20,),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    value: _selectedCategory,
                    hint: Text('Sélectionnez le Type', style: TextStyle(fontSize: 17)),
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
                   DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    value: _selectedetat,
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
                    onPressed: _updateFormationData,
                    child: Text('Mettre à jour la formation', style: GoogleFonts.lora(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(5, 44, 90, 0.808),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
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
