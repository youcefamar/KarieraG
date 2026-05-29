import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;

import 'package:Kariera/Pages/historique_inscriptions.dart';
import 'package:Kariera/Pages/Favorite_page.dart';
import 'package:Kariera/Pages/home.dart';
import 'package:Kariera/Pages/search_page.dart';
import 'package:Kariera/Pages/notification.dart';
import 'package:Kariera/Pages/profile_page.dart'; 

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  int _notificationCount = 0;
  bool _shouldUpdateBadge = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotificationCount();
  }

  Future<void> _fetchUnreadNotificationCount() async {
    User? user = _auth.currentUser;
    if (user != null && _shouldUpdateBadge) {
      String userEmail = user.email!;
      QuerySnapshot unreadNotifications = await _firestore
          .collection('notifications')
          .where('email', isEqualTo: userEmail)
          .where('status', isEqualTo: 'unread')
          .get();

      setState(() {
        _notificationCount = unreadNotifications.size;
      });
    }
  }

  void _navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    FavoritePage(),
    Historique(),
  ];

  void _openNotificationsPage() {
  Navigator.push<int>(
  context,
  MaterialPageRoute(builder: (context) => const NotificationsPage()),
).then((unreadCount) {
  if (unreadCount != null) {
    setState(() {
      _notificationCount = unreadCount;
    });
  }
});


  }

  void _navigateToProfilePage() {
    setState(() {
      _shouldUpdateBadge = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    ).then((_) {
      setState(() {
        _shouldUpdateBadge = true;
      });
      _fetchUnreadNotificationCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          child: AppBar(
            title: Text(
              'K A R I E R A',
              style: GoogleFonts.lora(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(5, 44, 90, 0.808),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: badges.Badge(
              badgeContent: Text(
                _notificationCount.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _openNotificationsPage,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: _navigateToProfilePage,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var userData = snapshot.data!;
                          String? imageUrl = userData['imageUrl'];
                          return imageUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.person);
                        } else {
                          return const Icon(Icons.person);
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(5, 44, 90, 0.808),
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: GNav(
                backgroundColor: Colors.transparent,
                color: Colors.white,
                activeColor: const Color.fromARGB(255, 108, 182, 224),
                iconSize: 24,
                textStyle: const TextStyle(fontSize: 13, color: Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                tabs: const [
                  GButton(icon: Icons.home, text: "Home"),
                  GButton(icon: Icons.search, text: "Search"),
                  GButton(icon: Icons.favorite, text: "Favoris"),
                  GButton(icon: Icons.history_sharp, text: "Historique"),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: _navigate,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
