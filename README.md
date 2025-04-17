# Application de Liste de Courses avec Géolocalisation

Application mobile Flutter permettant de gérer des listes de courses avec notifications de proximité des magasins favoris.

## Fonctionnalités

- Authentification utilisateur (inscription/connexion)
- Gestion de plusieurs listes de courses
- Ajout, modification et suppression d'articles
- Organisation des articles par catégorie
- Marquage des articles comme achetés
- Gestion des magasins favoris avec géolocalisation
- Notifications de proximité (500m) des magasins favoris

## Configuration requise

- Flutter SDK
- Firebase project avec:
  - Authentication
  - Cloud Firestore
- Clé API Google Maps

## Installation

1. Cloner le projet
2. Installer les dépendances :
   ```bash
   flutter pub get
   ```
3. Configurer Firebase :
   - Créer un projet Firebase
   - Ajouter une application Android/iOS
   - Télécharger le fichier de configuration
   - Activer l'authentification par email/mot de passe
   - Activer Cloud Firestore

4. Configurer Google Maps :
   - Obtenir une clé API Google Maps
   - Ajouter la clé dans AndroidManifest.xml et Info.plist

5. Lancer l'application :
   ```bash
   flutter run
   ```

## Structure du projet

```
lib/
├── models/          # Modèles de données
├── screens/         # Écrans de l'application
│   ├── auth/        # Écrans d'authentification
│   ├── home/        # Écran principal
│   ├── shopping/     # Gestion des listes
│   └── stores/       # Gestion des magasins
├── services/        # Services (Auth, Firebase, etc.)
├── utils/           # Utilitaires
└── widgets/         # Widgets réutilisables
```

## Base de données

Structure Firestore :

```
users/
 ├── userId/
     ├── profile/
     ├── shoppingLists/
     │   ├── listId/
     │       ├── name
     │       ├── items/
     │           ├── itemId/
     │               ├── name
     │               ├── category
     │               ├── quantity
     │               └── purchased
     └── favoriteStores/
         ├── storeId/
             ├── name
             ├── location
             └── radius
```
