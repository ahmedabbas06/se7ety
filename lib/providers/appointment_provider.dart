import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/appointment_model.dart';

class AppointmentProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  List<AppointmentModel> patientAppointments = [];
  List<AppointmentModel> doctorAppointments = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> bookAppointment({
    required String doctorId,
    required String doctorName,
    String? doctorSpeciality,
    required String patientId,
    required String patientName,
    String? patientPhone,
    required String date,
    required String time,
    String? location,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final sanitizedTime = time.replaceAll(RegExp(r'\s+'), '_');
      final docId = "${doctorId}_${date}_$sanitizedTime";

      final docRef = firestore.collection("appointments").doc(docId);

      final appointment = AppointmentModel(
        id: docId,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpeciality: doctorSpeciality,
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        date: date,
        time: time,
        location: location ?? "العيادة",
        status: "pending",
        createdAt: FieldValue.serverTimestamp(),
      );

      await firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (docSnapshot.exists) {
          final existingData = docSnapshot.data();
          if (existingData != null && existingData["status"] != "cancelled") {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'already-exists',
              message:
                  "هذا الموعد محجوز بالفعل عند الطبيب. يرجى اختيار موعد آخر.",
            );
          }
        }

        transaction.set(docRef, appointment.toMap());
      });

      await getPatientAppointments(patientId);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is FirebaseException &&
          e.code == 'already-exists' &&
          e.message != null) {
        errorMessage = e.message;
      } else {
        errorMessage = "تعذر حجز الموعد. يرجى التأكد من الاتصال بالإنترنت والمحاولة مجدداً.";
      }
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getPatientAppointments(String patientId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await firestore
          .collection("appointments")
          .where("patientId", isEqualTo: patientId)
          .get();

      patientAppointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      errorMessage = "تعذر تحميل المواعيد الخاصة بك.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getDoctorAppointments(String doctorId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await firestore
          .collection("appointments")
          .where("doctorId", isEqualTo: doctorId)
          .get();

      doctorAppointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      errorMessage = "تعذر تحميل المواعيد الخاصة بك.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String newStatus,
    required String doctorId,
  }) async {
    try {
      await firestore.collection("appointments").doc(appointmentId).update({
        "status": newStatus,
      });

      await getDoctorAppointments(doctorId);
    } catch (e) {
      errorMessage = "تعذر تحديث حالة الموعد.";
      notifyListeners();
    }
  }

  Future<void> cancelAppointment({
    required String appointmentId,
    required String patientId,
  }) async {
    try {
      await firestore.collection("appointments").doc(appointmentId).update({
        "status": "cancelled",
      });

      await getPatientAppointments(patientId);
    } catch (e) {
      errorMessage = "تعذر إلغاء الموعد.";
      notifyListeners();
    }
  }
}
