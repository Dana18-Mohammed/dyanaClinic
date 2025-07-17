// screens/patient_details_screen.dart
// screens/patient_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../services/supabase_service.dart';
import 'package:intl/intl.dart';
import '../widgets/patient_shimmer.dart';

class PatientDetailsScreen extends ConsumerStatefulWidget {
  final Patient patient;
  final Appointment? appointment;
  final double consultationFee;
  final bool isPaid;
  final String? initialDoctorNote;

  const PatientDetailsScreen({
    Key? key,
    required this.patient,
    this.appointment,
    required this.consultationFee,
    required this.isPaid,
    this.initialDoctorNote,
  }) : super(key: key);

  @override
  ConsumerState<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends ConsumerState<PatientDetailsScreen> {
  bool _editingNote = false;
  late TextEditingController _noteController;
  bool _saving = false;
  String? _saveError;
  bool _editingFee = false;
  bool _editingPayment = false;
  late TextEditingController _feeController;
  bool _editingExamPrice = false;
  late TextEditingController _examPriceController;
  bool _isPaidLocal = false;
  bool _loadingPatient = false;
  Patient? _latestPatient;
  List<Appointment> _appointments = [];
  bool _loadingAppointments = true;

  // إضافة متغيرات لتعديل بيانات المريض
  bool _editingPatientInfo = false;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _toothTypeController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialDoctorNote ?? '');
    _feeController = TextEditingController(text: widget.consultationFee.toString());
    _examPriceController = TextEditingController(text: widget.patient.examinationPrice?.toString() ?? '');
    _isPaidLocal = widget.patient.isPaid;
    _latestPatient = widget.patient;
    // Controllers for patient info
    _nameController = TextEditingController(text: widget.patient.name);
    _ageController = TextEditingController(text: widget.patient.age.toString());
    _toothTypeController = TextEditingController(text: widget.patient.toothType);
    _phoneController = TextEditingController(text: widget.patient.phone);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _feeController.dispose();
    _examPriceController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _toothTypeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      // مثال: حفظ الملاحظة في Supabase (تحتاج تعديل حسب جدولك)
      await SupabaseService.client
          .from('appointments')
          .update({'doctor_note': _noteController.text})
          .eq('id', widget.appointment?.id)
          .execute();
      setState(() {
        _editingNote = false;
      });
    } catch (e) {
      setState(() {
        _saveError = e.toString();
      });
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  Future<void> _saveFeeAndPayment() async {
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await SupabaseService.client
          .from('appointments')
          .update({
            'consultation_fee': double.tryParse(_feeController.text) ?? 0,
            'is_paid': _isPaidLocal
          })
          .eq('id', widget.appointment?.id)
          .execute();
      setState(() {
        _editingFee = false;
        _editingPayment = false;
      });
    } catch (e) {
      setState(() {
        _saveError = e.toString();
      });
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  Future<void> _saveExamPriceAndPayment() async {
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await SupabaseService.client
          .from('patients')
          .update({
            'examination_price': double.tryParse(_examPriceController.text) ?? 0,
            'is_paid': _isPaidLocal
          })
          .eq('id', widget.patient.id)
          .execute();
      setState(() {
        _editingExamPrice = false;
        _editingPayment = false;
      });
    } catch (e) {
      setState(() {
        _saveError = e.toString();
      });
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  Future<void> _refreshPatient() async {
    setState(() {
      _loadingPatient = true;
    });
    try {
      final response = await SupabaseService.client
          .from('patients')
          .select()
          .eq('id', widget.patient.id)
          .single();
      final patient = Patient.fromMap(response);
      setState(() {
        _latestPatient = patient;
        _examPriceController.text = patient.examinationPrice?.toString() ?? '';
        _isPaidLocal = patient.isPaid;
      });
    } catch (e) {
      // يمكن عرض رسالة خطأ إذا رغبت
    } finally {
      setState(() {
        _loadingPatient = false;
      });
    }
  }

  Future<void> _savePatientInfo() async {
    setState(() { _saving = true; _saveError = null; });
    try {
      await SupabaseService.client
          .from('patients')
          .update({
            'name': _nameController.text.trim(),
            'age': int.tryParse(_ageController.text.trim()) ?? 0,
            'tooth_type': _toothTypeController.text.trim(),
            'phone': _phoneController.text.trim(),
          })
          .eq('id', _latestPatient!.id)
          .execute();
      setState(() {
        _editingPatientInfo = false;
        _latestPatient = _latestPatient!.copyWith(
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text.trim()) ?? 0,
          toothType: _toothTypeController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      });
    } catch (e) {
      setState(() { _saveError = e.toString(); });
    } finally {
      setState(() { _saving = false; });
    }
  }

  // تعديل الكشفية وحالة الدفع
  bool _editingExamAndPayment = false;
  Future<void> _saveExamAndPayment() async {
    setState(() { _saving = true; _saveError = null; });
    try {
      await SupabaseService.client
          .from('patients')
          .update({
            'examination_price': double.tryParse(_examPriceController.text) ?? 0,
            'is_paid': _isPaidLocal
          })
          .eq('id', _latestPatient!.id)
          .execute();
      setState(() {
        _editingExamAndPayment = false;
        _latestPatient = _latestPatient!.copyWith(
          examinationPrice: double.tryParse(_examPriceController.text) ?? 0,
          isPaid: _isPaidLocal,
        );
      });
    } catch (e) {
      setState(() { _saveError = e.toString(); });
    } finally {
      setState(() { _saving = false; });
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() { _loadingAppointments = true; });
    try {
      final appointments = await SupabaseService().fetchAppointmentsForPatient(widget.patient.id);
      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      // يمكن عرض رسالة خطأ إذا رغبت
    } finally {
      setState(() { _loadingAppointments = false; });
    }
  }

  String formatAppointmentTime(DateTime date, bool isArabic) {
    final dateStr = DateFormat('dd-MM-yyyy', 'en').format(date);
    final timeStr = DateFormat('hh:mm a', 'en').format(date);
    return '$dateStr  $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final patient = _latestPatient ?? widget.patient;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تفاصيل المريض' : 'Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isArabic ? 'تحديث بيانات المريض' : 'Refresh Patient Data',
            onPressed: _loadingPatient ? null : _refreshPatient,
          ),
        ],
      ),
      body: _loadingPatient
          ? const PatientShimmer()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // صورة رمزية واسم المريض
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: theme.primaryColor.withOpacity(0.15),
                          child: Text(
                            patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 36,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          patient.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // بطاقة المعلومات الأساسية
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isArabic ? 'معلومات المريض' : 'Patient Info',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(_editingPatientInfo ? Icons.close : Icons.edit),
                                tooltip: isArabic ? 'تعديل' : 'Edit',
                                onPressed: () {
                                  setState(() {
                                    _editingPatientInfo = !_editingPatientInfo;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _editingPatientInfo
                              ? Column(
                                  children: [
                                    TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: isArabic ? 'اسم المريض' : 'Patient Name',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _ageController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: isArabic ? 'العمر' : 'Age',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _toothTypeController,
                                      decoration: InputDecoration(
                                        labelText: isArabic ? 'نوع السن' : 'Tooth Type',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        labelText: isArabic ? 'رقم الهاتف' : 'Phone',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      icon: _saving ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.save),
                                      label: Text(isArabic ? 'حفظ' : 'Save'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: _saving ? null : _savePatientInfo,
                                    ),
                                    if (_saveError != null) ...[
                                      const SizedBox(height: 8),
                                      Text(_saveError!, style: const TextStyle(color: Colors.red)),
                                    ]
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.cake, color: Colors.blueGrey),
                                        const SizedBox(width: 8),
                                        Text(isArabic ? 'العمر:' : 'Age:', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        const SizedBox(width: 8),
                                        Text(patient.age.toString(), style: const TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.medical_services, color: Colors.blueGrey),
                                        const SizedBox(width: 8),
                                        Text(isArabic ? 'نوع السن:' : 'Tooth Type:', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        const SizedBox(width: 8),
                                        Text(patient.toothType, style: const TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, color: Colors.blueGrey),
                                        const SizedBox(width: 8),
                                        Text(isArabic ? 'رقم الهاتف:' : 'Phone:', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        const SizedBox(width: 8),
                                        Text(patient.phone, style: const TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // بطاقة الكشفية وحالة الدفع
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isArabic ? 'الكشفية والدفع' : 'Examination & Payment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(_editingExamAndPayment ? Icons.close : Icons.edit),
                                tooltip: isArabic ? 'تعديل' : 'Edit',
                                onPressed: () {
                                  setState(() {
                                    _editingExamAndPayment = !_editingExamAndPayment;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _editingExamAndPayment
                              ? Column(
                                  children: [
                                    TextField(
                                      controller: _examPriceController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: isArabic ? 'سعر الكشفية' : 'Examination Price',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(isArabic ? 'حالة الدفع:' : 'Payment Status:', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        const SizedBox(width: 8),
                                        DropdownButton<bool>(
                                          value: _isPaidLocal,
                                          items: [
                                            DropdownMenuItem(
                                              value: true,
                                              child: Text(isArabic ? 'مدفوع' : 'Paid'),
                                            ),
                                            DropdownMenuItem(
                                              value: false,
                                              child: Text(isArabic ? 'غير مدفوع' : 'Not Paid'),
                                            ),
                                          ],
                                          onChanged: (val) {
                                            setState(() {
                                              _isPaidLocal = val ?? false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      icon: _saving ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.save),
                                      label: Text(isArabic ? 'حفظ' : 'Save'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: _saving ? null : _saveExamAndPayment,
                                    ),
                                    if (_saveError != null) ...[
                                      const SizedBox(height: 8),
                                      Text(_saveError!, style: const TextStyle(color: Colors.red)),
                                    ]
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.monetization_on, color: Colors.amber),
                                        const SizedBox(width: 8),
                                        Text(isArabic ? 'سعر الكشفية:' : 'Examination Price:', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        const SizedBox(width: 8),
                                        Text(
                                          patient.examinationPrice != null ? patient.examinationPrice.toString() : (isArabic ? 'غير محدد' : 'Not set'),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          patient.isPaid ? Icons.check_circle : Icons.cancel,
                                          color: patient.isPaid ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(isArabic ? 'حالة الدفع:' : 'Payment Status:', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        const SizedBox(width: 8),
                                        Text(
                                          patient.isPaid ? (isArabic ? 'مدفوع' : 'Paid') : (isArabic ? 'غير مدفوع' : 'Not Paid'),
                                          style: TextStyle(fontSize: 16, color: patient.isPaid ? Colors.green : Colors.red),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // بطاقة موعد الحجز
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'موعد الحجز' : 'Appointment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: theme.primaryColor,
                            ),
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                formatAppointmentTime(widget.appointment?.appointmentTime ?? DateTime.now(), isArabic),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // بطاقة ملاحظة الطبيب
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isArabic ? 'ملاحظة الطبيب' : "Doctor's Note",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.primaryColor),
                                ),
                              ),
                              IconButton(
                                icon: Icon(_editingNote ? Icons.close : Icons.edit),
                                tooltip: isArabic ? 'تعديل' : 'Edit',
                                onPressed: () {
                                  setState(() {
                                    _editingNote = !_editingNote;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _editingNote
                              ? Column(
                                  children: [
                                    TextField(
                                      controller: _noteController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: isArabic ? 'أدخل ملاحظة الطبيب...' : "Enter doctor's note...",
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          icon: _saving
                                              ? SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                )
                                              : Icon(Icons.save),
                                          label: Text(isArabic ? 'حفظ' : 'Save'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.primaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: _saving ? null : _saveNote,
                                        ),
                                        if (_saveError != null) ...[
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              _saveError!,
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ],
                                )
                              : Text(
                                  _noteController.text.isEmpty
                                      ? (isArabic ? 'لا توجد ملاحظة' : 'No note')
                                      : _noteController.text,
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // بطاقة كل مواعيد الحجز
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'كل مواعيد الحجز' : 'All Appointments',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: theme.primaryColor,
                            ),
                          ),
                          const Divider(height: 20),
                          _loadingAppointments
                              ? const Center(child: CircularProgressIndicator())
                              : _appointments.isEmpty
                                  ? Text(isArabic ? 'لا يوجد مواعيد' : 'No appointments')
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _appointments.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final appt = _appointments[index];
                                        final isPast = appt.appointmentTime.isBefore(DateTime.now());
                                        return Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          color: isPast ? Colors.green[50] : Colors.orange[50],
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: isPast ? Colors.green : Colors.orange,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: const EdgeInsets.all(8),
                                                  child: Icon(
                                                    isPast ? Icons.check_circle : Icons.schedule,
                                                    color: Colors.white,
                                                    size: 28,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        formatAppointmentTime(appt.appointmentTime, false),
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                      ),
                                                      if (appt.examinationPrice != null)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 4),
                                                          child: Text(
                                                            (isArabic ? 'سعر الكشفية: ' : 'Exam Price: ') + appt.examinationPrice.toString(),
                                                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                                                          ),
                                                        ),
                                                      // يمكن إضافة اسم الطبيب أو ملاحظة هنا إذا توفرت
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: isPast ? Colors.green : Colors.orange,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    isPast ? (isArabic ? 'منتهي' : 'Past') : (isArabic ? 'قادم' : 'Upcoming'),
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 