class JournalEntry {
  final String id;
  final String reflection; // User's reflection on the verse
  final String identification; // User's identification of the verse
  final String invocation; // User's invocation related to the verse
  final DateTime date;
  final int globalVerseNumber;
  final bool isCompleted;

  JournalEntry({
    required this.id,
    this.reflection = '',
    this.identification = '',
    this.invocation = '',
    required this.globalVerseNumber,
    required this.date,
    this.isCompleted = false,
  });

  JournalEntry copyWith({
    String? id,
    String? reflection,
    String? identification,
    String? invocation,
    DateTime? date,
    int? globalVerseNumber,
    bool? isCompleted,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      reflection: reflection ?? this.reflection,
      identification: identification ?? this.identification,
      invocation: invocation ?? this.invocation,
      date: date ?? this.date,
      globalVerseNumber: globalVerseNumber ?? this.globalVerseNumber,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
