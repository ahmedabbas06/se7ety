import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class HomeProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  List<UserModel> doctors = [];
  List<UserModel> filteredDoctors = [];

  String? selectedSpeciality;
  String searchQuery = "";

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> getDoctors() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await firestore
          .collection("users")
          .where("role", isEqualTo: "doctor")
          .get();

      doctors = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      filterDoctors();
    } catch (e) {
      errorMessage =
          "تعذر تحميل قائمة الأطباء. يرجى التأكد من الاتصال بالإنترنت.";
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
      if (selectedSpeciality != null && selectedSpeciality!.isNotEmpty) {
        matchesSpeciality =
            doctor.speciality != null &&
            doctor.speciality!.toLowerCase().contains(
              selectedSpeciality!.toLowerCase(),
            );
      }

      bool matchesSearch = true;
      if (searchQuery.isNotEmpty) {
        final queryLower = searchQuery.toLowerCase().trim();
        final nameMatches = doctor.name.toLowerCase().contains(queryLower);
        final specialityMatches =
            doctor.speciality != null &&
            doctor.speciality!.toLowerCase().contains(queryLower);
        matchesSearch = nameMatches || specialityMatches;
      }

      return matchesSpeciality && matchesSearch;
    }).toList();
  }

  void clearFilters() {
    selectedSpeciality = null;
    searchQuery = "";
    filterDoctors();
    notifyListeners();
  }
}
