import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/home_provider.dart';
import 'speciality_card.dart';

class SpecialitiesSection extends StatelessWidget {
  const SpecialitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    final List<Map<String, dynamic>> specialities = [
      {'title': 'جراحة عامة', 'icon': Icons.medical_services_outlined},
      {'title': 'دكتور قلب', 'icon': Icons.favorite_outline},
      {'title': 'أطفال', 'icon': Icons.child_care_outlined},
      {'title': 'أسنان', 'icon': Icons.medical_services_outlined},
      {'title': 'عظام', 'icon': Icons.accessibility_new_outlined},
      {'title': 'جلدية', 'icon': Icons.clean_hands_outlined},
    ];

    return SizedBox(
      height: 155,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: specialities.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = specialities[index];
          final String title = item['title'];
          final IconData icon = item['icon'];
          final bool isSelected = homeProvider.selectedSpeciality == title;

          return SpecialityCard(
            title: title,
            icon: icon,
            isSelected: isSelected,
            onTap: () {
              homeProvider.selectSpeciality(title);
            },
          );
        },
      ),
    );
  }
}
