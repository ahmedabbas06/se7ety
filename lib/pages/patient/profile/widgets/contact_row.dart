import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ContactRow extends StatelessWidget {
  const ContactRow({super.key, required this.icon, required this.text});

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
            style: TextStyle(fontSize: 13),
          ),
        ),

        SizedBox(width: 10),

        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}
