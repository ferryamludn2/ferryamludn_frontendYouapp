import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileModel profile;

  const ProfileHeaderWidget({super.key, required this.profile});

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return "?";
    String initials = parts[0][0].toUpperCase();
    if (parts.length > 1 && parts[1].isNotEmpty) {
      initials += parts[1][0].toUpperCase();
    }
    return initials;
  }

  Color _getAvatarColor(String name) {
    final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final displayImageProvider = profile.getDisplayImageProvider();
    final initials = _getInitials(profile.username);
    final avatarColor = _getAvatarColor(profile.username);

    return Stack(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            image: displayImageProvider != null
                ? DecorationImage(
                    image: displayImageProvider,
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  )
                : null,
          ),
          child: displayImageProvider == null
              ? Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: avatarColor,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black12, Colors.black12],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "@${profile.username}${profile.displayAge != 'N/A' ? ', ${profile.displayAge}' : ''}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black87)],
                ),
              ),
              if (profile.gender != null &&
                  profile.gender!.isNotEmpty &&
                  profile.gender != "N/A") ...[
                const SizedBox(height: 4),
                Text(
                  profile.gender!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                  ),
                ),
              ],
              if (profile.westernZodiacName != 'N/A' &&
                  profile.westernZodiacName.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoChip(
                    profile.westernZodiacIcon, profile.westernZodiacName),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
