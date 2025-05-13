import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoint.dart';
import '../../../../core/error/exceptions.dart';

abstract class ProfileRemoteDataSource {
  Future<void> createProfile(String token, Map<String, dynamic> profileData);
  Future<Map<String, dynamic>> getProfile(String token);
  Future<void> updateProfile(String token, Map<String, dynamic> profileData);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<void> createProfile(
      String token, Map<String, dynamic> profileData) async {
    Uri url = Uri.parse(ApiEndpoints.createProfile);
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileData),
    );

    if (response.statusCode != 200) {
      throw const GeneralException(message: "Failed to create profile");
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile(String token) async {
    Uri url = Uri.parse(ApiEndpoints.getProfile);
    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw const GeneralException(message: "Failed to fetch profile");
    }
  }

  @override
  Future<void> updateProfile(
      String token, Map<String, dynamic> profileData) async {
    Uri url = Uri.parse(ApiEndpoints.updateProfile);
    var response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileData),
    );

    if (response.statusCode != 200) {
      throw const GeneralException(message: "Failed to update profile");
    }
  }
}
