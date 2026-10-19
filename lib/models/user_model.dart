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

    if (data['rating'] is num) {
      parsedRating = (data['rating'] as num).toDouble();
    } else if (data['role'] == 'doctor') {
      parsedRating = 0.0;
    }

    return UserModel(
      uid: data['uid']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? '',
      createdAt: data['createdAt'],
      speciality: data['speciality']?.toString(),
      bio: data['bio']?.toString(),
      address: data['address']?.toString(),
      startHour: data['startHour']?.toString(),
      endHour: data['endHour']?.toString(),
      phone1: data['phone1']?.toString(),
      phone2: data['phone2']?.toString(),
      image: data['image']?.toString(),
      rating: parsedRating,
      phone: data['phone']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      if (createdAt != null) 'createdAt': createdAt,
      if (speciality != null) 'speciality': speciality,
      if (bio != null) 'bio': bio,
      if (address != null) 'address': address,
      if (startHour != null) 'startHour': startHour,
      if (endHour != null) 'endHour': endHour,
      if (phone1 != null) 'phone1': phone1,
      if (phone2 != null) 'phone2': phone2,
      if (image != null) 'image': image,
      if (rating != null) 'rating': rating,
      if (phone != null) 'phone': phone,
    };
  }
}
