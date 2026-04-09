# 🌙 Tadabbur Daily

**Application de méditation quotidienne du Coran avec journal de réflexion et audio des versets**

Une application Flutter conçue pour vous aider à méditer et réfléchir sur les versets du Coran chaque jour, avec journal personnel et notifications quotidiennes.

## ✨ Features

- 📖 **Verset Aléatoire Quotidien** - Accédez à un nouveau verset chaque jour via l'API Al-Quran Cloud
- 🔊 **Audio des Versets** - Écoutez les récitations (Mishary Alafasy)
- 📝 **Journal de Réflexion** - Enregistrez vos pensées avec 3 catégories:
  - Ce qui m'a marqué
  - Comment je m'y identifie
  - Mon du'a (invocation)
- 🔥 **Statistiques** - Suivi du streak de méditation quotidienne
- ⭐ **Favoris** - Sauvegardez vos versets préférés
- 🔔 **Notifications** - Rappels quotidiens configurables
- 🌓 **Thème Sombre/Clair** - Interface adaptée à vos préférences
- 🌐 **Multilingue** - Support FR/EN avec polices Amiri pour l'arabe
- 💾 **Stockage Local** - Toutes vos données sauvegardées localement avec Hive

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
├── main.dart                 # Point d'entrée + ThemeData
├── models/
│   ├── verse.dart           # Modèle Verse
│   └── journal_entry.dart   # Modèle JournalEntry
├── screens/
│   ├── home_screen.dart     # Écran principal (verset + audio)
│   ├── dashboard_screen.dart # Statistiques et streak
│   ├── journal_screen.dart  # Édition du journal
│   └── favorites_screen.dart# Liste des favoris
└── services/
    ├── quran_service.dart       # Appels API Al-Quran Cloud
    ├── storage_service.dart     # Stockage local (Hive)
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
✅ Toutes permissions Android ajoutées  
✅ Configuration iOS complète  
✅ Tests web release réussis  
✅ Prêt pour production

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

- **Clés de journal**: `YYYY-MM-DD` → Map de réflexions
- **Clé favoris**: `fav_<global_verse_number>`
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
