// models/appointment.dart
class Appointment {
  final String id;
  final String patientId;
  final DateTime appointmentTime;
  final double? examinationPrice;

  Appointment({required this.id, required this.patientId, required this.appointmentTime, this.examinationPrice});

  factory Appointment.fromMap(Map<String, dynamic> map) => Appointment(
    id: map['id']?.toString() ?? '',
    patientId: map['patient_id']?.toString() ?? '',
    appointmentTime: DateTime.parse(map['appointment_time'] ?? DateTime.now().toIso8601String()),
    examinationPrice: map['examination_price'] != null ? double.tryParse(map['examination_price'].toString()) : null,
  );

  Map<String, dynamic> toMap() => {
    if (id.isNotEmpty) 'id': id, // Only include id if it's not empty
    'patient_id': patientId,
    'appointment_time': appointmentTime.toIso8601String(),
    if (examinationPrice != null) 'examination_price': examinationPrice,
  };
} 