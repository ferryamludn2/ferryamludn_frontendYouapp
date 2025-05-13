import 'package:get/get.dart';
import '../../data/datasources/data_source.dart';

class ProfileController extends GetxController {
  final ProfileRemoteDataSource profileRemoteDataSource;

  ProfileController({
    required this.profileRemoteDataSource,
  });

  var profile = {}.obs;

  Future<void> createProfile(
      String token, Map<String, dynamic> profileData) async {
    try {
      await profileRemoteDataSource.createProfile(token, profileData);
      Get.snackbar("Success", "Profile created successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> getProfile(String token) async {
    try {
      var result = await profileRemoteDataSource.getProfile(token);
      profile.value = result;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> updateProfile(
      String token, Map<String, dynamic> profileData) async {
    try {
      await profileRemoteDataSource.updateProfile(token, profileData);
      Get.snackbar("Success", "Profile updated successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
