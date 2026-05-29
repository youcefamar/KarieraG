import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      Reference storageReference = _storage.ref().child('profile_images/$userId');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => null);
      String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> updateProfile(
      String userId, String username, String email, String imageUrl, String? objectif) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'username': username,
        'email': email,
        'profileImage': imageUrl,
        'objectif': objectif,
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
