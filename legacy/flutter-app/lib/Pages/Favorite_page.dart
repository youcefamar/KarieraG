import 'package:Kariera/Pages/formation_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late String _currentUserEmail;
  late List<DocumentSnapshot> _favoriteFormations;

  @override
  void initState() {
    super.initState();
    _favoriteFormations = [];
    _loadCurrentUserEmail();
  }

  Future<void> _loadCurrentUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserEmail = user.email!;
      });
      _loadFavoriteFormations();
    }
  }

  Future<void> _loadFavoriteFormations() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('favoris')
        .doc(_currentUserEmail)
        .collection('mes_favoris')
        .get();
    setState(() {
      _favoriteFormations = querySnapshot.docs;
    });
  }

  Future<void> _toggleFavorite(DocumentSnapshot formation, bool isFavorite) async {
    final prefs = await SharedPreferences.getInstance();
    final formationId = formation.id;
    setState(() {
      if (isFavorite) {
        _favoriteFormations.remove(formation);
        prefs.setBool(formationId, false);
      } else {
        _favoriteFormations.add(formation);
        prefs.setBool(formationId, true);
      }
    });

    if (_currentUserEmail.isNotEmpty) {
      final docRef = FirebaseFirestore.instance
          .collection('favoris')
          .doc(_currentUserEmail)
          .collection('mes_favoris')
          .doc(formationId);
      if (isFavorite) {
        await docRef.delete();
      } else {
        await docRef.set(formation.data() as Map<String, dynamic>);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        children: [
          SizedBox(height: 80,),
          Text("Vos Formations Favorites", style: GoogleFonts.notoSerif(fontWeight: FontWeight.bold, fontSize: 22),),
          SizedBox(height: 30,),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: 20,),
              itemCount: _favoriteFormations.length,
              itemBuilder: (context, index) {
                final formation = _favoriteFormations[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormationDetailsPage(
                          formationData: formation.data() as Map<String, dynamic>,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ListTile(
                      tileColor: Colors.white60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      leading: Image.network(
                        formation['imageUrl'],
                        fit: BoxFit.cover,
                      ),
                      title: Text(formation['title'] ?? '', style: GoogleFonts.lora(color: Colors.black, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        children: [
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Text('Durée :', style: GoogleFonts.notoSerif(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),),
                              SizedBox(width: 10,),
                              Text(formation['duree'], style: GoogleFonts.lora(fontSize: 12, color: Colors.black),),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text('Prerequis :', style: GoogleFonts.notoSerif(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),),
                              SizedBox(width: 10,),
                              Text(formation['prerequis'], style: GoogleFonts.lora(fontSize: 12, color: Colors.black),),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text('Catégorie :', style: GoogleFonts.notoSerif(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),),
                              SizedBox(width: 10,),
                              Text(formation['categorie'], style: GoogleFonts.lora(fontSize: 12, color: Colors.black),),
                            ],
                          ),
                          SizedBox(height: 10,),
                         
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
