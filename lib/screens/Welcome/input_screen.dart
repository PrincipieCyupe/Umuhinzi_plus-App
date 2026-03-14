import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: InputDetails()),
  );
}

class InputDetails extends StatefulWidget {
  const InputDetails({super.key});

  @override
  State<InputDetails> createState() => _InputDetailsState();
}

class _InputDetailsState extends State<InputDetails> {
  //  Simple variables to hold user selections
  String? selectedCrop;
  String? selectedSeason;
  String? selectedProvince;
  String? selectedDistrict;

  // Sample lists
  final List<String> crops = [
    'Maize',
    'Beans',
    'Rice',
    'Cassava',
    'Irish Potatoes',
    'Bananas',
    'Coffee',
    'Tea',
  ];
  final List<String> seasons = ['Season A', 'Season B', 'Season C'];
  final List<String> provinces = [
    'Kigali City',
    'Northern Province',
    'Southern Province',
    'Eastern Province',
    'Western Province',
  ];

  // Maps Provinces to their specific Districts
  final Map<String, List<String>> districtsByProvince = {
    'Kigali City': ['Gasabo', 'Kicukiro', 'Nyarugenge'],
    'Northern Province': ['Burera', 'Gakenke', 'Gicumbi', 'Musanze', 'Rulindo'],
    'Southern Province': [
      'Gisagara',
      'Huye',
      'Kamonyi',
      'Muhanga',
      'Nyamagabe',
      'Nyanza',
      'Nyaruguru',
      'Ruhango',
    ],
    'Eastern Province': [
      'Bugesera',
      'Gatsibo',
      'Kayonza',
      'Kirehe',
      'Ngoma',
      'Nyagatare',
      'Rwamagana',
    ],
    'Western Province': [
      'Karongi',
      'Ngororero',
      'Nyabihu',
      'Nyamasheke',
      'Rubavu',
      'Rusizi',
      'Rutsiro',
    ],
  };

  List<String> currentDistricts = [];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: screenHeight * 0.30,
              decoration: const BoxDecoration(
                color: Color(0xFF0C4D32),
              ),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: "UMUHIN",
                              style: TextStyle(color: Color(0xFF3FAE4A)),
                            ),
                            TextSpan(
                              text: "ZI+",
                              style: TextStyle(color: Color(0xFFFFF000)),
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        top: -16,
                        left: 146,
                        child: Transform.rotate(
                          angle: -0.3,
                          child: const Icon(
                            Icons.eco,
                            color: Color(0xFF3FAE4A),
                            size: 28,
                          ),
                        ),
                      ),

                      Positioned(
                        top: -16,
                        left: 220,
                        child: Transform.rotate(
                          angle: -0.3,
                          child: const Icon(
                            Icons.eco,
                            color: Color(0xFF3FAE4A),
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Form Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Join the future of farming",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  const Text(
                    "Get reliable, timely, and easy-to-understand agricultural information based on what you grow, season, and your location.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // 3. The Dropdowns
                  _buildDropdown(
                    hint: "Main crop",
                    value: selectedCrop,
                    items: crops,
                    onChanged: (val) => setState(() => selectedCrop = val),
                  ),

                  const SizedBox(height: 16),

                  _buildDropdown(
                    hint: "Season",
                    value: selectedSeason,
                    items: seasons,
                    onChanged: (val) => setState(() => selectedSeason = val),
                  ),

                  const SizedBox(height: 16),

                  _buildDropdown(
                    hint: "Farm location (Province)",
                    value: selectedProvince,
                    items: provinces,
                    onChanged: (val) {
                      setState(() {
                        selectedProvince = val;
                        // Reset district when province changes and load new districts
                        selectedDistrict = null;
                        currentDistricts = districtsByProvince[val] ?? [];
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildDropdown(
                    hint: "Farm location (District)",
                    value: selectedDistrict,
                    items: currentDistricts,
                    // Disable this dropdown if no province is selected yet
                    onChanged: currentDistricts.isEmpty
                        ? null
                        : (val) => setState(() => selectedDistrict = val),
                  ),

                  SizedBox(height: screenHeight * 0.06),

                  // 4. Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF3FAE4A,
                        ), // Green button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // TODO: Trigger your BLoC Event here
                        // e.g., context.read<OnboardingBloc>().add(SaveDetailsEvent(...));
                        print(
                          "Saved: $selectedCrop, $selectedSeason, $selectedProvince, $selectedDistrict",
                        );
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create the dropdown
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          isExpanded: true,
          // If onChanged is null (like when District is disabled), disable the dropdown visually
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
