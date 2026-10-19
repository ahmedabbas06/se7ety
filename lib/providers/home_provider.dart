
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class HomeProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  List<UserModel> doctors = [];
  List<UserModel> filteredDoctors = [];

  String? selectedSpeciality;
  String searchQuery = '';

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<String> get specialities {
    final Set<String> availableSpecialities = {};

    for (final doctor in doctors) {
      final speciality = doctor.speciality?.trim();

      if (speciality != null && speciality.isNotEmpty) {
        availableSpecialities.add(speciality);
      }
    }

    final result = availableSpecialities.toList();
    result.sort();
    return result;
  }

  List<UserModel> get topDoctors {
    final result = List<UserModel>.from(filteredDoctors);

    result.sort((first, second) {
      final firstRating = first.rating ?? 0.0;
      final secondRating = second.rating ?? 0.0;

      return secondRating.compareTo(firstRating);
    });

    return result;
  }

  Future<void> getDoctors() async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      doctors = querySnapshot.docs.map((doc) {
        final doctorData = Map<String, dynamic>.from(doc.data());

        if (doctorData['uid'] == null ||
            doctorData['uid'].toString().isEmpty) {
          doctorData['uid'] = doc.id;
        }

        return UserModel.fromMap(doctorData);
      }).toList();

      filterDoctors();
    } catch (e) {
      errorMessage =
      'تعذر تحميل قائمة الأطباء. يرجى التأكد من الاتصال بالإنترنت.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectSpeciality(String? speciality) {
    if (selectedSpeciality == speciality) {
      selectedSpeciality = null;
    } else {
      selectedSpeciality = speciality;
    }

    filterDoctors();
    notifyListeners();
  }

  void searchDoctors(String query) {
    searchQuery = query;
    filterDoctors();
    notifyListeners();
  }

  void filterDoctors() {
    filteredDoctors = doctors.where((doctor) {
      bool matchesSpeciality = true;

      if (selectedSpeciality != null &&
          selectedSpeciality!.isNotEmpty) {
        matchesSpeciality = doctor.speciality?.trim() == selectedSpeciality;
      }

      bool matchesSearch = true;

      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();

        final nameMatches = doctor.name.toLowerCase().contains(query);
        final specialityMatches =
            doctor.speciality?.toLowerCase().contains(query) ?? false;

        matchesSearch = nameMatches || specialityMatches;
      }

      return matchesSpeciality && matchesSearch;
    }).toList();
  }

  void clearFilters() {
    selectedSpeciality = null;
    searchQuery = '';
    filterDoctors();
    notifyListeners();
  }
}
