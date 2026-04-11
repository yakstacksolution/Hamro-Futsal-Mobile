import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/custom_dropdown_widget.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/profile_header_widget.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key, this.user});

  final UserData? user;

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  late String _selectedGender;
  late final TextEditingController _fullnameController;
  late final TextEditingController _dobController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final UserData? user = widget.user;
    _selectedGender = 'Other';
    _fullnameController = TextEditingController(text: _resolvedFullName(user));
    _dobController = TextEditingController(text: 'Not provided');
    _emailController = TextEditingController(
      text: _resolvedValue(user?.email, 'No email available'),
    );
    _phoneController = TextEditingController(
      text: _resolvedValue(user?.phone, 'No phone number'),
    );
    _locationController = TextEditingController(text: _resolvedLocation(user));
  }

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
    final UserData? user = widget.user;

    return Scaffold(
      backgroundColor: LightColor.backgroundWarm,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(
                name: _resolvedFullName(user),
                location: _resolvedLocation(user),
                avatarUrl: _resolvedAvatar(user) ?? '',
                backgroundColors: const <Color>[
                  LightColor.secondaryDark,
                  LightColor.secondary,
                  LightColor.primary,
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _fullnameController,
                      keyboardType: TextInputType.text,
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _dobController,
                      keyboardType: TextInputType.text,
                      labelText: 'Date of birth',
                      hintText: 'Date of birth',
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

                    CustomTextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'Email address',
                      hintText: 'Email address',
                      icon: Icons.email,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      labelText: 'Phone number',
                      hintText: '+977 9812345678',
                      icon: Icons.phone,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _locationController,
                      keyboardType: TextInputType.text,
                      labelText: 'Location',
                      hintText: 'Location',
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
      backgroundColor: LightColor.secondary,
      onPressed: () {},
    );
  }

  String _resolvedFullName(UserData? user) {
    if (user == null) {
      return 'Guest User';
    }

    if (user.fullName.trim().isNotEmpty) {
      return user.fullName;
    }

    if (user.name.trim().isNotEmpty) {
      return user.name;
    }

    return 'Guest User';
  }

  String _resolvedLocation(UserData? user) {
    if (user == null) {
      return 'Location not available';
    }

    final bool hasLatitude = user.latitude != null;
    final bool hasLongitude = user.longitude != null;

    if (hasLatitude && hasLongitude) {
      return '${user.latitude}, ${user.longitude}';
    }

    if (user.designation != null && user.designation!.trim().isNotEmpty) {
      return user.designation!;
    }

    return 'Location not available';
  }

  String? _resolvedAvatar(UserData? user) {
    final String? profilePhoto = user?.profilePhoto;
    if (profilePhoto == null || profilePhoto.trim().isEmpty) {
      return null;
    }

    return profilePhoto;
  }

  String _resolvedValue(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    return value;
  }
}
