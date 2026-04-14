# 🌙 Tadabbur Daily

**Application de méditation quotidienne du Coran avec journal de réflexion et audio des versets**

Une application Flutter conçue pour vous aider à méditer et réfléchir sur les versets du Coran chaque jour, avec journal personnel et notifications quotidiennes.

## ✨ Features

- 📖 **Verset Aléatoire Quotidien** - Accédez à un nouveau verset chaque jour via l'API Al-Quran Cloud
- � **Recherche par Sourate** - Choisissez parmi les 114 sourates
- �🔊 **Audio des Versets** - Écoutez les récitations (Mishary Alafasy)
- 📝 **Journal de Réflexion** - Enregistrez vos pensées avec 3 catégories:
  - Ce qui m'a marqué
  - Comment je m'y identifie
  - Mon du'a (invocation)
- 🔥 **Statistiques** - Streak, total, graphique hebdomadaire (fl_chart)
- 📅 **Historique par mois** - Entrées regroupées avec sections repliables
- ⭐ **Favoris** - Sauvegardez vos versets préférés
- � **Partage** - Partagez un verset (mobile) ou copiez-le (desktop/web)
- �🔔 **Notifications** - Rappels quotidiens configurables
- 🌓 **Thème Sombre/Clair** - Interface adaptée à vos préférences
- 🌐 **Multilingue** - Support FR/EN avec polices Amiri pour l'arabe
- 💾 **Stockage Local** - Toutes vos données sauvegardées localement avec Hive
- 🗂️ **Gestion des données** - Export JSON, nettoyage automatique (+90j), suppression totale
- 🎨 **Splash Screen** - Écran de démarrage personnalisé

## 📋 Prerequisites

- Flutter 3.11.1 ou supérieur
- Dart SDK 3.11.1
- Android SDK (pour build Android)
- Xcode (pour build iOS)
- Node.js (optionnel, pour deployment web)

## 🚀 Installation

### 1. Cloner et installer les dépendances

```bash
git clone <repository-url>
cd tadabbur_daily
flutter pub get
```

### 2. Configuration Android

Pour la signature de la release, créer `android/key.properties`:

```properties
keyAlias=my-key-alias
keyPassword=***
storeFile=key.jks
storePassword=***
```

### 3. Lancer l'app en développement

```bash
flutter run
```

## 🏗️ Architecture

```
lib/
├── main.dart                 # Point d'entrée + ThemeData + Navigation 4 onglets
├── models/
│   ├── verse.dart           # Modèle Verse (avec audioUrl)
│   └── journal_entry.dart   # Modèle JournalEntry (avec copyWith)
├── screens/
│   ├── home_screen.dart     # Verset du jour + audio + recherche sourate
│   ├── dashboard_screen.dart # Stats, chart hebdo, historique par mois
│   ├── journal_screen.dart  # Édition du journal (3 champs)
│   ├── favorites_screen.dart# Liste des favoris
│   └── settings_screen.dart # Paramètres + gestion des données
└── services/
    ├── quran_service.dart       # Appels API Al-Quran Cloud
    ├── storage_service.dart     # Stockage local (Hive) + export/nettoyage
    └── notification_service.dart# Notifications locales
```

## 📦 Dépendances Principales

- **flutter** - Framework UI
- **hive_flutter** - Stockage local persistant
- **google_fonts** - Polices personnalisées (Amiri, Poppins)
- **http** - Appels API ReSTful
- **flutter_local_notifications** - Notifications du système
- **just_audio** - Lecture audio des versets
- **timezone** - Gestion des fuseaux horaires
- **share_plus** - Partage natif (mobile) / Presse-papier (desktop)
- **fl_chart** - Graphique hebdomadaire
- **flutter_native_splash** - Splash screen personnalisé
- **flutter_launcher_icons** - Icône de l'app

## 🔔 Configuration des Notifications

Les notifications sont automatiquement configurées au démarrage avec un rappel quotidien à **08:00**.

**Permissions requises:**

- Android: `POST_NOTIFICATIONS` (Android 13+)
- iOS: Permission à l'installation

## 🌐 API Utilisée

**Al-Quran Cloud API** (`https://api.alquran.cloud/v1`)

- Édition Quran: `quran-uthmani`
- Traductions: `fr.hamidullah`, `en.sahih`
- Audio: `ar.alafasy`
- Aucune clé API requise ✅

## 📱 Build & Deployment

### Android APK

```bash
flutter build apk --release
# Sortie: build/app/release/app-release.apk
```

### Android App Bundle (Google Play)

```bash
flutter build appbundle --release
# Sortie: build/app/release/app-release.aab
```

### iOS

```bash
flutter build ios --release
# Puis ouvrir dans Xcode: ios/Runner.xcworkspace
```

### Web

```bash
flutter build web --release
# Sortie: build/web/ (prêt pour deployment)
```

### Vérifications Pré-Deployment

```bash
# Analyser le code
flutter analyze

# Tester la compilation web
flutter build web --release

# Vérifier les versions
flutter --version
flutter doctor
```

## 🏅 État du Projet

✅ Code compilé avec succès  
✅ 89 tests passent (unitaires + intégration + widgets)  
✅ Toutes permissions Android ajoutées  
✅ Configuration iOS complète  
✅ Build AAB automatisé via GitHub Actions  
✅ Signature release configurée (keystore)  
✅ Prêt pour publication Google Play Store

## 🛠️ Développement

### Format le code Dart

```bash
flutter format lib/
```

### Analyser les erreurs/warnings

```bash
flutter analyze
```

### Nettoyer et reconstruire

```bash
flutter clean
flutter pub get
flutter run
```

## 📊 Structure de Données

### Hive Storage

- **Clés de journal**: `YYYY-MM-DD_<globalVerseNumber>` → Map de réflexions (plusieurs méditations/jour)
- **Clé favoris**: `fav_<global_verse_number>`
- **Clé verset du jour**: `daily_verse` (cache quotidien avec date + langue)
- **Clé langue**: `selected_language` (FR/EN)
- **Clé notifications**: `notifications_enabled`
- **Clé thème**: `dark_mode_enabled`

## 🎨 Thèmes

**Thème Clair (Light)**

- Primary: Teal
- Secondary: Dark Teal
- Background: Light Teal

**Thème Sombre (Dark)**

- Primary: Light Teal
- Secondary: Cyan
- Background: Dark Gray

## 📝 License

Propriétaire - Tous droits réservés

## 🤝 Support

Pour les bugs ou features demandes, veuillez ouvrir une issue dans le dépôt.

## 📚 Ressources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Al-Quran Cloud API](https://alquran.cloud/api)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
