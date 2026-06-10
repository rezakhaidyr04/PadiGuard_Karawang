import '../../core/utils/firebase_mocks.dart';

/// User Entity Model
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final String role; // 'farmer', 'penyuluh', 'admin'
  final String district;
  final String? subDistrict;
  final String? village;
  final List<String> fieldIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profilePhotoUrl,
    this.role = 'farmer',
    this.district = 'Karawang',
    this.subDistrict,
    this.village,
    this.fieldIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      role: json['role'] as String? ?? 'farmer',
      district: json['district'] as String? ?? 'Karawang',
      subDistrict: json['subDistrict'] as String?,
      village: json['village'] as String?,
      fieldIds: List<String>.from(json['fieldIds'] as List? ?? []),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': profilePhotoUrl,
      'role': role,
      'district': district,
      'subDistrict': subDistrict,
      'village': village,
      'fieldIds': fieldIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isVerified': isVerified,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePhotoUrl,
    String? role,
    String? district,
    String? subDistrict,
    String? village,
    List<String>? fieldIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      role: role ?? this.role,
      district: district ?? this.district,
      subDistrict: subDistrict ?? this.subDistrict,
      village: village ?? this.village,
      fieldIds: fieldIds ?? this.fieldIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
