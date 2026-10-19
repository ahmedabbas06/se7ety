import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/appointment_model.dart';

class AppointmentProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  List<AppointmentModel> patientAppointments = [];
  List<AppointmentModel> doctorAppointments = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
      final docId = '${doctorId}_${date}_$sanitizedTime';
      final docRef = firestore.collection('appointments').doc(docId);

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
        location: location ?? 'العيادة',
        status: 'pending',
        createdAt: FieldValue.serverTimestamp(),
      );

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (snapshot.exists) {
          final data = snapshot.data();

          if (data != null && data['status'] != 'cancelled') {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'already-exists',
              message: 'هذا الموعد محجوز بالفعل. يرجى اختيار موعد آخر.',
            );
          }
        }

        transaction.set(docRef, appointment.toMap());
      });

      await _loadPatientAppointments(patientId);
      return true;
    } catch (e) {
      if (e is FirebaseException && e.code == 'already-exists') {
        errorMessage = e.message ?? 'هذا الموعد محجوز بالفعل.';
      } else {
        errorMessage = 'تعذر حجز الموعد. حاول مرة أخرى.';
      }

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPatientAppointments(String patientId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _loadPatientAppointments(patientId);
    } catch (e) {
      errorMessage = 'تعذر تحميل المواعيد الخاصة بك.';
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
      await _loadDoctorAppointments(doctorId);
    } catch (e) {
      errorMessage = 'تعذر تحميل حجوزات المرضى.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPatientAppointments(String patientId) async {
    final snapshot = await firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get();

    patientAppointments = snapshot.docs
        .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
        .toList();

    _sortAppointments(patientAppointments);
  }

  Future<void> _loadDoctorAppointments(String doctorId) async {
    final snapshot = await firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    doctorAppointments = snapshot.docs
        .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
        .toList();

    _sortAppointments(doctorAppointments);
  }

  DateTime _parseAppointmentDateTime(AppointmentModel appointment) {
    try {
      final dateParts = appointment.date.split('-');
      if (dateParts.length != 3) {
        return DateTime(2000);
      }

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      int hour = 0;
      int minute = 0;

      String timeStr = appointment.time.trim().toLowerCase();

      bool isPm = timeStr.contains('م') ||
          timeStr.contains('pm') ||
          timeStr.contains('مساءً') ||
          timeStr.contains('مساء');

      bool isAm = timeStr.contains('ص') ||
          timeStr.contains('am') ||
          timeStr.contains('صباحًا') ||
          timeStr.contains('صباح');

      final digitsMatch = RegExp(r'(\d{1,2})(?::(\d{1,2}))?').firstMatch(timeStr);

      if (digitsMatch != null) {
        hour = int.parse(digitsMatch.group(1)!);
        minute = int.parse(digitsMatch.group(2) ?? '0');

        if (isPm && hour < 12) {
          hour += 12;
        } else if (isAm && hour == 12) {
          hour = 0;
        }
      }

      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return DateTime(2000);
    }
  }

  void _sortAppointments(List<AppointmentModel> appointments) {
    appointments.sort((first, second) {
      final firstDt = _parseAppointmentDateTime(first);
      final secondDt = _parseAppointmentDateTime(second);

      return firstDt.compareTo(secondDt);
    });
  }

  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String newStatus,
    required String doctorId,
  }) async {
    errorMessage = null;

    if (![
      'accepted',
      'confirmed',
      'cancelled',
      'completed',
    ].contains(newStatus)) {
      errorMessage = 'حالة الحجز غير صحيحة.';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final docRef = firestore.collection('appointments').doc(appointmentId);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('الحجز غير موجود.');
        }

        final data = snapshot.data();

        if (data == null || data['doctorId'] != doctorId) {
          throw Exception('ليس لديك صلاحية تعديل هذا الحجز.');
        }

        final currentStatus = data['status'] ?? 'pending';

        final canAccept = newStatus == 'accepted' || newStatus == 'confirmed';

        if (canAccept && currentStatus != 'pending') {
          throw Exception('لا يمكن قبول هذا الحجز في حالته الحالية.');
        }

        if (newStatus == 'cancelled' &&
            currentStatus != 'pending' &&
            currentStatus != 'accepted' &&
            currentStatus != 'confirmed') {
          throw Exception('لا يمكن إلغاء هذا الحجز في حالته الحالية.');
        }

        if (newStatus == 'completed' &&
            currentStatus != 'accepted' &&
            currentStatus != 'confirmed') {
          throw Exception('لا يمكن إكمال حجز غير مؤكد.');
        }

        transaction.update(docRef, {'status': newStatus});
      });

      await _loadDoctorAppointments(doctorId);
    } catch (e) {
      errorMessage = e is FirebaseException
          ? 'تعذر تحديث الحجز. تحقق من الاتصال والصلاحيات.'
          : e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelAppointment({
    required String appointmentId,
    required String patientId,
  }) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final docRef = firestore.collection('appointments').doc(appointmentId);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('الحجز غير موجود.');
        }

        final data = snapshot.data();

        if (data == null || data['patientId'] != patientId) {
          throw Exception('ليس لديك صلاحية إلغاء هذا الحجز.');
        }

        if (data['status'] != 'pending') {
          throw Exception('يمكن إلغاء الحجوزات التي لم يتم تأكيدها فقط.');
        }

        transaction.update(docRef, {'status': 'cancelled'});
      });

      await _loadPatientAppointments(patientId);
    } catch (e) {
      errorMessage = e is FirebaseException
          ? 'تعذر إلغاء الحجز. تحقق من الاتصال والصلاحيات.'
          : e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Set<String>> getBookedTimesForDate({
    required String doctorId,
    required String date,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isEqualTo: date)
          .get();

      final bookedTimes = <String>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final status = data['status']?.toString() ?? 'pending';
        final time = data['time']?.toString();

        if (status != 'cancelled' && time != null && time.isNotEmpty) {
          bookedTimes.add(time);
        }
      }

      return bookedTimes;
    } catch (e) {
      throw Exception(
        'تعذر تحميل المواعيد المتاحة. تحقق من الاتصال وحاول مرة أخرى.',
      );
    }
  }
}
