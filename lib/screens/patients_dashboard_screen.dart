// screens/patients_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_provider.dart';
import '../providers/appointment_provider.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import 'package:intl/intl.dart';

const Color kPurple = Color(0xFF8e24aa);
const Color kPurpleLight = Color(0xFFe1bee7);
const Color kPurpleDark = Color(0xFF5e35b1);

class PatientsDashboardScreen extends ConsumerWidget {
  const PatientsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(patientProvider);
    final appointments = ref.watch(appointmentProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final int patientsCount = patients.length;
    final int todayAppointments = appointments.where((a) =>
      a.appointmentTime.year == today.year &&
      a.appointmentTime.month == today.month &&
      a.appointmentTime.day == today.day
    ).length;
    final int doneAppointments = patients.where((p) => p.isPaid).length;
    final int pendingAppointments = patients.where((p) => !p.isPaid).length;
    final double monthlyIncome = patients
      .where((p) => p.isPaid && p.examinationPrice != null && _isInCurrentMonth(p, now))
      .fold(0.0, (sum, p) => sum + (p.examinationPrice ?? 0));
    final List<String> months = List.generate(6, (i) {
      final date = DateTime(now.year, now.month - 5 + i);
      return DateFormat('MMM', 'ar').format(date);
    });
    final List<int> monthlyPatients = List.generate(6, (i) {
      final date = DateTime(now.year, now.month - 5 + i);
      return patients.where((p) => p.createdAt != null && p.createdAt!.year == date.year && p.createdAt!.month == date.month).length;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5e35b1)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('لوحة إحصائيات المرضى', style: TextStyle(color: Color(0xFF5e35b1), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kPurpleLight, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: kPurple,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.dashboard, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Text('لوحة إحصائيات المرضى',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: kPurpleDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      _StatCard(title: 'عدد المرضى', value: patientsCount.toString(), icon: Icons.people, color: kPurple),
                      _StatCard(title: 'مواعيد اليوم', value: todayAppointments.toString(), icon: Icons.event_available, color: kPurpleDark),
                      _StatCard(title: 'المنجزة', value: doneAppointments.toString(), icon: Icons.check_circle, color: Colors.green),
                      _StatCard(title: 'المؤجلة', value: pendingAppointments.toString(), icon: Icons.schedule, color: Colors.orange),
                      _StatCard(title: 'الدخل الشهري', value: '₪${monthlyIncome.toStringAsFixed(2)}', icon: Icons.attach_money, color: kPurple),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: kPurple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.bar_chart, color: kPurpleDark, size: 22),
                      ),
                      const SizedBox(width: 8),
                      Text('تطور عدد المرضى خلال الشهور',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: kPurpleDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPurpleLight.withOpacity(0.5), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: kPurpleLight.withOpacity(0.3), blurRadius: 16, offset: Offset(0, 6))],
                    ),
                    child: _SimpleBarChart(months: months, values: monthlyPatients),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isInCurrentMonth(Patient p, DateTime now) {
    return true; // مؤقتًا
  }
  bool _isInMonth(Patient p, DateTime date) {
    return true; // مؤقتًا
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  const _StatCard({required this.title, required this.value, required this.icon, this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: kPurpleLight.withOpacity(0.25), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color?.withOpacity(0.13) ?? kPurpleLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color ?? kPurple),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kPurpleDark)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<String> months;
  final List<int> values;
  const _SimpleBarChart({required this.months, required this.values, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final max = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(months.length, (i) {
          final height = max > 0 ? (values[i] / max) * 120.0 : 0.0;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: height.toDouble(),
                  width: 22,
                  decoration: BoxDecoration(
                    color: kPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                Text(months[i], style: TextStyle(fontSize: 13, color: kPurpleDark)),
                Text(values[i].toString(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          );
        }),
      ),
    );
  }
} 