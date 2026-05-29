import 'package:Kariera/Pages/Favorite_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Kariera/Pages/Homepage.dart';
import 'package:Kariera/Pages/WelcomePage.dart';
import 'package:Kariera/Pages/formateurProfile.dart';
import 'package:Kariera/Pages/formateur_home.dart';
import 'package:Kariera/Pages/formulairPage.dart';
import 'package:Kariera/Pages/intro2.dart';
import 'package:Kariera/Pages/profile_page.dart';
import 'package:Kariera/Pages/sign_up.dart';
import 'package:Kariera/firebase_options.dart';
import 'package:Kariera/Pages/login_page.dart';
import 'package:provider/provider.dart';
import 'Components/theme.dart';
import 'Pages/Settings.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
   
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('==============User is currently signed out!');
      } else {
        print('====================User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Kariera',
          debugShowCheckedModeBanner: false,
          theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: FirebaseAuth.instance.currentUser == null
              ? Intropage2()
              : FirebaseAuth.instance.currentUser!.email != null &&
                      FirebaseAuth.instance.currentUser!.email!.endsWith('@kariera.com')
                  ? formateurhome()
                  : Homepage(),
          routes: {
            "homepage": (context) => Homepage(),
            "profil": (context) => ProfilePage(),
            "fav": (context) => FavoritePage(),
            "signup": (context) => Signup(),
            "login": (context) => Loginpage(),
            "formateurhome": (context) => formateurhome(),
            "welcomepage": (context) => WelcomePage(),
            "formulair": (context) => FormulairPage(),
            "formateurprofile": (context) => FormateurProfile(),
            "settings": (context) => SettingsPage(),
             
          },
        );
      },
    );
  }
}
