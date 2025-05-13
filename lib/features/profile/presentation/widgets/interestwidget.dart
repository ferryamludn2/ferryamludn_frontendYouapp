import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Color defaultCardBackgroundColor = Color(0xFF162329);
const Color defaultChipBackgroundColor = Color(0xFF2D3C42);
const Color defaultTextColor = Colors.white;
const Color defaultLabelColor = Colors.white70;
const Color defaultIconColor = Colors.white;

class InterestDisplaySection extends StatelessWidget {
  final dynamic interestsData;
  final VoidCallback? onEdit;
  final String editRouteName;
  final bool showEditButton;

  const InterestDisplaySection({
    super.key,
    required this.interestsData,
    this.onEdit,
    this.editRouteName = '/interest-select',
    this.showEditButton = true,
  });

  List<String> _parseInterests() {
    List<String> interestsList = [];
    if (interestsData is List) {
      interestsList = (interestsData as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (interestsData is String && interestsData.isNotEmpty) {
      interestsList = interestsData
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return interestsList;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> interestsList = _parseInterests();
    final bool hasInterests = interestsList.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: defaultCardBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Interest",
                style: TextStyle(
                  color: defaultTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showEditButton)
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: defaultIconColor, size: 20),
                  onPressed: onEdit ??
                      () {
                        context.go(editRouteName);
                      },
                ),
            ],
          ),
          const SizedBox(height: 12),
          hasInterests
              ? Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: interestsList
                      .map(
                        (interest) => Chip(
                          label: Text(
                            interest,
                            style: const TextStyle(
                                color: defaultTextColor, fontSize: 13),
                          ),
                          backgroundColor: defaultChipBackgroundColor,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                      .toList(),
                )
              : const Text(
                  "Add in your interest to find a better match",
                  style: TextStyle(color: defaultLabelColor, fontSize: 14),
                ),
        ],
      ),
    );
  }
}
