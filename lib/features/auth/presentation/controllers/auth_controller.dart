import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../data/datasources/auth_datasource.dart';

class AuthController extends GetxController {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthController({required this.authRemoteDataSource});

  var token = ''.obs;

  Future<void> register(String email, String username, String password) async {
    try {
      await authRemoteDataSource.register(email, username, password);
      Get.snackbar("Success", "Registration successful");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      String result = await authRemoteDataSource.login(email, password);
      token.value = result;

      // Save token to Hive
      var box = await Hive.openBox('auth_box');
      box.put('token', result);

      Get.snackbar("Success", "Login successful");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> logout() async {
    try {
      var box = await Hive.openBox('auth_box');
      await box.delete('token');
      token.value = '';
      Get.snackbar("Success", "Logged out successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<String?> getToken() async {
    var box = await Hive.openBox('auth_box');
    return box.get('token');
  }
}
