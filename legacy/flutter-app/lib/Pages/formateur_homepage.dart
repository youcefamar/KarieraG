import 'package:Kariera/Pages/addformation.dart';
import 'package:Kariera/Pages/details_formation_formateur.dart';
import 'package:Kariera/Pages/edit_formations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; 

const primaryColor = Color.fromRGBO(5, 44, 90, 0.808);
const disabledColor = Colors.grey;

class FormateurHomepage extends StatefulWidget {
  const FormateurHomepage({Key? key}) : super(key: key);

  @override
  State<FormateurHomepage> createState() => _FormateurHomepageState();
}

class _FormateurHomepageState extends State<FormateurHomepage> {
  final currentuser = FirebaseAuth.instance.currentUser;
  bool showCurrentUserFormations = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20), 
            _buildLottieAnimation(), 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: _buildSectionButtons(),
            ),
            _buildFormationsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFormation()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: primaryColor,
      ),
    );
  }

  Widget _buildLottieAnimation() {
    return Container(
      height: 200, 
      width: double.infinity,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 20), 
        child: Lottie.asset('assets/former.json'), 
      ),
    );
  }

  Widget _buildSectionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildButton('Vos Formations', showCurrentUserFormations, () {
            setState(() {
              showCurrentUserFormations = true;
            });
          }),
        ),
        const SizedBox(width: 10), 
        Expanded(
          child: _buildButton('Posté par les autres', !showCurrentUserFormations, () {
            setState(() {
              showCurrentUserFormations = false;
            });
          }),
        ),
      ],
    );
  }

  ElevatedButton _buildButton(String text, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          return isActive ? primaryColor : disabledColor;
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: isActive
                ? const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFormationsList() {
    final formationsStream = FirebaseFirestore.instance
        .collection('formations')
        .where(
          'formateurPoster',
          isEqualTo: showCurrentUserFormations ? currentuser?.email : null,
        )
        .where(
          'formateurPoster',
          isNotEqualTo: !showCurrentUserFormations ? currentuser?.email : null,
        )
        .snapshots();

    return StreamBuilder(
      stream: formationsStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucune formation trouvée.'));
        }
        return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var formation = snapshot.data!.docs[index];
            return FormationListItem(
              formation: formation,
              onDelete: () => _deleteFormation(formation.id),
              canModify: showCurrentUserFormations,
            );
          },
        );
      },
    );
  }

  Future<void> _deleteFormation(String formationId) async {
    if (showCurrentUserFormations) {
      try {
        await FirebaseFirestore.instance
            .collection('formations')
            .doc(formationId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formation supprimée avec succès.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la suppression: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous ne pouvez pas supprimer cette formation.')),
      );
    }
  }
}

class FormationListItem extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> formation;
  final Function onDelete;
  final bool canModify;

  const FormationListItem({
    Key? key,
    required this.formation,
    required this.onDelete,
    required this.canModify,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormationDetailsPage2(
              formationData: formation.data() as Map<String, dynamic>,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              child: Image.network(
                formation['imageUrl'],
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formation['title'],
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.calendar_today, '${formation['date']}'),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          formation['etat'] == 'Ouvert' ? Icons.lock_open : Icons.lock,
                          ' ${formation['etat']}',
                        ),
                      ],
                    ),
                  ),
                  if (canModify)
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            onDelete();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: primaryColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditFormationPage(formation: formation),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
