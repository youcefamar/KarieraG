import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Kariera/Pages/formateur_home.dart';
import 'package:Kariera/Pages/Settings.dart';

class FormateurProfile extends StatefulWidget {
  FormateurProfile({super.key});

  @override
  _FormateurProfileState createState() => _FormateurProfileState();
}

class _FormateurProfileState extends State<FormateurProfile> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection('formateurs');
  File? _image;
  String? _imageUrl;
  bool _isEditing = false;
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _nomInstitutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserImage();
    _loadUserData();
  }

  Future<void> _loadUserImage() async {
    final userData = await userCollection
        .where('connection-email', isEqualTo: currentUser.email)
        .limit(1)
        .get();
    if (userData.docs.isNotEmpty) {
      setState(() {
        _imageUrl = userData.docs[0].data().containsKey('imageUrl')
            ? userData.docs[0]['imageUrl']
            : null;
      });
    }
  }

  Future<void> _loadUserData() async {
    final userData = await userCollection
        .where('connection-email', isEqualTo: currentUser.email)
        .limit(1)
        .get();
    if (userData.docs.isNotEmpty) {
      final data = userData.docs[0].data();
      _numeroController.text = data['numero'];
      _nomInstitutController.text = data['nom_dinstitut'];
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('formateur_images/${currentUser.uid}.jpg');
        await storageRef.putFile(_image!);
        _imageUrl = await storageRef.getDownloadURL();

        final userData = await userCollection
            .where('connection-email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (userData.docs.isNotEmpty) {
          await userCollection
              .doc(userData.docs[0].id)
              .update({'imageUrl': _imageUrl});
          setState(() {});
        }
      } catch (e) {
        print("Image upload error: $e");
      }
    }
  }

  Future<void> _updateUserData() async {
    final userData = await userCollection
        .where('connection-email', isEqualTo: currentUser.email)
        .limit(1)
        .get();

    if (userData.docs.isNotEmpty) {
      await userCollection.doc(userData.docs[0].id).update({
        'numero': _numeroController.text,
        'nom_dinstitut': _nomInstitutController.text,
      });
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  return formateurhome();
                },
              ));
            },
            icon: const Icon(Icons.keyboard_arrow_left_sharp),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SettingsPage();
                    },
                  ),
                );
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: userCollection
                .where('connection-email', isEqualTo: currentUser.email)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                var userData = snapshot.data!.docs[0];
                String email = userData['email'];

                return SafeArea(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: _imageUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : _image != null
                                      ? ClipOval(
                                          child: Image.file(
                                            _image!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.person, size: 100),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: _uploadImage,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _buildProfileItem('E-mail', email),
                        _buildEditableProfileItem(
                          'Numero de telephone',
                          _numeroController,
                          Icons.phone,
                        ),
                        _buildEditableProfileItem(
                          "Nom d'institut",
                          _nomInstitutController,
                          Icons.school,
                        ),
                        const SizedBox(height: 35),
                        _isEditing
                            ? ElevatedButton(
                                onPressed: _updateUserData,
                                child: Text("Save"),
                              )
                            : GestureDetector(
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, 'welcomepage', (route) => false);
                                },
                                child: Text(
                                  "Se déconnecter",
                                  style: GoogleFonts.lora(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error ${snapshot.error}'),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableProfileItem(String title, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: _isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: title,
                  ),
                )
              : Text(
                  controller.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
         
leading: IconButton(
icon: Icon(_isEditing ? Icons.save : Icons.edit),
onPressed: () {
setState(() {
if (_isEditing) {
_updateUserData();
}
_isEditing = !_isEditing;
});
},
),
),
),
);
}
}