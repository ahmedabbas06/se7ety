import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';
import 'contact_row.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userData;

        return Column(
          children: [
            const Divider(),

            const SizedBox(height: 12),

            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'معلومات التواصل',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F0FC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ContactRow(
                    icon: Icons.email_outlined,
                    text: user?.email ?? 'غير محدد',
                  ),

                  const SizedBox(height: 10),

                  ContactRow(
                    icon: Icons.phone_outlined,
                    text: (user?.phone != null && user!.phone!.isNotEmpty)
                        ? user.phone!
                        : 'لم تضف',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
