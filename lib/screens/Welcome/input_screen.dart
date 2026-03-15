import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/rwanda_data.dart';
import '../../presentation/blocs/input_details/input_details_bloc.dart';
import '../../presentation/blocs/input_details/input_details_event.dart';
import '../../presentation/blocs/input_details/input_details_state.dart';
import '../home_screen.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: InputDetails()),
  );
}

class InputDetails extends StatelessWidget {
  const InputDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InputDetailsBloc(),
      child: const InputDetailsView(),
    );
  }
}

class InputDetailsView extends StatelessWidget {
  const InputDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<InputDetailsBloc, InputDetailsState>(
        listener: (context, state) {
          // Show success message when saved
          if (state.isSaved) {
            // Navigate to home screen with the selected district
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Home(selectedDistrict: state.selectedDistrict),
              ),
            );
          }
          // Show error message if any
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.30,
                  decoration: const BoxDecoration(color: Color(0xFF0C4D32)),
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
                      // Crop Dropdown
                      _buildDropdown(
                        context: context,
                        hint: "Main crop",
                        value: state.selectedCrop,
                        items: Crops.crops,
                        onChanged: (val) {
                          if (val != null) {
                            context.read<InputDetailsBloc>().add(
                              SelectCrop(crop: val),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Season Dropdown
                      _buildDropdown(
                        context: context,
                        hint: "Season",
                        value: state.selectedSeason,
                        items: Seasons.seasons,
                        onChanged: (val) {
                          if (val != null) {
                            context.read<InputDetailsBloc>().add(
                              SelectSeason(season: val),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Province Dropdown
                      _buildDropdown(
                        context: context,
                        hint: "Farm location (Province)",
                        value: state.selectedProvince,
                        items: Provinces.provinces,
                        onChanged: (val) {
                          if (val != null) {
                            context.read<InputDetailsBloc>().add(
                              SelectProvince(province: val),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // District Dropdown
                      _buildDropdown(
                        context: context,
                        hint: "Farm location (District)",
                        value: state.selectedDistrict,
                        items: state.currentDistricts,
                        // Disable this dropdown if no province is selected yet
                        onChanged: state.currentDistricts.isEmpty
                            ? null
                            : (val) {
                                if (val != null) {
                                  context.read<InputDetailsBloc>().add(
                                    SelectDistrict(district: val),
                                  );
                                }
                              },
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      // Save Button
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
                            // Trigger BLoC event to save
                            context.read<InputDetailsBloc>().add(
                              const SaveInputDetails(),
                            );

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Farm details saved successfully!',
                                ),
                                backgroundColor: Color(0xFF3FAE4A),
                              ),
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
          );
        },
      ),
    );
  }

  // Helper method to create the dropdown
  Widget _buildDropdown({
    required BuildContext context,
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
