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
    this.status = "pending",
    this.createdAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> data, String docId) {
    return AppointmentModel(
      id: docId,
      doctorId: data["doctorId"] ?? "",
      doctorName: data["doctorName"] ?? "",
      doctorSpeciality: data["doctorSpeciality"],
      patientId: data["patientId"] ?? "",
      patientName: data["patientName"] ?? "",
      patientPhone: data["patientPhone"],
      date: data["date"] ?? "",
      time: data["time"] ?? "",
      location: data["location"],
      status: data["status"] ?? "pending",
      createdAt: data["createdAt"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "doctorId": doctorId,
      "doctorName": doctorName,
      if (doctorSpeciality != null) "doctorSpeciality": doctorSpeciality,
      "patientId": patientId,
      "patientName": patientName,
      if (patientPhone != null) "patientPhone": patientPhone,
      "date": date,
      "time": time,
      if (location != null) "location": location,
      "status": status,
      if (createdAt != null) "createdAt": createdAt,
    };
  }
}
