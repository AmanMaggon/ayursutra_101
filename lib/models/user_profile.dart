class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String role;
  final bool isActive;
  final String? abhaId;
  final String? abhaAddress;
  final String languagePreference;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    required this.role,
    required this.isActive,
    this.abhaId,
    this.abhaAddress,
    required this.languagePreference,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// This factory constructor now safely handles potential null values from the JSON data.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // FIX: Added checks for required fields to prevent crashes if data is missing.
    if (map['id'] == null || map['email'] == null || map['created_at'] == null) {
      throw const FormatException('Required field (id, email, or created_at) is missing in UserProfile data');
    }

    return UserProfile(
      id: map['id'],
      email: map['email'],
      fullName: map['full_name'] ?? '',
      phoneNumber: map['phone_number'],
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.tryParse(map['date_of_birth'])
          : null,
      gender: map['gender'],
      role: map['role'] ?? 'patient',
      isActive: map['is_active'] ?? true,
      abhaId: map['abha_id'],
      abhaAddress: map['abha_address'],
      languagePreference: map['language_preference'] ?? 'en',
      profileImageUrl: map['profile_image_url'],
      createdAt: DateTime.parse(map['created_at']),
      // Use tryParse for updatedAt as it might be null on creation.
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.parse(map['created_at']),
    );
  }

  /// Converts the UserProfile object to a Map for saving to the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
      'role': role,
      'is_active': isActive,
      'abha_id': abhaId,
      'abha_address': abhaAddress,
      'language_preference': languagePreference,
      'profile_image_url': profileImageUrl,
    };
  }

  /// Creates a copy of the UserProfile with updated fields.
  UserProfile copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? role,
    bool? isActive,
    String? abhaId,
    String? abhaAddress,
    String? languagePreference,
    String? profileImageUrl,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      abhaId: abhaId ?? this.abhaId,
      abhaAddress: abhaAddress ?? this.abhaAddress,
      languagePreference: languagePreference ?? this.languagePreference,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      // FIX: This now correctly copies the existing updatedAt value instead of creating a new one.
      updatedAt: updatedAt,
    );
  }
}