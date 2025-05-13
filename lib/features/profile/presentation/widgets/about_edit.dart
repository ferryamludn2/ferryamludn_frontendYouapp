// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_endpoint.dart';
import '../../../../core/constants/database_lokal.dart';
import 'interestwidget.dart';

class AboutEdit extends StatefulWidget {
  const AboutEdit({super.key});

  @override
  _AboutEditState createState() => _AboutEditState();
}

class _AboutEditState extends State<AboutEdit> {
  Map<String, dynamic>? _profile;
  String? _imagePath;
  String? _username;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  DateTime? _selectedBirthdayDate;

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female'];

  String _westernZodiac = 'N/A';
  String _chineseZodiac = 'N/A';

  bool _isLoading = true;
  String? _errorMessage;

  static const Color cardBgColor = Color(0xFF162329);
  static const Color inputFieldBgColor = Color(0xFF2D3C42);
  static const Color accentColor = Color(0xFFD1AF64);
  static const Color labelColor = Colors.white70;
  static const Color valueColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _loadLocalImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    _heightController.dispose();
    _weightController.dispose();
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
      if (mounted) context.go('/login');
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

      if (mounted) {
        if (response.statusCode == 200) {
          final profileData = jsonDecode(response.body);
          final dataToUse = profileData['data'] ?? profileData;
          setState(() {
            _profile = dataToUse;
            _username = dataToUse['username'] ?? dataToUse['name'] ?? "user";
            _nameController.text = dataToUse['name'] ?? '';

            String? birthdayFromAPI = dataToUse['birthday'];
            if (birthdayFromAPI != null && birthdayFromAPI.isNotEmpty) {
              try {
                _selectedBirthdayDate = DateTime.parse(birthdayFromAPI);
                _birthdayController.text =
                    DateFormat('dd MM yyyy').format(_selectedBirthdayDate!);
              } catch (e) {
                _birthdayController.text = '';
                _selectedBirthdayDate = null;
              }
            } else {
              _birthdayController.text = '';
              _selectedBirthdayDate = null;
            }

            _heightController.text = dataToUse['height']?.toString() ?? '';
            _weightController.text = dataToUse['weight']?.toString() ?? '';
            _selectedGender = dataToUse['gender'];
            if (_selectedGender == null ||
                !_genderOptions.contains(_selectedGender)) {
              _selectedGender = _genderOptions.first;
            }

            _calculateZodiacSigns(_selectedBirthdayDate);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                "Error ${response.statusCode}: Failed to load profile.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Network Error: Could not connect. $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadLocalImage() async {
    final imagePath = await LocalDatabase.instance.getImagePath();
    if (imagePath != null && mounted) {
      setState(() {
        _imagePath = imagePath;
      });
    }
  }

  void _calculateZodiacSigns(DateTime? birthDate) {
    if (birthDate != null) {
      _westernZodiac = _getWesternZodiacSign(birthDate);
      _chineseZodiac = _getChineseZodiacSign(birthDate);
    } else {
      _westernZodiac = 'N/A';
      _chineseZodiac = 'N/A';
    }
  }

  String _getWesternZodiacSign(DateTime birthDate) {
    int day = birthDate.day;
    int month = birthDate.month;
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return 'Gemini';
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) return 'Libra';
    if ((month == 10 && day >= 24) || (month == 11 && day <= 21)) {
      return 'Scorpio';
    }
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'Sagittarius';
    }
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'Capricorn';
    }
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'Aquarius';
    }
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'Pisces';
    return 'N/A';
  }

  String _getChineseZodiacSign(DateTime birthDate) {
    final year = birthDate.year;
    const chineseZodiacs = [
      'Rat',
      'Ox',
      'Tiger',
      'Rabbit',
      'Dragon',
      'Snake',
      'Horse',
      'Goat',
      'Monkey',
      'Rooster',
      'Dog',
      'Pig'
    ];
    int index = (year - 1900) % 12;
    if (index < 0) index += 12;
    return chineseZodiacs[index];
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdayDate ?? DateTime.now(),
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
    if (picked != null && picked != _selectedBirthdayDate) {
      setState(() {
        _selectedBirthdayDate = picked;
        _birthdayController.text = DateFormat('dd MM yyyy').format(picked);
        _calculateZodiacSigns(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/profile_image.png';
        await File(pickedFile.path).copy(imagePath);
        await LocalDatabase.instance.insertImagePath(imagePath);
        if (mounted) {
          setState(() {
            _imagePath = imagePath;
          });
        }
      }
    } else if (status.isDenied || status.isRestricted) {
      _showSnackBar(
          "Gallery access denied. Please allow in settings.", Colors.redAccent);
    } else if (status.isPermanentlyDenied) {
      _showSnackBar(
          "Gallery access permanently denied. Please open settings to allow.",
          Colors.redAccent);
      await openAppSettings();
    }
  }

  void _showImageOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBgColor,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Remove Profile Image',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _removeImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardBgColor,
          title:
              const Text('Remove Image', style: TextStyle(color: Colors.white)),
          content: const Text(
              'Are you sure you want to remove your profile image?',
              style: TextStyle(color: labelColor)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Remove',
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await LocalDatabase.instance.deleteImagePath();
      if (mounted) {
        setState(() {
          _imagePath = null;
        });
        _showSnackBar("Profile image removed.", Colors.orange);
      }
    }
  }

  Future<void> _updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      if (mounted) context.go('/login');
      return;
    }

    List<String> currentInterests = [];
    if (_profile != null && _profile!['interests'] != null) {
      if (_profile!['interests'] is List) {
        currentInterests =
            List<String>.from(_profile!['interests'].map((e) => e.toString()));
      }
    }

    final Map<String, dynamic> updatedProfileData = {
      'name': _nameController.text,
      'gender': _selectedGender,
      'interests': currentInterests,
    };

    if (_heightController.text.isNotEmpty) {
      updatedProfileData['height'] = int.tryParse(_heightController.text);
    }
    if (_weightController.text.isNotEmpty) {
      updatedProfileData['weight'] = int.tryParse(_weightController.text);
    }

    if (_selectedBirthdayDate != null) {
      updatedProfileData['birthday'] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedBirthdayDate!);
    } else if (_birthdayController.text.isNotEmpty) {
      try {
        DateTime parsedFromController =
            DateFormat('dd MM yyyy').parse(_birthdayController.text);
        updatedProfileData['birthday'] =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedFromController);
      } catch (e) {
        updatedProfileData['birthday'] = null;
      }
    }

    updatedProfileData.removeWhere(
        (key, value) => value == null && (key == 'height' || key == 'weight'));

    try {
      final response = await http.put(
        Uri.parse(ApiEndpoints.updateProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(updatedProfileData),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          _showSnackBar("Profile updated successfully!", Colors.green);
          context.go('/get-profile');
        } else {
          _showSnackBar(
              "Error ${response.statusCode}: Failed to update profile. ${response.body}",
              Colors.redAccent);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
            "Network Error: Could not update profile. $e", Colors.redAccent);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTextFieldRow(
      String label, TextEditingController controller, String hintText,
      {TextInputType? keyboardType,
      String? unit,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(color: labelColor, fontSize: 14)),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              style: const TextStyle(color: valueColor, fontSize: 14),
              keyboardType: keyboardType,
              decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: inputFieldBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 14.0),
                  suffixText: unit,
                  suffixStyle:
                      const TextStyle(color: labelColor, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String? currentValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(color: labelColor, fontSize: 14)),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: inputFieldBgColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentValue,
                  isExpanded: true,
                  dropdownColor: inputFieldBgColor,
                  icon: const Icon(Icons.arrow_drop_down, color: labelColor),
                  style: const TextStyle(color: valueColor, fontSize: 14),
                  items: items.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(color: labelColor, fontSize: 14)),
          ),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: inputFieldBgColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(value.isEmpty ? 'N/A' : value,
                  style: const TextStyle(color: valueColor, fontSize: 14)),
            ),
          ),
        ],
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.go('/get-profile'),
          ),
          title: Text(
            _isLoading ? "Loading..." : "@${_username ?? 'user'}",
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!,
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 16),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                            onPressed: _fetchProfile,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            "@${_username ?? 'user'},",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("About",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  TextButton(
                                    onPressed: _updateProfile,
                                    child: const Text("Save & Update",
                                        style: TextStyle(
                                            color: accentColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_imagePath != null) {
                                        _showImageOptionsBottomSheet();
                                      } else {
                                        _pickImage();
                                      }
                                    },
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: inputFieldBgColor,
                                        borderRadius: BorderRadius.circular(10),
                                        image: _imagePath != null
                                            ? DecorationImage(
                                                image: FileImage(
                                                    File(_imagePath!)),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _imagePath == null
                                          ? const Center(
                                              child: Icon(
                                                  Icons.add_a_photo_outlined,
                                                  color: Colors.white70,
                                                  size: 30))
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (_imagePath != null) {
                                          _showImageOptionsBottomSheet();
                                        } else {
                                          _pickImage();
                                        }
                                      },
                                      child: Text(
                                        _imagePath == null
                                            ? "Add image"
                                            : "Tap image to change",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextFieldRow("Display name:",
                                  _nameController, "Enter display name"),
                              _buildDropdownRow(
                                  "Gender:", _selectedGender, _genderOptions,
                                  (newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              }),
                              _buildTextFieldRow("Birthday:",
                                  _birthdayController, "DD MM YYYY",
                                  readOnly: true,
                                  onTap: () => _selectBirthday(context)),
                              _buildDisplayRow("Horoscope:", _westernZodiac),
                              _buildDisplayRow("Zodiac:", _chineseZodiac),
                              _buildTextFieldRow(
                                  "Height:", _heightController, "Height",
                                  keyboardType: TextInputType.number,
                                  unit: "cm"),
                              _buildTextFieldRow(
                                  "Weight:", _weightController, "Weight",
                                  keyboardType: TextInputType.number,
                                  unit: "kg"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        if (_profile != null)
                          InterestDisplaySection(
                            interestsData: _profile!['interests'],
                            showEditButton: true,
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
