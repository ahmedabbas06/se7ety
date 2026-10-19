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
      children: [
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),

        SizedBox(width: 8),

        Icon(icon, size: 17, color: AppColors.primary),
      ],
    );
  }
}
