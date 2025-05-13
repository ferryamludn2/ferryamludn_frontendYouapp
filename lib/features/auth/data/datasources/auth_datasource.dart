import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoint.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<String> register(String email, String username, String password);
  Future<String> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<String> register(
      String email, String username, String password) async {
    Uri url = Uri.parse(ApiEndpoints.register);
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return "Registration successful";
    } else {
      throw const GeneralException(message: "Registration failed");
    }
  }

  @override
  Future<String> login(String email, String password) async {
    Uri url = Uri.parse(ApiEndpoints.login);
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw const GeneralException(message: "Login failed");
    }
  }
}
