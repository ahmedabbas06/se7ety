
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> updatePatientProfile({
    required String uid,
    required String name,
    required String phone,
    required String bio,
    required AuthProvider authProvider,
  }) async {
    if (authProvider.currentUser == null ||
        authProvider.currentUser!.uid != uid ||
        authProvider.userData?.role != 'patient') {
      errorMessage = 'لا يمكنك تعديل بيانات هذا الحساب.';
      notifyListeners();
      return false;
    }

    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    final trimmedBio = bio.trim();

    if (trimmedName.isEmpty) {
      errorMessage = 'الرجاء إدخال الاسم.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await firestore.collection('users').doc(uid).update({
        'name': trimmedName,
        'phone': trimmedPhone,
        'bio': trimmedBio,
      });

      await authProvider.getUserData();

      if (authProvider.userData == null) {
        errorMessage =
        'تم حفظ البيانات، لكن تعذر تحديث البيانات المعروضة. حاول إعادة تحميل الحساب.';
        return false;
      }

      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        errorMessage = 'ليس لديك صلاحية تعديل بيانات الحساب.';
      } else if (e.code == 'not-found') {
        errorMessage = 'بيانات الحساب غير موجودة في قاعدة البيانات.';
      } else {
        errorMessage = 'تعذر الاتصال بقاعدة البيانات. حاول مرة أخرى.';
      }

      return false;
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء تحديث بيانات الحساب.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
