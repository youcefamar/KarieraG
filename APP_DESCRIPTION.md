# Kariera - Application Mobile de Formation Professionnelle

## Vue d'ensemble

**Kariera** est une application mobile Flutter multiplateforme (Android, iOS, Web, Windows, macOS, Linux) qui met en relation des **étudiants** cherchant à se former avec des **formateurs/instituts** proposant des formations professionnelles. L'application utilise **Firebase** comme backend (Authentication, Firestore, Storage).

---

## Architecture Technique

| Composant | Technologie |
|-----------|-------------|
| Framework | Flutter (Dart) |
| Authentification | Firebase Auth (Email/Password, Google Sign-In, Facebook) |
| Base de données | Cloud Firestore |
| Stockage fichiers | Firebase Storage |
| State Management | Provider, GetX |
| UI | Google Fonts, Google Nav Bar, Lottie Animations, Awesome Dialog |
| Navigation | Named Routes + MaterialPageRoute |

---

## Rôles Utilisateurs

L'application distingue deux types d'utilisateurs basés sur l'email :

### 1. Étudiant (utilisateur standard)
- Tout utilisateur dont l'email ne se termine pas par `@kariera.com`
- Accès à la page d'accueil étudiant avec navigation par onglets

### 2. Formateur (administrateur de formations)
- Utilisateur dont l'email se termine par `@kariera.com`
- Accès à un dashboard dédié pour gérer les formations

---

## Fonctionnalités Détaillées

### Authentification & Onboarding
- **Page d'introduction** : Onboarding en 3 étapes avec animations Lottie et PageView
- **Inscription** : Email, mot de passe, nom d'utilisateur, choix d'un objectif/catégorie (Development, Marketing, Business, Design, Finance)
- **Connexion** : Email/mot de passe, Google Sign-In, Facebook Login
- **Réinitialisation de mot de passe** : Envoi d'email de récupération
- **Persistance de session** : Redirection automatique selon l'état d'authentification

### Espace Étudiant

#### Page d'accueil (Home)
- Affichage personnalisé avec le nom de l'utilisateur
- Formations recommandées basées sur l'objectif choisi lors de l'inscription
- Catégorisation des formations
- Notifications pour les nouvelles formations correspondant à l'objectif de l'étudiant

#### Recherche
- Recherche de formations par titre dans Firestore
- Suggestions en temps réel avec autocomplétion

#### Favoris
- Ajout/suppression de formations en favoris
- Stockage des favoris dans Firestore (collection `favoris`) et en local (SharedPreferences)

#### Historique des inscriptions
- Consultation de toutes les formations auxquelles l'étudiant s'est inscrit
- Données récupérées depuis la sous-collection `mes_formulaires`

#### Détails d'une formation
- Image, titre, description ("About")
- Nom de l'institut/formateur
- Prix, durée, prérequis, programme, localisation, date
- Catégorie (Présentiel / En ligne)
- État (Ouvert / Fermé)

#### Formulaire d'inscription à une formation
- Champs : Nom et prénom, niveau, email (pré-rempli), numéro de téléphone, compétences
- Soumission enregistrée dans Firestore sous la formation concernée

#### Profil
- Photo de profil (upload depuis la galerie vers Firebase Storage)
- Informations personnelles (email, username, objectif)
- Modification du profil

#### Notifications
- Alertes pour les nouvelles formations dans la catégorie de l'utilisateur
- Badge de compteur de notifications non lues
- Marquage lu/non lu

#### Paramètres
- Thème sombre / clair (Provider + ThemeNotifier)
- Liens externes (URL Launcher)

### Espace Formateur

#### Dashboard Formateur
- Vue de toutes les formations ou uniquement celles du formateur connecté
- Animation Lottie décorative

#### Gestion des formations
- **Ajouter** une formation : titre, prix, description, durée, prérequis, nom de l'institut, catégorie, programme, localisation, date, type (Présentiel/En ligne), état (Ouvert/Fermé), image
- **Modifier** une formation existante
- **Consulter les détails** et les inscriptions reçues

#### Profil Formateur
- Page de profil dédiée

---

## Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée, configuration Firebase, routing
├── firebase_options.dart        # Configuration Firebase auto-générée
├── FirebaseService.dart         # Service d'upload d'image et mise à jour profil
├── Components/
│   ├── theme.dart               # ThemeNotifier (dark/light mode)
│   ├── textfield.dart           # Widget TextField réutilisable
│   ├── mytextfield.dart         # Variante de TextField
│   ├── Signin_button.dart       # Bouton de connexion
│   ├── formation_tile.dart      # Carte de formation réutilisable
│   ├── infos_tile.dart          # Tuile d'information
│   └── helper_function.dart     # Fonctions utilitaires
├── Models/
│   ├── Formations_model.dart    # Modèle de données des formations (statique)
│   └── profile_infos_model.dart # Modèle d'informations de profil
└── Pages/
    ├── intro.dart / intro2.dart          # Pages d'onboarding
    ├── WelcomePage.dart                  # Page de bienvenue
    ├── login_page.dart                   # Connexion
    ├── sign_up.dart                      # Inscription
    ├── Homepage.dart                     # Shell avec navigation (étudiant)
    ├── home.dart                         # Contenu de la page d'accueil
    ├── search_page.dart                  # Recherche de formations
    ├── Favorite_page.dart                # Formations favorites
    ├── historique_inscriptions.dart       # Historique des inscriptions
    ├── formation_details.dart            # Détails d'une formation
    ├── formulaire_aremplir.dart          # Formulaire d'inscription
    ├── formulairPage.dart                # Page formulaire
    ├── profile_page.dart                 # Profil étudiant
    ├── notification.dart                 # Notifications
    ├── Settings.dart                     # Paramètres
    ├── formateur_home.dart               # Shell formateur
    ├── formateur_homepage.dart           # Dashboard formateur
    ├── formateurProfile.dart             # Profil formateur
    ├── Formateur.dart                    # Page formateur
    ├── addformation.dart                 # Ajout de formation
    ├── edit_formations.dart              # Modification de formation
    └── details_formation_formateur.dart  # Détails côté formateur
```

---

## Base de Données Firestore (Collections)

| Collection | Description |
|------------|-------------|
| `users` | Profils utilisateurs (username, email, objectif, imageUrl) |
| `formations` | Formations disponibles (title, prix, about, durée, prérequis, nomInstitut, categorie, programme, localisation, date, imageUrl, formateurPoster, état) |
| `formations/{id}/mes_formulaires` | Inscriptions des étudiants à une formation |
| `favoris/{email}/mes_favoris` | Formations favorites d'un utilisateur |
| `notifications` | Notifications push (email, formationId, formationTitle, status, message, timestamp) |

---

## Catégories de Formation

- Development
- Marketing
- Business
- Design
- Finance

---

## Résumé

Kariera est une plateforme éducative mobile complète qui facilite la découverte et l'inscription à des formations professionnelles. Elle offre une expérience personnalisée aux étudiants (recommandations basées sur leurs objectifs) et des outils de gestion complets aux formateurs pour publier et suivre leurs formations.
