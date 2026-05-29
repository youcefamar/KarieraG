import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Kariera/Pages/formation_details.dart';
import 'package:lottie/lottie.dart';

class FormationSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Recherchez une formation';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Tap on a formation to view details.', style: GoogleFonts.lora()),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Stream<QuerySnapshot> formationsStream;

    if (query.isEmpty) {
      formationsStream = FirebaseFirestore.instance
          .collection('formations')
          .limit(5)
          .snapshots();
    } else {
      formationsStream = FirebaseFirestore.instance
          .collection('formations')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: formationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print('Snapshot has error: ${snapshot.error}');
          return Center(
            child: Text('Une erreur est survenue: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('No data available.');
          return Center(
            child: Text('Pas de formation trouvé', style: GoogleFonts.lora(fontSize: 15)),
          );
        }

        final docs = snapshot.data!.docs;
        print('Formations found: ${docs.length}');

        return ListView(
          children: docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            return Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    leading: data['imageUrl'] != null
                        ? SizedBox(
                            width: 40,
                            child: Image.network(data['imageUrl']),
                          )
                        : null,
                    title: Text(data['title'] ?? 'No title', style: GoogleFonts.lora()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormationDetailsPage(
                            formationData: data,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> updateKeywords() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('formations').get();
    List<DocumentSnapshot> documents = querySnapshot.docs;

    for (DocumentSnapshot doc in documents) {
      String title = doc['title'];
      String description = doc['description'];
      String combinedText = '$title $description';
      List<String> tokens = combinedText.toLowerCase().split(RegExp(r'\s+'));
      await doc.reference.update({'keywords': tokens});
    }

    print('Keywords updated for all documents.');
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(112, 223, 219, 219),
        elevation: 0,
        title: Text(
          'Recherche de Formation',
          style: GoogleFonts.lora(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(context: context, delegate: FormationSearchDelegate());
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/search.json',
             
              height: 200,
            ),
            const SizedBox(height: 30),
            Text(
              'Trouvez la formation qui vous convient',
              style: GoogleFonts.lora(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
           
          
          ],
        ),
      ),
    );
  }
}
