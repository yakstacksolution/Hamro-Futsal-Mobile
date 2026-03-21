import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/custom_dropdown_widget.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/profile_header_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedGender = 'Male';

  final TextEditingController _fullnameController = TextEditingController(
    text: 'Joe Marie',
  );
  final TextEditingController _dobController = TextEditingController(
    text: '06 August 1992',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'joemarie@gmail.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '619 3456 7890',
  );
  final TextEditingController _locationController = TextEditingController(
    text: 'California, United states',
  );

  // Olive / army green palette
  // static const Color _primaryGreen = Color(0xFF7A8B3A);
  // static const Color _bgGrey = Color(0xFFF4F6F8);

  @override
  void dispose() {
    _fullnameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: _bgGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // _buildHeader(),
              ProfileHeader(
                name: "Dilli Bhandari",
                location: "Kathmandu, Nepal",
                avatarUrl: "https://i.pravatar.cc/150?img=47",
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomTextField(
                      keyboardType: TextInputType.text,
                      labelText: 'Full Name',
                      hintText: 'Joe Marie',
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 20),

                    const CustomTextField(
                      keyboardType: TextInputType.text,
                      labelText: 'Date of birth',
                      hintText: '06 August 1992',
                      icon: Icons.cake,
                    ),

                    const SizedBox(height: 20),
                    CustomDropdown(
                      labelText: "Gender",
                      icon: Icons.wc_rounded,
                      initialValue: _selectedGender,
                      options: ["Male", "Female", "Other"],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    const CustomTextField(
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'Email address',
                      hintText: 'joemarie@gmail.com',
                      icon: Icons.email,
                    ),

                    const SizedBox(height: 20),

                    const CustomTextField(
                      keyboardType: TextInputType.phone,
                      labelText: 'Phone number',
                      hintText: '+977 9812345678',
                      icon: Icons.phone,
                    ),

                    const SizedBox(height: 20),

                    const CustomTextField(
                      keyboardType: TextInputType.text,
                      labelText: 'Location',
                      hintText: 'California, United states',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 36),
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return CustomButton(
      text: "Save",
      minHeight: 45,
      borderRadius: 10,
      fontSize: 14,
      backgroundColor: LightColor.primaryGreen,
      onPressed: () {},
    );
  }
}
