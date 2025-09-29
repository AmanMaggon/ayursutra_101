class TherapySession {
  final String id;
  final String patientId;
  final String? doctorId;
  final String? therapistId;
  final String? packageId;
  final String? roomId;
  final String therapyType;
  final String therapyPhase;
  final int? sessionNumber;
  final DateTime scheduledDate;
  final String scheduledTime;
  final int durationMinutes;
  final String status;
  final Map<String, dynamic> sessionNotes;
  final Map<String, dynamic> vitalSigns;
  final bool contraindications;
  final Map<String, dynamic> complications;
  final String? progressNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final Map<String, dynamic>? packageData;
  final Map<String, dynamic>? doctorData;

  TherapySession({
    required this.id,
    required this.patientId,
    this.doctorId,
    this.therapistId,
    this.packageId,
    this.roomId,
    required this.therapyType,
    required this.therapyPhase,
    this.sessionNumber,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.status,
    required this.sessionNotes,
    required this.vitalSigns,
    required this.contraindications,
    required this.complications,
    this.progressNotes,
    required this.createdAt,
    required this.updatedAt,
    this.packageData,
    this.doctorData,
  });

  factory TherapySession.fromJson(Map<String, dynamic> json) {
    return TherapySession(
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      therapistId: json['therapist_id'],
      packageId: json['package_id'],
      roomId: json['room_id'],
      therapyType: json['therapy_type'],
      therapyPhase: json['therapy_phase'] ?? 'pradhana_karma',
      sessionNumber: json['session_number'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      scheduledTime: json['scheduled_time'],
      durationMinutes: json['duration_minutes'] ?? 90,
      status: json['status'],
      sessionNotes: Map<String, dynamic>.from(json['session_notes'] ?? {}),
      vitalSigns: Map<String, dynamic>.from(json['vital_signs'] ?? {}),
      contraindications: json['contraindications_checked'] ?? false,
      complications: Map<String, dynamic>.from(json['complications'] ?? {}),
      progressNotes: json['progress_notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      packageData: json['therapy_packages'],
      doctorData: json['user_profiles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'therapist_id': therapistId,
      'package_id': packageId,
      'room_id': roomId,
      'therapy_type': therapyType,
      'therapy_phase': therapyPhase,
      'session_number': sessionNumber,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'scheduled_time': scheduledTime,
      'duration_minutes': durationMinutes,
      'status': status,
      'session_notes': sessionNotes,
      'vital_signs': vitalSigns,
      'contraindications_checked': contraindications,
      'complications': complications,
      'progress_notes': progressNotes,
    };
  }

  // Helper getters
  String get therapyDisplayName {
    switch (therapyType) {
      case 'abhyanga':
        return 'Abhyanga Massage';
      case 'shirodhara':
        return 'Shirodhara';
      case 'pizhichil':
        return 'Pizhichil';
      case 'udvartana':
        return 'Udvartana';
      case 'basti':
        return 'Basti';
      case 'nasya':
        return 'Nasya';
      case 'vamana':
        return 'Vamana';
      case 'virechana':
        return 'Virechana';
      case 'raktamokshana':
        return 'Raktamokshana';
      default:
        return therapyType
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rescheduled':
        return 'Rescheduled';
      default:
        return status
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  String get doctorName => doctorData?['full_name'] ?? 'Dr. Unknown';
  String? get doctorImage => doctorData?['profile_image_url'];
  String get packageName => packageData?['name'] ?? 'Custom Session';
  String? get packageDescription => packageData?['description'];

  DateTime get scheduledDateTime {
    final timeParts = scheduledTime.split(':');
    return DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  bool get isUpcoming {
    return scheduledDateTime.isAfter(DateTime.now()) && status == 'scheduled';
  }
}
