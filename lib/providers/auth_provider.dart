import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  User? currentUser;
  UserModel? userData;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    userData = null;
    currentUser = null;
    notifyListeners();

    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentUser = userCredential.user;

      if (currentUser == null) {
        errorMessage = 'تعذر تسجيل الدخول. يرجى المحاولة مرة أخرى.';
        return;
      }

      await getUserData();

      if (userData == null && errorMessage == null) {
        errorMessage = 'تعذر تحميل بيانات الحساب.';
      }
    } on FirebaseAuthException catch (e) {
      currentUser = null;
      userData = null;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صحيح.';
          break;
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
          break;
        case 'user-disabled':
          errorMessage = 'هذا الحساب تم تعطيله.';
          break;
        case 'too-many-requests':
          errorMessage = 'محاولات كثيرة. يرجى المحاولة لاحقًا.';
          break;
        case 'network-request-failed':
          errorMessage = 'تحقق من اتصال الإنترنت وحاول مرة أخرى.';
          break;
        default:
          errorMessage = 'تعذر تسجيل الدخول. يرجى المحاولة مرة أخرى.';
      }
    } catch (e) {
      currentUser = null;
      userData = null;
      errorMessage = 'حدث خطأ أثناء تسجيل الدخول.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await firebaseAuth.signOut();

      currentUser = null;
      userData = null;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'تعذر تسجيل الخروج. يرجى المحاولة مرة أخرى.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String role,
    String? speciality,
  ) async {
    isLoading = true;
    errorMessage = null;
    userData = null;
    currentUser = null;
    notifyListeners();

    try {
      if (role != 'doctor' && role != 'patient') {
        errorMessage = 'نوع الحساب غير صحيح.';
        return;
      }

      if (role == 'doctor' &&
          (speciality == null || speciality.trim().isEmpty)) {
        errorMessage = 'يرجى إدخال تخصص الطبيب.';
        return;
      }

      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      currentUser = userCredential.user;

      if (currentUser == null) {
        errorMessage = 'تعذر إنشاء الحساب. يرجى المحاولة مرة أخرى.';
        return;
      }

      try {
        await firestore.collection('users').doc(currentUser!.uid).set({
          'uid': currentUser!.uid,
          'name': name.trim(),
          'email': email.trim(),
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          if (role == 'doctor') 'speciality': speciality!.trim(),
          if (role == 'doctor') 'rating': 0.0,
        });

        await getUserData();

        if (userData == null) {
          throw Exception('تعذر تحميل بيانات الحساب بعد التسجيل.');
        }
      } catch (e) {
        try {
          await currentUser?.delete();
        } catch (deleteError) {
          try {
            await firebaseAuth.signOut();
          } catch (signOutError) {
            // سيتم إظهار رسالة الخطأ بالأسفل.
          }
        }

        currentUser = null;
        userData = null;
        errorMessage =
            'حدث خطأ أثناء حفظ بيانات الحساب. يرجى المحاولة مرة أخرى.';
      }
    } on FirebaseAuthException catch (e) {
      currentUser = null;
      userData = null;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'البريد الإلكتروني مستخدم بالفعل.';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صحيح.';
          break;
        case 'weak-password':
          errorMessage = 'كلمة المرور ضعيفة. يرجى اختيار كلمة مرور أقوى.';
          break;
        case 'network-request-failed':
          errorMessage = 'تحقق من اتصال الإنترنت وحاول مرة أخرى.';
          break;
        default:
          errorMessage = 'تعذر إنشاء الحساب. يرجى المحاولة مرة أخرى.';
      }
    } catch (e) {
      currentUser = null;
      userData = null;
      errorMessage = 'حدث خطأ أثناء إنشاء الحساب.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkCurrentUser() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = firebaseAuth.currentUser;

      if (currentUser != null) {
        await getUserData();
      } else {
        userData = null;
      }
    } catch (e) {
      userData = null;
      errorMessage = 'تعذر التحقق من بيانات الحساب.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUserData() async {
    if (currentUser == null) {
      userData = null;
      errorMessage = 'لا يوجد مستخدم مسجل الدخول.';
      return;
    }

    try {
      final doc = await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        userData = UserModel.fromMap(doc.data()!);
        errorMessage = null;
      } else {
        userData = null;
        errorMessage = 'لم يتم العثور على بيانات المستخدم في قاعدة البيانات.';
      }
    } on FirebaseException catch (e) {
      userData = null;

      if (e.code == 'permission-denied') {
        errorMessage = 'ليس لديك صلاحية الوصول إلى بيانات الحساب.';
      } else {
        errorMessage =
            'تعذر تحميل بيانات المستخدم. يرجى التأكد من الاتصال بالإنترنت.';
      }
    } catch (e) {
      userData = null;
      errorMessage = 'حدث خطأ أثناء تحميل بيانات المستخدم.';
    }

    notifyListeners();
  }
}
