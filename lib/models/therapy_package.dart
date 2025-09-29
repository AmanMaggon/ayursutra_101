class TherapyPackage {
  final String id;
  final String name;
  final String? description;
  final List<String> therapyTypes;
  final int durationDays;
  final int totalSessions;
  final double price;
  final List<String> contraindications;
  final Map<String, dynamic> eligibilityCriteria;
  final Map<String, dynamic> sopDocuments;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  TherapyPackage({
    required this.id,
    required this.name,
    this.description,
    required this.therapyTypes,
    required this.durationDays,
    required this.totalSessions,
    required this.price,
    required this.contraindications,
    required this.eligibilityCriteria,
    required this.sopDocuments,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TherapyPackage.fromJson(Map<String, dynamic> json) {
    return TherapyPackage(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      therapyTypes: List<String>.from(json['therapy_types'] ?? []),
      durationDays: json['duration_days'],
      totalSessions: json['total_sessions'],
      price: (json['price'] as num).toDouble(),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      eligibilityCriteria:
          Map<String, dynamic>.from(json['eligibility_criteria'] ?? {}),
      sopDocuments: Map<String, dynamic>.from(json['sop_documents'] ?? {}),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'therapy_types': therapyTypes,
      'duration_days': durationDays,
      'total_sessions': totalSessions,
      'price': price,
      'contraindications': contraindications,
      'eligibility_criteria': eligibilityCriteria,
      'sop_documents': sopDocuments,
      'is_active': isActive,
    };
  }

  // Helper getters
  String get formattedPrice {
    return '₹${price.toStringAsFixed(0)}';
  }

  String get durationText {
    if (durationDays == 1) {
      return '1 day';
    } else if (durationDays < 7) {
      return '$durationDays days';
    } else {
      final weeks = durationDays / 7;
      if (weeks == weeks.floor()) {
        return weeks == 1 ? '1 week' : '${weeks.toInt()} weeks';
      } else {
        return '$durationDays days';
      }
    }
  }

  String get sessionsText {
    return totalSessions == 1 ? '1 session' : '$totalSessions sessions';
  }

  List<String> get therapyDisplayNames {
    return therapyTypes.map((type) {
      switch (type) {
        case 'abhyanga':
          return 'Abhyanga';
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
          return type
              .split('_')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' ');
      }
    }).toList();
  }

  double get pricePerSession {
    return totalSessions > 0 ? price / totalSessions : price;
  }

  String get formattedPricePerSession {
    return '₹${pricePerSession.toStringAsFixed(0)}';
  }
}
