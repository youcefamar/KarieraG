import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Kariera/Pages/historique_inscriptions.dart';
import 'package:Kariera/Pages/Homepage.dart';
import 'package:Kariera/Pages/Settings.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser;
  File? _image;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
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
            .child('user_images/${currentUser?.uid}.jpg');
        await storageRef.putFile(_image!);
        _imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .update({'imageUrl': _imageUrl});
      } catch (e) {
        print("Image upload error: $e");
      }
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );
  }

  void _navigateToHistorique() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Historique()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return const Homepage();
              },
            ));
          },
          icon: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: _navigateToHistorique,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SettingsPage();
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: currentUser?.email)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              var userData = snapshot.data!.docs[0];
              String username = userData['username'];
              String email = userData['email'];
              String password = userData['password'];
              String objectif = userData['objectif'];
              _imageUrl = userData.data().containsKey('imageUrl')
                  ? userData['imageUrl']
                  : null;

              return Center(
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
                    _buildProfileItem('Nom', username),
                    _buildProfileItem('E-mail', email),
                    _buildProfileItem('Password', password),
                    _buildProfileItem('Objectif', objectif),
                    const SizedBox(height: 35),
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, 'login', (route) => false);
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
                    const SizedBox(height: 20),
                  ],
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
}


class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _objectifController = TextEditingController();
  late Stream<DocumentSnapshot> _userDataStream;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _usernameController.text = currentUser.displayName ?? '';
      _emailController.text = currentUser.email ?? '';
      _loadUserObjectif(currentUser.uid);
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _loadUserObjectif(String uid) async {
    _userDataStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();

    _userDataStream.listen((userData) {
      if (_isMounted) {
        setState(() {
          _objectifController.text = userData['objectif'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 5),
                      color: Colors.white,
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'New nom',
                    labelStyle: GoogleFonts.lora(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 5),
                      color: Colors.white,
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'E-mail',
                    labelStyle: GoogleFonts.lora(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 5),
                      color: Colors.white,
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: TextFormField(
                  showCursor: false,
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'New Password',
                    labelStyle: GoogleFonts.lora(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 5),
                      color: Colors.white,
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: TextFormField(
                  controller: _objectifController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Objectif',
                    labelStyle: GoogleFonts.lora(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () async {
                  try {
                    User? user = FirebaseAuth.instance.currentUser;
                    await user?.updateDisplayName(_usernameController.text);
                    await user?.updateEmail(_emailController.text);

                    if (_passwordController.text.isNotEmpty) {
                      await user?.updatePassword(_passwordController.text);
                    }

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .update({
                      'username': _usernameController.text,
                      'email': _emailController.text,
                      'objectif': _objectifController.text, 
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profile updated successfully'),
                      ),
                    );
                    Navigator.pop(context);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update profile: $error'),
                      ),
                    );
                  }
                } ,              
                  child: Text(
                  "Enregister",
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 