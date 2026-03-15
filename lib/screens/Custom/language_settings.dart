import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Language Settings Screen
class LanguageSettings extends StatefulWidget {
  const LanguageSettings({super.key});

  @override
  State<LanguageSettings> createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<LanguageSettings> {
  String _selectedLanguage = 'en'; // Default: English

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'rw', 'name': 'Kinyarwanda', 'native': 'Ikinyarwanda'},
    {'code': 'fr', 'name': 'French', 'native': 'Français'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        backgroundColor: const Color(0xFF0C4D32),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = _selectedLanguage == language['code'];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF3FAE4A)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3FAE4A)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    language['code']!.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              title: Text(
                language['name']!,
                style: GoogleFonts.sourceSans3(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                language['native']!,
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF3FAE4A))
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
              onTap: () {
                setState(() {
                  _selectedLanguage = language['code']!;
                });
                // Save language preference
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language set to ${language['name']}'),
                    backgroundColor: const Color(0xFF3FAE4A),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
