import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Kariera/Pages/formation_details.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _notificationsList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    User? user = _auth.currentUser;
    String? userEmail = user?.email;

    if (userEmail != null) {
      try {
        // Récupérer les notifications des formations ajoutées
        QuerySnapshot notificationsSnapshot = await _firestore
            .collection('formations')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        // Convertir les documents en listes de notifications
        List<Map<String, dynamic>> formationNotifications = notificationsSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            ...data,
            'id': doc.id,
            'type': 'formation',
          };
        }).toList();

        setState(() {
          _notificationsList = formationNotifications;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to load notifications: $e';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'User is not logged in.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.lora(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(5, 44, 90, 0.808),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: GoogleFonts.lora(color: Colors.red)))
              : _notificationsList.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications yet!',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.separated(
                        itemCount: _notificationsList.length,
                        itemBuilder: (context, index) {
                          final notification = _notificationsList[index];
                          final title = notification['title'] ?? 'No Title';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FormationDetailsPage(
                                    formationData: notification,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Nouvelle Formation',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Cliquez pour voir les détails de la formation',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
}
