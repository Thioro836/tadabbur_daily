class AppLocalizations {
  final String locale;

  AppLocalizations(this.locale);

  static const Map<String, Map<String, String>> _translations = {
    'fr': {
      // Home Screen
      'homeTitle': 'verset du jour',
      'chooseSurah': 'Choisir une sourate',
      'verses': 'versets',

      // Journal Screen
      'journalTitle': 'Méditation',
      'whatStruckMe': 'Ce qui m\'a marqué',
      'howIdentify': 'Comment je m\'y identifie',
      'myDuaa': 'Mon du\'a (invocation)',
      'save': 'Enregistrer',
      'saved': '✅ Méditation enregistrée !',
      'updated': '✏️ Méditation mise à jour !',

      // Dashboard Screen
      'dashboardTitle': 'Mon Tableau de Bord',
      'noMeditationYet':
          'Aucune méditation pour le moment.\nCommencez par méditer un verset ! 🌙',
      'last7Days': '📈 7 derniers jours',
      'streakTitle': '🔥 Votre Série',
      'meditationCount': 'Méditations',
      'weeklyAverage': 'Moyenne par jour',
      'totalMeditations': 'Total',

      // Favorites Screen
      'favoritesTitle': 'Mes Favoris',
      'noFavorites': 'Aucun favori pour le moment ⭐',

      // Settings Screen
      'settingsTitle': 'Paramètres',
      'preferences': '⚙️ Préférences',
      'notifications': '🔔 Notifications',
      'dailyReminder': 'Rappel quotidien à 8h',
      'darkMode': '🌙 Mode sombre',
      'darkModeDesc': 'Thème adapté pour la nuit',
      'dataManagement': '🗂️ Gestion des données',
      'exportData': 'Exporter mes données',
      'exportDataDesc': 'Copie JSON dans le presse-papier',
      'exportedToClipboard': '✅ Données exportées dans le presse-papier !',
      'cleanData': 'Nettoyer (+90 jours)',
      'cleanDataDesc': 'Supprime les anciennes méditations',
      'cleanDataConfirm': '🧹 Nettoyer les données',
      'cleanDataMessage':
          'Supprimer les méditations de plus de 90 jours ?\n\nLes favoris ne seront pas affectés.',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'entriesDeleted': '🗑️ {{count}} entrée(s) supprimée(s)',
      'deleteAll': 'Tout supprimer',
      'deleteAllDesc': 'Efface toutes les données',
      'deleteAllConfirm': '⚠️ Tout supprimer',
      'deleteAllMessage':
          'Cette action est irréversible !\n\nToutes vos méditations, favoris et paramètres seront supprimés.',
      'allDataDeleted': '🗑️ Toutes les données ont été supprimées',
      'about': '📱 À propos',
      'appName': 'Tadabbur Daily',
      'version': 'Version 1.0.0',
      'verseSource': 'Source des versets',
      'verseSourceAPI': 'API Al-Quran Cloud',

      // Bottom Navigation
      'home': 'Accueil',
      'journal': 'Journal',
      'dashboard': 'Tableau de bord',
      'favorites': 'Favoris',
      'settings': 'Paramètres',

      // Common
      'error': 'Erreur !',
      'loading': 'Chargement...',
      'verseAddedToFavorites': 'Verset ajouté aux favoris ⭐',
      'verseCopied': 'Verset copié ! 📋',
    },
    'en': {
      // Home Screen
      'homeTitle': 'Verse of the day',
      'chooseSurah': 'Choose a surah',
      'verses': 'verses',

      // Journal Screen
      'journalTitle': 'Meditation',
      'whatStruckMe': 'What struck me',
      'howIdentify': 'How I identify with it',
      'myDuaa': 'My du\'a (invocation)',
      'save': 'Save',
      'saved': '✅ Meditation saved!',
      'updated': '✏️ Meditation updated!',

      // Dashboard Screen
      'dashboardTitle': 'My Dashboard',
      'noMeditationYet':
          'No meditation yet.\nStart by meditating on a verse! 🌙',
      'last7Days': '📈 Last 7 days',
      'streakTitle': '🔥 Your Streak',
      'meditationCount': 'Meditations',
      'weeklyAverage': 'Average per day',
      'totalMeditations': 'Total',

      // Favorites Screen
      'favoritesTitle': 'My Favorites',
      'noFavorites': 'No favorites yet ⭐',

      // Settings Screen
      'settingsTitle': 'Settings',
      'preferences': '⚙️ Preferences',
      'notifications': '🔔 Notifications',
      'dailyReminder': 'Daily reminder at 8am',
      'darkMode': '🌙 Dark mode',
      'darkModeDesc': 'Night-friendly theme',
      'dataManagement': '🗂️ Data Management',
      'exportData': 'Export my data',
      'exportDataDesc': 'JSON copy to clipboard',
      'exportedToClipboard': '✅ Data exported to clipboard!',
      'cleanData': 'Clean (+90 days)',
      'cleanDataDesc': 'Remove old meditations',
      'cleanDataConfirm': '🧹 Clean data',
      'cleanDataMessage':
          'Delete meditations older than 90 days?\n\nFavorites will not be affected.',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'entriesDeleted': '🗑️ {{count}} entry(ies) deleted',
      'deleteAll': 'Delete all',
      'deleteAllDesc': 'Delete all data',
      'deleteAllConfirm': '⚠️ Delete everything',
      'deleteAllMessage':
          'This action is irreversible!\n\nAll your meditations, favorites and settings will be deleted.',
      'allDataDeleted': '🗑️ All data has been deleted',
      'about': '📱 About',
      'appName': 'Tadabbur Daily',
      'version': 'Version 1.0.0',
      'verseSource': 'Verse source',
      'verseSourceAPI': 'API Al-Quran Cloud',

      // Bottom Navigation
      'home': 'Home',
      'journal': 'Journal',
      'dashboard': 'Dashboard',
      'favorites': 'Favorites',
      'settings': 'Settings',

      // Common
      'error': 'Error!',
      'loading': 'Loading...',
      'verseAddedToFavorites': 'Verse added to favorites ⭐',
      'verseCopied': 'Verse copied! 📋',
    },
  };

  String get(String key) {
    return _translations[locale]?[key] ?? key;
  }

  String translate(String key, {Map<String, String>? params}) {
    String text = _translations[locale]?[key] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{{$k}}', v);
      });
    }
    return text;
  }

  static AppLocalizations of(String locale) {
    return AppLocalizations(locale);
  }
}
