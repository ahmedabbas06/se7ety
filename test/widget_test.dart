import 'package:flutter_test/flutter_test.dart';
import 'package:se7ety/models/appointment_model.dart';
import 'package:se7ety/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel.fromMap converts data correctly for doctor', () {
      final data = {
        'uid': 'doc123',
        'name': 'د. خالد علي',
        'email': 'khaled@example.com',
        'role': 'doctor',
        'speciality': 'دكتور قلب',
        'rating': 4.5,
        'phone1': '0122222222',
        'address': 'مدينة نصر',
      };

      final user = UserModel.fromMap(data);

      expect(user.uid, 'doc123');
      expect(user.name, 'د. خالد علي');
      expect(user.email, 'khaled@example.com');
      expect(user.role, 'doctor');
      expect(user.speciality, 'دكتور قلب');
      expect(user.rating, 4.5);
      expect(user.phone1, '0122222222');
      expect(user.address, 'مدينة نصر');
    });

    test('UserModel.fromMap handles int rating correctly', () {
      final data = {
        'uid': 'doc456',
        'name': 'د. علي أحمد',
        'email': 'ali@example.com',
        'role': 'doctor',
        'rating': 4,
      };

      final user = UserModel.fromMap(data);
      expect(user.rating, 4.0);
    });

    test('UserModel.toMap exports non-null fields accurately', () {
      final user = UserModel(
        uid: 'pat123',
        name: 'سيد عبد العزيز',
        email: 'sayed@example.com',
        role: 'patient',
        phone: '01012345678',
        bio: 'مريض سكري',
      );

      final map = user.toMap();

      expect(map['uid'], 'pat123');
      expect(map['name'], 'سيد عبد العزيز');
      expect(map['email'], 'sayed@example.com');
      expect(map['role'], 'patient');
      expect(map['phone'], '01012345678');
      expect(map['bio'], 'مريض سكري');
      expect(map.containsKey('speciality'), isFalse);
    });
  });

  group('AppointmentModel Tests', () {
    test('AppointmentModel.fromMap creates instance with defaults', () {
      final data = {
        'doctorId': 'doc123',
        'doctorName': 'د. خالد علي',
        'doctorSpeciality': 'دكتور قلب',
        'patientId': 'pat123',
        'patientName': 'سيد عبد العزيز',
        'patientPhone': '01012345678',
        'date': '2026-04-20',
        'time': '10:00 ص',
        'location': 'العيادة',
      };

      final appointment = AppointmentModel.fromMap(
        data,
        'doc123_2026-04-20_10:00_ص',
      );

      expect(appointment.id, 'doc123_2026-04-20_10:00_ص');
      expect(appointment.doctorId, 'doc123');
      expect(appointment.patientId, 'pat123');
      expect(appointment.date, '2026-04-20');
      expect(appointment.time, '10:00 ص');
      expect(appointment.status, 'pending');
    });

    test('AppointmentModel.toMap serializes status and IDs', () {
      final appointment = AppointmentModel(
        id: 'apt1',
        doctorId: 'doc123',
        doctorName: 'د. خالد علي',
        patientId: 'pat123',
        patientName: 'سيد عبد العزيز',
        date: '2026-04-20',
        time: '14:00',
        status: 'accepted',
      );

      final map = appointment.toMap();

      expect(map['id'], 'apt1');
      expect(map['doctorId'], 'doc123');
      expect(map['patientId'], 'pat123');
      expect(map['status'], 'accepted');
      expect(map['date'], '2026-04-20');
      expect(map['time'], '14:00');
    });
  });
}
