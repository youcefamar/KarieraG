import 'package:Kariera/Pages/formation_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentUserEmail;
  User? currentUser;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _categoriesKey = GlobalKey();
  final Map<String, GlobalKey> _categoryKeys = {};

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    getCurrentUserEmail();
    _checkForNewFormations();
  }

  void getCurrentUserEmail() {
    if (currentUser != null) {
      setState(() {
        currentUserEmail = currentUser!.email;
      });
    }
  }

  Future<void> _checkForNewFormations() async {
    if (currentUser != null) {
      String userObjectif = '';
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        userObjectif = userDoc['objectif'];
      }

      QuerySnapshot formationsSnapshot = await _firestore.collection('formations').get();
      List<QueryDocumentSnapshot> newFormations = formationsSnapshot.docs.where((doc) {
        return doc['categorie'] == userObjectif;
      }).toList();

      for (var formation in newFormations) {
        await _firestore.collection('notifications').add({
          'email': currentUserEmail,
          'formationId': formation.id,
          'formationTitle': formation['title'],
          'status': 'unread',
          'message': 'Une nouvelle formation a été ajoutée dans votre catégorie.',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: currentUser!.email)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              var userData = snapshot.data!.docs[0];
              String username = userData['username'];
              String objectif = userData['objectif'];

              return Center(
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    
                    buildWelcomeContainer(username),
               
                    buildObjectifContainer(objectif),
                    const SizedBox(height: 10),
                    
                    Lottie.asset('assets/pc.json', height: 210 ),
                    const SizedBox(height: 20),
                   
                    buildCategoriesScroller(),
                   
                    buildFormationsList(),
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

  Container buildWelcomeContainer(String username) {
    return Container(
      padding: const EdgeInsets.all(15),
     
      child: Column(
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (BuildContext context, double value, Widget? child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              'Bienvenue, $username',
              style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold),
            ),
             
          ),
          const SizedBox(height: 0),
        ],
      ),
    );
  }

  Container buildObjectifContainer(String objectif) {
    return Container(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.all(10),
     
      child: Column(
        children: [
          const SizedBox(height: 8),
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (BuildContext context, double value, Widget? child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              objectif,
              style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> buildCategoriesScroller() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('formations').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text('Une erreur s\'est produite');
        }

        // Extraction des catégories uniques
        Set<String> categories = snapshot.data!.docs
            .map((doc) => doc['categorie'] as String)
            .toSet();

        return Column(
          key: _categoriesKey,
          children: [
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String category = categories.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      _scrollToCategory(category);
                    },
                    child: buildCategoryItem(category),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Profitez de nos exclusives formations :',
                style: GoogleFonts.notoSerif(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> buildFormationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('formations').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text('Une erreur s\'est produite');
        }

        
        Map<String, List<QueryDocumentSnapshot>> formationsByCategory = {};
        snapshot.data!.docs.forEach((formation) {
          String category = formation['categorie'];
          if (!formationsByCategory.containsKey(category)) {
            formationsByCategory[category] = [];
            _categoryKeys[category] = GlobalKey();
          }
          formationsByCategory[category]!.add(formation);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: formationsByCategory.entries.map((entry) {
            String category = entry.key;
            List<QueryDocumentSnapshot> formations = entry.value;

            return Column(
              key: _categoryKeys[category],
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    category,
                    style: GoogleFonts.notoSerif(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: formations.length,
                    itemBuilder: (context, index) {
                      var formation = formations[index];
                      return FormationListItem(
                        formation: formation,
                        currentUserEmail: currentUserEmail,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Container buildCategoryItem(String category) {
    return  Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black, // Color of the border
          width: 2,           // Width of the border
        ),
      ),
      child: Center(
        child: Text(
          category,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _scrollToCategory(String category) {
    final categoryKey = _categoryKeys[category];
    if (categoryKey != null) {
      Scrollable.ensureVisible(
        categoryKey.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }
}

class FormationListItem extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> formation;
  final String? currentUserEmail;

  const FormationListItem({Key? key, required this.formation, required this.currentUserEmail}) : super(key: key);

  @override
  _FormationListItemState createState() => _FormationListItemState();
}

class _FormationListItemState extends State<FormationListItem> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = false;
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final prefs = await SharedPreferences.getInstance();
    final isFavorite = prefs.getBool('${widget.formation.id}-${widget.currentUserEmail}') ?? false;
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${widget.formation.id}-${widget.currentUserEmail}', _isFavorite);
    if (_isFavorite) {
      if (widget.currentUserEmail != null) {
        FirebaseFirestore.instance
            .collection('favoris')
            .doc(widget.currentUserEmail)
            .collection('mes_favoris')
            .doc(widget.formation.id)
            .set(widget.formation.data() as Map<String, dynamic>);
      }
    } else {
      if (widget.currentUserEmail != null) {
        FirebaseFirestore.instance
            .collection('favoris')
            .doc(widget.currentUserEmail)
            .collection('mes_favoris')
            .doc(widget.formation.id)
            .delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormationDetailsPage(formationData: widget.formation.data() as Map<String, dynamic>),
          ),
        );
      },
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 800),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (BuildContext context, double value, Widget? child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.95 + 0.05 * value,
              child: child,
            ),
          );
        },
        child: Container(
          width: 250,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.formation['imageUrl'] ?? '',
                width: 250,
                height: 150,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        widget.formation['title'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          widget.formation['prix'] ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "DA",
                          style: GoogleFonts.lora(fontSize: 18),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          color: _isFavorite ? Colors.red : Colors.grey,
                          iconSize: 30,
                          onPressed: _toggleFavorite,
                          icon: const Icon(Icons.favorite),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
