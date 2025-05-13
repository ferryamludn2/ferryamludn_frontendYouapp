import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../../core/utils/profile_utils.dart';

class ProfileModel {
  final String username;
  final String name;
  final String? birthdayString;
  final String? gender;
  final int? height;
  final int? weight;
  final List<String> interests;
  final String? profileImageUrlApi;
  final String? localImagePath;

  final DateTime? birthDate;
  final String displayAge;
  final String displayBirthday;
  final String westernZodiac;
  final String westernZodiacName;
  final IconData westernZodiacIcon;
  final String chineseZodiac;

  ProfileModel({
    required this.username,
    required this.name,
    this.birthdayString,
    this.gender,
    this.height,
    this.weight,
    this.interests = const [],
    this.profileImageUrlApi,
    this.localImagePath,
  })  : birthDate = parseBirthdayString(birthdayString),
        displayAge = calculateAge(birthdayString),
        displayBirthday = formatBirthdayForDisplay(birthdayString),
        westernZodiac =
            getWesternZodiacSign(parseBirthdayString(birthdayString)),
        westernZodiacName = getZodiacName(
            getWesternZodiacSign(parseBirthdayString(birthdayString))),
        westernZodiacIcon = getIconForWesternZodiac(
            getWesternZodiacSign(parseBirthdayString(birthdayString))),
        chineseZodiac =
            getChineseZodiacSign(parseBirthdayString(birthdayString));

  factory ProfileModel.fromMap(
      Map<String, dynamic> map, String? localImagePath) {
    dynamic rawInterests = map['interests'];
    List<String> parsedInterests = [];
    if (rawInterests is List) {
      parsedInterests = rawInterests
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (rawInterests is String && rawInterests.isNotEmpty) {
      parsedInterests = rawInterests
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return ProfileModel(
      username: map['username'] as String? ?? map['name'] as String? ?? 'user',
      name: map['name'] as String? ?? 'N/A',
      birthdayString: map['birthday'] as String?,
      gender: map['gender'] as String?,
      height: map['height'] is String
          ? int.tryParse(map['height'])
          : map['height'] as int?,
      weight: map['weight'] is String
          ? int.tryParse(map['weight'])
          : map['weight'] as int?,
      interests: parsedInterests,
      profileImageUrlApi: map['profileImageUrl'] as String?,
      localImagePath: localImagePath,
    );
  }

  ImageProvider? getDisplayImageProvider() {
    if (localImagePath != null && File(localImagePath!).existsSync()) {
      return FileImage(File(localImagePath!))..evict();
    } else if (profileImageUrlApi != null && profileImageUrlApi!.isNotEmpty) {
      return NetworkImage(profileImageUrlApi!);
    }
    return null;
  }
}
