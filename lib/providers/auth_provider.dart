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
    notifyListeners();

    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentUser = userCredential.user;
      await getUserData();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();

    currentUser = null;
    userData = null;
    errorMessage = null;
    notifyListeners();
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
    notifyListeners();

    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentUser = userCredential.user;

      if (currentUser != null) {
        try {
          await firestore.collection("users").doc(currentUser!.uid).set({
            "uid": currentUser!.uid,
            "name": name,
            "email": email,
            "role": role,
            "createdAt": FieldValue.serverTimestamp(),
            if (role == "doctor") "speciality": speciality,
            if (role == "doctor") "rating": 0.0,
          });

          await getUserData();
        } catch (firestoreError) {
          try {
            await currentUser?.delete();
          } catch (_) {}
          currentUser = null;
          userData = null;
          errorMessage =
              "حدث خطأ أثناء حفظ بيانات الحساب. يرجى المحاولة مرة أخرى.";
        }
      }
    } catch (e) {
      errorMessage = e.toString();
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
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUserData() async {
    if (currentUser == null) {
      userData = null;
      return;
    }

    try {
      final doc = await firestore
          .collection("users")
          .doc(currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        userData = UserModel.fromMap(doc.data()!);
      } else {
        userData = null;
        errorMessage = "لم يتم العثور على بيانات المستخدم في قاعدة البيانات.";
      }
    } catch (e) {
      userData = null;
      errorMessage =
          "تعذر تحميل بيانات المستخدم. يرجى التأكد من الاتصال بالإنترنت.";
    }

    notifyListeners();
  }
}
