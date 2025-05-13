import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/profile_model.dart';

const Color cardBackgroundColor = Color(0xFF162329);
const Color labelColor = Colors.white60;
const Color valueColor = Colors.white;

const Color iconEditColor = Colors.white70;
const Color titleColor = Colors.white;

class ProfileAboutSectionWidget extends StatelessWidget {
  final ProfileModel profile;

  const ProfileAboutSectionWidget({super.key, required this.profile});

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty || value == "N/A") {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(color: labelColor, fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value == "N/A" ? "—" : value,
              style: const TextStyle(
                  color: valueColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayableBirthday = profile.displayBirthday;

    String displayableAgeString = "N/A";
    if (profile.displayAge.isNotEmpty && profile.displayAge != "N/A") {
      final int? ageYears = int.tryParse(profile.displayAge);

      if (ageYears != null && ageYears > 0) {
        displayableAgeString = "$ageYears years old";
      }
    }

    final String westernZodiacDisplay = profile.westernZodiac;
    final String chineseZodiacDisplay = profile.chineseZodiac;
    final String heightDisplay =
        profile.height != null ? '${profile.height} cm' : "N/A";
    final String weightDisplay =
        profile.weight != null ? '${profile.weight} kg' : "N/A";

    bool hasAnyAboutInfo = (displayableBirthday != "N/A" &&
            displayableBirthday.isNotEmpty) ||
        (displayableAgeString != "N/A") ||
        (westernZodiacDisplay != "N/A" && westernZodiacDisplay.isNotEmpty) ||
        (chineseZodiacDisplay != "N/A" && chineseZodiacDisplay.isNotEmpty) ||
        (heightDisplay != "N/A") ||
        (weightDisplay != "N/A");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'About',
                style: TextStyle(
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              InkWell(
                onTap: () => context.go('/about-edit'),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.edit_outlined,
                    color: iconEditColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasAnyAboutInfo) ...[
            _buildInfoRow('Birthday', displayableBirthday),
            if (displayableAgeString != "N/A")
              _buildInfoRow('Age', displayableAgeString),
            _buildInfoRow('Horoscope', westernZodiacDisplay),
            _buildInfoRow('Zodiac', chineseZodiacDisplay),
            _buildInfoRow('Height', heightDisplay),
            _buildInfoRow('Weight', weightDisplay),
          ] else
            const Text(
              "No information provided.",
              style: TextStyle(color: labelColor, fontSize: 14),
            ),
        ],
      ),
    );
  }
}
