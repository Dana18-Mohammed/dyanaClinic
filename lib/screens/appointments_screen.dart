// screens/appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../models/patient.dart';
import '../providers/appointment_provider.dart';
import '../providers/patient_provider.dart';
import '../widgets/appointment_form.dart';
import '../widgets/appointment_shimmer.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  String _filterValue = 'all'; // Default filter
  DateTime? _selectedDay;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    // Set loading to true when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentLoadingProvider.notifier).state = true;
      // Load appointments after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        ref.read(appointmentProvider.notifier).loadAppointmentsWithLoading(ref);
      });
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(appointmentProvider);
    final patients = ref.watch(patientProvider);
    final isLoading = ref.watch(appointmentLoadingProvider);
    final currentLocale = ref.watch(localeProvider);
    final localizations = AppLocalizations(currentLocale);
    final isArabic = currentLocale.languageCode == 'ar';

    final filteredAppointments = appointments.where((appointment) {
      final patient = patients.firstWhere((p) => p.id == appointment.patientId, orElse: () => Patient(id: '', name: '', age: 0, toothType: '', phone: ''));
      final patientName = patient.name.toLowerCase();
      final searchTerm = _searchQuery.toLowerCase();
      return patientName.contains(searchTerm);
    }).toList();

    // فلترة حسب الحالة
    String _filter = _filterValue;
    List<Appointment> filteredByStatus = filteredAppointments;
    if (_filter == 'upcoming') {
      filteredByStatus = filteredAppointments.where((a) => a.appointmentTime.isAfter(DateTime.now())).toList();
    } else if (_filter == 'past') {
      filteredByStatus = filteredAppointments.where((a) => a.appointmentTime.isBefore(DateTime.now())).toList();
    }

    // فلترة حسب التاريخ
    List<Appointment> filteredByDate = filteredByStatus;
    if (_selectedDay != null) {
      filteredByDate = filteredByStatus.where((a) =>
        a.appointmentTime.year == _selectedDay!.year &&
        a.appointmentTime.month == _selectedDay!.month &&
        a.appointmentTime.day == _selectedDay!.day
      ).toList();
    } else if (_selectedRange != null) {
      filteredByDate = filteredByStatus.where((a) =>
        a.appointmentTime.isAfter(_selectedRange!.start.subtract(const Duration(days: 1))) &&
        a.appointmentTime.isBefore(_selectedRange!.end.add(const Duration(days: 1)))
      ).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.get('appointments_management'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(appointmentProvider.notifier).loadAppointmentsWithLoading(ref),
            tooltip: localizations.get('refresh'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFe1bee7), Colors.white],
          ),
        ),
        child: isLoading
            ? const AppointmentShimmer()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: isArabic ? 'ابحث باسم المريض' : 'Search by patient name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Text(isArabic ? 'فلترة:' : 'Filter:'),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _filter,
                          items: [
                            DropdownMenuItem(value: 'all', child: Text(isArabic ? 'الكل' : 'All')),
                            DropdownMenuItem(value: 'upcoming', child: Text(isArabic ? 'القادمة فقط' : 'Upcoming Only')),
                            DropdownMenuItem(value: 'past', child: Text(isArabic ? 'المنتهية فقط' : 'Past Only')),
                          ],
                          onChanged: (val) {
                            setState(() { _filterValue = val ?? 'all'; });
                          },
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.today),
                          label: Text(isArabic ? 'يوم' : 'Day'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 8)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              locale: isArabic ? const Locale('ar') : const Locale('en'),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDay = picked;
                                _selectedRange = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text(isArabic ? 'فترة' : 'Range'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 8)),
                          onPressed: () async {
                            DateTime? start = DateTime.now();
                            DateTime? end = DateTime.now();
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setStateDialog) {
                                    return AlertDialog(
                                      title: Text(isArabic ? 'اختر الفترة' : 'Select Range'),
                                      content: SizedBox(
                                        width: 350,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(isArabic ? 'من' : 'From'),
                                                  CalendarDatePicker(
                                                    initialDate: start!,
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                    onDateChanged: (date) {
                                                      setStateDialog(() {
                                                        start = date;
                                                        if (end != null && end!.isBefore(start!)) {
                                                          end = start;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(isArabic ? 'إلى' : 'To'),
                                                  CalendarDatePicker(
                                                    initialDate: end!,
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                    onDateChanged: (date) {
                                                      setStateDialog(() {
                                                        end = date;
                                                        if (start != null && end!.isBefore(start!)) {
                                                          start = end;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (start != null && end != null) {
                                              setState(() {
                                                _selectedRange = DateTimeRange(start: start!, end: end!);
                                                _selectedDay = null;
                                              });
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Text(isArabic ? 'تأكيد' : 'Confirm'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        if (_selectedDay != null || _selectedRange != null)
                          TextButton.icon(
                            icon: const Icon(Icons.clear),
                            label: Text(isArabic ? 'إزالة الفلترة' : 'Clear'),
                            onPressed: () {
                              setState(() {
                                _selectedDay = null;
                                _selectedRange = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filteredByDate.isEmpty
                        ? Center(
                            child: Text(
                              isArabic ? 'لا يوجد مواعيد' : 'No appointments',
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredByDate.length,
                            itemBuilder: (context, index) {
                              final appointment = filteredByDate[index];
                              final patient = patients.firstWhere((p) => p.id == appointment.patientId, orElse: () => Patient(id: '', name: 'Unknown', age: 0, toothType: '', phone: ''));
                              final isPast = appointment.appointmentTime.isBefore(DateTime.now());
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                color: Colors.grey[100],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // صورة رمزية صغيرة
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Color(0xFF8e24aa),
                                        child: Text(
                                          patient.name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // اسم المريض والتاريخ
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              patient.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time, size: 15, color: Colors.blueGrey[700]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${appointment.appointmentTime.day.toString().padLeft(2, '0')}-'
                                                  '${appointment.appointmentTime.month.toString().padLeft(2, '0')}-'
                                                  '${appointment.appointmentTime.year}  '
                                                  '${appointment.appointmentTime.hour.toString().padLeft(2, '0')}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // شارة الحالة
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPast ? Colors.green[400] : Colors.orange[400],
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          isPast ? (isArabic ? 'منتهي' : 'Past') : (isArabic ? 'قادم' : 'Upcoming'),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // زر تعديل صغير (للتاريخ فقط)
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                        onPressed: () async {
                                          final updated = await showDialog<Appointment>(
                                            context: context,
                                            builder: (_) => _EditAppointmentDialog(
                                              appointment: appointment,
                                            ),
                                          );
                                          if (updated != null) {
                                            await ref.read(appointmentProvider.notifier).updateAppointment(updated);
                                          }
                                        },
                                        tooltip: isArabic ? 'تعديل' : 'Edit',
                                      ),
                                      // زر حذف صغير
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => ref.read(appointmentProvider.notifier).deleteAppointment(appointment.id),
                                        tooltip: localizations.get('delete'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => AppointmentForm(
              patients: patients,
              onSave: (newAppointment) async {
                try {
                  print('Screen: Starting to add appointment for patient: ${newAppointment.patientId}');
                  await ref.read(appointmentProvider.notifier).addAppointment(newAppointment);
                  print('Screen: Appointment added successfully');
                } catch (e) {
                  print('Screen: Error adding appointment: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding appointment: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(localizations.get('add_appointment')),
      ),
    );
  }
}

// عدّل Dialog التعديل ليحتوي فقط على اختيار التاريخ والوقت بدون حقل الكشفية
class _EditAppointmentDialog extends StatefulWidget {
  final Appointment appointment;
  const _EditAppointmentDialog({Key? key, required this.appointment}) : super(key: key);

  @override
  State<_EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<_EditAppointmentDialog> {
  late DateTime _dateTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dateTime = widget.appointment.appointmentTime;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return AlertDialog(
      title: Text(isArabic ? 'تعديل الموعد' : 'Edit Appointment'),
      content: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(isArabic ? 'التاريخ والوقت' : 'Date & Time'),
        subtitle: Text('${_dateTime.day.toString().padLeft(2, '0')}-'
            '${_dateTime.month.toString().padLeft(2, '0')}-'
            '${_dateTime.year}  '
            '${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}'),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _dateTime,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            locale: isArabic ? const Locale('ar') : const Locale('en'),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(_dateTime),
            );
            if (time != null) {
              setState(() {
                _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
              });
            }
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isArabic ? 'إلغاء' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  final updated = Appointment(
                    id: widget.appointment.id,
                    patientId: widget.appointment.patientId,
                    appointmentTime: _dateTime,
                    examinationPrice: widget.appointment.examinationPrice,
                  );
                  Navigator.pop(context, updated);
                },
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isArabic ? 'حفظ' : 'Save'),
        ),
      ],
    );
  }
} 