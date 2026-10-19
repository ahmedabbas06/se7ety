import 'package:flutter/material.dart';

class BookingsSection extends StatelessWidget {
  const BookingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(),

        SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'حجوزاتي',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
