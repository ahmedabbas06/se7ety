import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/profile_provider.dart';
import '../appointments/appointments_page.dart';
import '../doctors/doctor_details_page.dart';
import '../profile/patient_profile_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final existingProvider = Provider.of<HomeProvider?>(context, listen: false);

    if (existingProvider != null) {
      return SearchPageContent(homeProvider: existingProvider);
    }

    return ChangeNotifierProvider<HomeProvider>(
      create: (_) => HomeProvider()..getDoctors(),
      child: const SearchPageContent(),
    );
  }
}

class SearchPageContent extends StatefulWidget {
  const SearchPageContent({super.key, this.homeProvider});

  final HomeProvider? homeProvider;

  @override
  State<SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<SearchPageContent> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final homeProvider =
          widget.homeProvider ??
          Provider.of<HomeProvider>(context, listen: false);

      searchController.text = homeProvider.searchQuery;

      if (homeProvider.doctors.isEmpty &&
          !homeProvider.isLoading &&
          homeProvider.errorMessage == null) {
        homeProvider.getDoctors();
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                const SearchHeader(),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchField(
                    controller: searchController,
                    onChanged: homeProvider.searchDoctors,
                    onClear: () {
                      searchController.clear();
                      homeProvider.searchDoctors('');
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildSearchResults(homeProvider)),
              ],
            ),
          ),
          bottomNavigationBar: const SearchBottomNavigation(),
        );
      },
    );
  }

  Widget _buildSearchResults(HomeProvider homeProvider) {
    if (homeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (homeProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 50, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                homeProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 15),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: homeProvider.getDoctors,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (homeProvider.filteredDoctors.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 60),
          SvgPicture.asset('assets/no-search.svg', height: 160),
          const SizedBox(height: 20),
          Text(
            searchController.text.trim().isEmpty
                ? 'لا يوجد أطباء متاحون حالياً'
                : 'لا توجد نتائج بحث مطابقة',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (searchController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'جرّب البحث باسم الدكتور أو التخصص',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: homeProvider.filteredDoctors.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final doctor = homeProvider.filteredDoctors[index];

        return DoctorSearchCard(
          doctor: doctor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorDetailsPage(doctor: doctor),
              ),
            );
          },
        );
      },
    );
  }
}

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'البحث عن دكتور',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Positioned(
            right: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F0FA),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو التخصص',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: onClear,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class DoctorSearchCard extends StatelessWidget {
  const DoctorSearchCard({super.key, required this.doctor, this.onTap});

  final UserModel doctor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = doctor.image != null && doctor.image!.trim().isNotEmpty;

    final hasSpeciality =
        doctor.speciality != null && doctor.speciality!.trim().isNotEmpty;

    return Material(
      color: const Color(0xFFE2F2FC),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFB7E8A5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: hasImage
                      ? Image.network(
                          doctor.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.white,
                            );
                          },
                        )
                      : const Icon(Icons.person, size: 32, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      doctor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (hasSpeciality) ...[
                      const SizedBox(height: 3),
                      Text(
                        doctor.speciality!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (doctor.rating != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.orange, size: 17),
                const SizedBox(width: 2),
                Text(
                  doctor.rating!.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBottomNavigation extends StatelessWidget {
  const SearchBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'الملف الشخصي',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider<ProfileProvider>(
                      create: (_) => ProfileProvider(),
                      child: const PatientProfilePage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_outline),
            ),
            IconButton(
              tooltip: 'المواعيد',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider<AppointmentProvider>(
                      create: (_) => AppointmentProvider(),
                      child: const AppointmentsPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month_outlined),
            ),
            Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'البحث',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'الرئيسية',
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
