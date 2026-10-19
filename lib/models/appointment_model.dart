class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String? doctorSpeciality;
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final String date;
  final String time;
  final String? location;
  final String status;
  final dynamic createdAt;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    this.doctorSpeciality,
    required this.patientId,
    required this.patientName,
    this.patientPhone,
    required this.date,
    required this.time,
    this.location,
    this.status = 'pending',
    this.createdAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> data, String docId) {
    return AppointmentModel(
      id: docId,
      doctorId: data['doctorId']?.toString() ?? '',
      doctorName: data['doctorName']?.toString() ?? '',
      doctorSpeciality: data['doctorSpeciality']?.toString(),
      patientId: data['patientId']?.toString() ?? '',
      patientName: data['patientName']?.toString() ?? '',
      patientPhone: data['patientPhone']?.toString(),
      date: data['date']?.toString() ?? '',
      time: data['time']?.toString() ?? '',
      location: data['location']?.toString(),
      status: data['status']?.toString() ?? 'pending',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpeciality': doctorSpeciality,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'date': date,
      'time': time,
      'location': location,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
