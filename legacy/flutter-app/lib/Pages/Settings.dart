import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Kariera/Components/theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildListItem(BuildContext context, String title, IconData icon, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.secondary),
                SizedBox(width: 16.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.secondary, size: 20.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(
          'Paramètres ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                title: Text(
                  'Mode sombre',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
                ),
                trailing: CupertinoSwitch(
                  value: Provider.of<ThemeNotifier>(context).isDarkMode,
                  onChanged: (value) {
                    Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                  },
                ),
              ),
            ),
           _buildListItem(
  context,
  'Politique de confidentialité',
  Icons.privacy_tip,
  () {
    // Afficher la politique de confidentialité
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Politique de confidentialité',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Votre vie privée est importante pour nous. Elle est protégée par notre politique de confidentialité :',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                '1. Nous ne recueillons que les informations nécessaires au bon fonctionnement de l\'application.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: 16.0,
                ),
              ),
              Text(
                '2. Vos données personnelles ne seront jamais vendues à des tiers.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: 16.0,
                ),
              ),
              Text(
                '3. Nous utilisons des mesures de sécurité pour protéger vos informations personnelles contre tout accès non autorisé.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Fermer',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  },
),

           _buildListItem(
  context,
  'Conditions générales',
  Icons.description,
  () {
    // Afficher les conditions générales
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Conditions générales',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue dans l\'application KARIERA. En utilisant cette application, vous acceptez les conditions générales suivantes :',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                '1. Vous ne pouvez pas utiliser cette application à des fins illégales ou non autorisées.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: 16.0,
                ),
              ),
              Text(
                '2. Vous ne pouvez pas violer les lois de votre juridiction en utilisant cette application.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: 16.0,
                ),
              ),
              Text(
                '3. Toute utilisation abusive de cette application peut entraîner la résiliation de votre compte.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Fermer',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  },
),

          _buildListItem(
  context,
  'Effacer les données locales',
  Icons.delete,
  () {
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Effacer les données locales',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Cette action supprimera toutes les données stockées localement par l\'application. Êtes-vous sûr de vouloir continuer ?',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1!.color,
              fontSize: 16.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // nzido function bach nsupprimer kolch 
                Navigator.pop(context);
              },
              child: Text(
                'Confirmer',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16.0,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  },
),
           
           _buildListItem(
  context,
  'À propos',
  Icons.info,
  () {
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'À propos',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KARIERA',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                "KARIERA est une application mobile qui propose les meilleures opportunités de formation en Algérie. Elle offre une large gamme de formations pour aider les individus à améliorer leurs compétences et à faire avancer leur carrière.",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Fermer',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  },
),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildListItem(
                context,
                'Contactez-nous',
                Icons.contact_support,
                () {
                  
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Contactez-nous',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text(
                                'Instagram',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyText1!.color,
                                  fontSize: 16.0,
                                ),
                              ),
                              onTap: () {
                                _launchURL('https://www.instagram.com/kariera__?igsh=cGJ0MXF4azFweXFp');
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text(
                                'Facebook',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyText1!.color,
                                  fontSize: 16.0,
                                ),
                              ),
                              onTap: () {
                                _launchURL('https://www.facebook.com/profile.php?id=61560227632957&mibextid=ZbWKwL');
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text(
                                'Twitter',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyText1!.color,
                                  fontSize: 16.0,
                                ),
                              ),
                              onTap: () {
                                _launchURL('https://x.com/Kariera__?t=N9WNgNifrlg74Pq3HeNM4A&s=09');
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
