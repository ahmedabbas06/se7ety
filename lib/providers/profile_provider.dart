import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> updatePatientProfile({
    required String uid,
    required String name,
    required String phone,
    required String bio,
    required AuthProvider authProvider,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await firestore.collection("users").doc(uid).update({
        "name": name,
        "phone": phone,
        "bio": bio,
      });

      await authProvider.getUserData();

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = "تعذر تحديث بيانات الملف الشخصي.";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
