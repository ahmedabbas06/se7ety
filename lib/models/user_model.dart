class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final dynamic createdAt;

  final String? speciality;
  final String? bio;
  final String? address;
  final String? startHour;
  final String? endHour;
  final String? phone1;
  final String? phone2;
  final String? image;
  final double? rating;

  final String? phone;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
    this.speciality,
    this.bio,
    this.address,
    this.startHour,
    this.endHour,
    this.phone1,
    this.phone2,
    this.image,
    this.rating,
    this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    double? parsedRating;
    if (data["rating"] != null) {
      if (data["rating"] is num) {
        parsedRating = (data["rating"] as num).toDouble();
      }
    } else if (data["role"] == "doctor") {
      parsedRating = 0.0;
    }

    return UserModel(
      uid: data["uid"] ?? "",
      name: data["name"] ?? "",
      email: data["email"] ?? "",
      role: data["role"] ?? "",
      createdAt: data["createdAt"],
      speciality: data["speciality"],
      bio: data["bio"],
      address: data["address"],
      startHour: data["startHour"],
      endHour: data["endHour"],
      phone1: data["phone1"],
      phone2: data["phone2"],
      image: data["image"],
      rating: parsedRating,
      phone: data["phone"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "role": role,
      if (createdAt != null) "createdAt": createdAt,
      if (speciality != null) "speciality": speciality,
      if (bio != null) "bio": bio,
      if (address != null) "address": address,
      if (startHour != null) "startHour": startHour,
      if (endHour != null) "endHour": endHour,
      if (phone1 != null) "phone1": phone1,
      if (phone2 != null) "phone2": phone2,
      if (image != null) "image": image,
      if (rating != null) "rating": rating,
      if (phone != null) "phone": phone,
    };
  }
}
