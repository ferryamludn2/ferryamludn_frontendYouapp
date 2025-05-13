import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/api_endpoint.dart';
import '../../../../../core/constants/database_lokal.dart';
import '../models/profile_model.dart';

class ProfileService {
  Future<ProfileModel?> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return null;
    }

    String? localImagePath = await LocalDatabase.instance.getImagePath();

    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileJson = jsonDecode(response.body);
        final dataToUse = profileJson['data'] ?? profileJson;
        await prefs.setString('profileData', jsonEncode(dataToUse));
        return ProfileModel.fromMap(dataToUse, localImagePath);
      } else {
        final cachedData = await _loadProfileFromCache();
        if (cachedData != null) {
          return ProfileModel.fromMap(cachedData, localImagePath);
        }
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      final cachedData = await _loadProfileFromCache();
      if (cachedData != null) {
        return ProfileModel.fromMap(cachedData, localImagePath);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _loadProfileFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final localDataString = prefs.getString('profileData');
    if (localDataString != null) {
      return jsonDecode(localDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('profileData');
    await LocalDatabase.instance.deleteImagePath();
  }
}
