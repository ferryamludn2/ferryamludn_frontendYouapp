// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/constants/api_endpoint.dart';

class InterestSelect extends StatefulWidget {
  const InterestSelect({super.key});

  @override
  _InterestSelectState createState() => _InterestSelectState();
}

class _InterestSelectState extends State<InterestSelect> {
  Map<String, dynamic>? _profile;
  List<String> _interests = [];
  final TextEditingController _interestController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  static const String keyName = 'name';
  static const String keyBirthday = 'birthday';
  static const String keyHeight = 'height';
  static const String keyWeight = 'weight';
  static const String keyInterests = 'interests';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _interestController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      context.go('/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body);
        final dataToUse = profileData['data'] ?? profileData;
        setState(() {
          _profile = dataToUse;
          _interests = List<String>.from(dataToUse[keyInterests] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              "Error ${response.statusCode}: Failed to load profile.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network Error: Could not connect.";
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_profile == null) {
      _showSnackBar("Profile data not loaded.", Colors.redAccent);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      context.go('/login');
      return;
    }

    final updatedProfile = {
      'name': _profile![keyName] ?? "Herul Ja",
      'birthday': _profile![keyBirthday] ?? "2025-05-06 15:30:00",
      'height': _profile![keyHeight] ?? 20,
      'weight': _profile![keyWeight] ?? 20,
      'interests': _interests,
    };

    try {
      final response = await http.put(
        Uri.parse(ApiEndpoints.updateProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(updatedProfile),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Interests updated successfully!", Colors.green);

        context.go('/get-profile');
      } else {
        _showSnackBar(
            "Error ${response.statusCode}: Failed to update interests.",
            Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar(
          "Network Error: Could not update interests.", Colors.redAccent);
    }
  }

  void _addInterest(String interest) {
    if (interest.isEmpty || _interests.contains(interest)) return;
    setState(() {
      _interests.add(interest);
    });
    _interestController.clear();
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 2.4,
          colors: [
            Color(0xFF1F4247),
            Color(0xFF0D1D23),
            Color(0xFF09141A),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.go('/get-profile');
                },
              ),
              const Text(
                "Back",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _updateProfile,
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ],
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 2.4,
              colors: [
                Color(0xFF1F4247),
                Color(0xFF0D1D23),
                Color(0xFF09141A),
              ],
            ),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                            onPressed: _fetchProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 100),
                              const Text(
                                "Tell everyone about your self",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellowAccent,
                                ),
                              ),
                              const Text(
                                "What interest you?",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _interestController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white30,
                                  hintText: "Search Interests",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    _addInterest(value.trim());
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _interests
                                    .map(
                                      (interest) => Chip(
                                        label: Text(
                                          interest,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        backgroundColor: Colors.grey[700],
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onDeleted: () =>
                                            _removeInterest(interest),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
