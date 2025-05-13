import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime? parseBirthdayString(String? birthdayString) {
  if (birthdayString == null || birthdayString.isEmpty) return null;
  try {
    return DateTime.parse(birthdayString);
  } catch (_) {}
  List<String> formats = [
    'yyyy-MM-dd',
    'dd/MM/yyyy',
    'dd-MM-yyyy',
    'MM/dd/yyyy',
    'yyyy/MM/dd',
    'dd MM yyyy',
    'yyyy-MM-dd HH:mm:ss'
  ];
  for (var formatString in formats) {
    try {
      final format = DateFormat(formatString);
      return format
          .parseStrict(birthdayString.replaceAll(RegExp(r'\s+/'), '/'));
    } catch (_) {}
  }
  return null;
}

String calculateAge(String? birthdayString) {
  final birthDate = parseBirthdayString(birthdayString);
  if (birthDate == null) return 'N/A';
  final today = DateTime.now();
  int age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age > 0 ? '$age' : 'N/A';
}

String getWesternZodiacSign(DateTime? birthDate) {
  if (birthDate == null) return 'N/A';
  int day = birthDate.day;
  int month = birthDate.month;
  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '♈ Aries';

  if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return '♓ Pisces';
  return 'N/A';
}

String getChineseZodiacSign(DateTime? birthDate) {
  if (birthDate == null) return 'N/A';
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

String getZodiacName(String? zodiacSignWithSymbol) {
  if (zodiacSignWithSymbol == null || zodiacSignWithSymbol == 'N/A') {
    return 'N/A';
  }
  var parts = zodiacSignWithSymbol.split(' ');
  return parts.length > 1 ? parts[1] : zodiacSignWithSymbol;
}

IconData getIconForWesternZodiac(String? zodiacSignWithSymbol) {
  if (zodiacSignWithSymbol == null || zodiacSignWithSymbol == 'N/A') {
    return Icons.star_outline;
  }
  final signName = getZodiacName(zodiacSignWithSymbol).toLowerCase();
  switch (signName) {
    case 'aries':
      return Icons.local_fire_department_outlined;

    case 'pisces':
      return Icons.waves_outlined;
    default:
      return Icons.star_outline;
  }
}

String formatBirthdayForDisplay(String? birthdayString) {
  if (birthdayString == null || birthdayString.isEmpty) return "N/A";
  final birthDate = parseBirthdayString(birthdayString);
  if (birthDate == null) return birthdayString;
  return DateFormat('dd MMM yyyy').format(birthDate);
}
