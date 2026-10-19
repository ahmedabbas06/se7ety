import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AppointmentInfoRow extends StatelessWidget {
  const AppointmentInfoRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            softWrap: true,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 17, color: AppColors.primary),
      ],
    );
  }
}
