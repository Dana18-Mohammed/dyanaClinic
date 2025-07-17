// models/patient.dart
class Patient {
  final String id;
  final String name;
  final int age;
  final String toothType;
  final String phone;
  final double? examinationPrice;
  final bool isPaid;
  final DateTime? createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.toothType,
    required this.phone,
    this.examinationPrice,
    this.isPaid = false,
    this.createdAt,
  });

  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
    id: map['id']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    age: map['age'] is int ? map['age'] : int.tryParse(map['age']?.toString() ?? '0') ?? 0,
    toothType: map['tooth_type']?.toString() ?? '',
    phone: map['phone']?.toString() ?? '',
    examinationPrice: map['examination_price'] != null ? double.tryParse(map['examination_price'].toString()) : null,
    isPaid: map['is_paid'] == true || map['is_paid'] == 1,
    createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id, // Always include id for updates
    'name': name,
    'age': age,
    'tooth_type': toothType,
    'phone': phone,
    if (examinationPrice != null) 'examination_price': examinationPrice,
    'is_paid': isPaid,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? toothType,
    String? phone,
    double? examinationPrice,
    bool? isPaid,
    DateTime? createdAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      toothType: toothType ?? this.toothType,
      phone: phone ?? this.phone,
      examinationPrice: examinationPrice ?? this.examinationPrice,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 