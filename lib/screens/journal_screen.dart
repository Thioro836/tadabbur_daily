import 'package:flutter/material.dart';
import 'package:tadabbur_daily/models/verse.dart';

class JournalScreen extends StatefulWidget {
  final Verse verse;
  const JournalScreen({super.key, required this.verse});

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  // On crée des TextEditingController pour chaque TextField
  final _reflectionController = TextEditingController();
  final _identificationController = TextEditingController();
  final _invocationController = TextEditingController();

  // On n'oublie pas de les disposer pour éviter les fuites de mémoire
  @override
  void dispose() {
    _reflectionController.dispose();
    _identificationController.dispose();
    _invocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Méditation')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.verse.arabicText,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl, // Right-To-Left (arabe)
                style: TextStyle(fontSize: 24),
              ),
              Divider(thickness: 1, color: Colors.grey),
              SizedBox(height: 20),
              TextFormField(
                controller: _reflectionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Ce qui m\'a marqué',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _identificationController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Comment je m\'y identifie',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _invocationController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Mon du\'a(invocation)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: Text('Sauvegarder')),
            ],
          ),
        ),
      ),
    );
  }
}
