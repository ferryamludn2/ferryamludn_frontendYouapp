import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({Key? key}) : super(key: key);

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final nameController = TextEditingController();
  final birthdayController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final interestsController = TextEditingController();

  int _currentStep = 0;
  String? username;
  String? token;

  static const Color accentColor = Color(0xFFD1AF64);
  static const Color cardBgColor = Color(0xFF162329);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'username';
      token = prefs.getString('token');
    });
  }

  Future<void> _submitProfile() async {
    if (token == null) {
      _showPopup("Error", "Token not found");
      return;
    }

    final profileData = {
      "name": username,
      "birthday": birthdayController.text.isNotEmpty
          ? birthdayController.text
          : "2025-02-06 15:30:00",
      "height": double.tryParse(heightController.text) ?? 0,
      "weight": double.tryParse(weightController.text) ?? 0,
      "interests": interestsController.text.isNotEmpty
          ? interestsController.text.split(',').map((e) => e.trim()).toList()
          : ["makan"],
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        Uri.parse(
            'https://ferryamludn-youapp-backend1.vercel.app/api/createProfile'),
        headers: headers,
        body: jsonEncode(profileData),
      );

      final responseBody = response.body;
      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text("Completed, go to login page again."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.offAllNamed('/login');
                  },
                  child: const Text("Continue"),
                ),
              ],
            );
          },
        );
      } else {
        _showPopup("Error", "Failed to create profile: $responseBody");
      }
    } catch (e) {
      _showPopup("Error", "An error occurred: $e");
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0 && birthdayController.text.isEmpty) {
      _showPopup("Error", "Please select your birthday");
      return;
    }
    if (_currentStep == 1 &&
        (heightController.text.isEmpty || weightController.text.isEmpty)) {
      _showPopup("Error", "Please fill in your height and weight");
      return;
    }
    if (_currentStep == 2 && interestsController.text.isEmpty) {
      _showPopup("Error", "Please enter your interests");
      return;
    }
    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      _submitProfile();
    }
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          steps: [
            Step(
              title: const Text("Welcome"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi $username, please complete your profile.",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: birthdayController,
                    decoration: InputDecoration(
                      labelText: "Birthday",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: accentColor,
                                onPrimary: Colors.black,
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: cardBgColor,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          birthdayController.text =
                              DateFormat('yyyy-MM-dd HH:mm:ss')
                                  .format(pickedDate);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Step(
              title: const Text("Physical Info"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: heightController,
                    decoration: InputDecoration(
                      labelText: "Height (cm)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: weightController,
                    decoration: InputDecoration(
                      labelText: "Weight (kg)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text("Interests"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: interestsController,
                    decoration: InputDecoration(
                      labelText: "Interests (comma-separated)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              ),
              content: Center(
                child: ElevatedButton(
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            context.go('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Go to Login Page",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
