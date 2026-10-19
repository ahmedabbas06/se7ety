import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../providers/auth_provider.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.userData?.name;

        final welcomeText = (userName != null && userName.isNotEmpty)
            ? 'مرحباً، $userName'
            : 'مرحباً بك';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              welcomeText,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 17,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'احجز الآن وكن جزءًا من رحلتك\nالصحية.',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }
}
