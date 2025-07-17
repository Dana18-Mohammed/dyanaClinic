// l10n/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'patients': 'Patients',
      'appointments': 'Appointments',
      'dental_clinic': 'عيادة Dyana Clinic',
      'add_patient': 'Add Patient',
      'add_new_patients': 'Add New Patients',
      'edit_patient': 'Edit Patient',
      'add_appointment': 'Add Appointment',
      'no_patients': 'No patients found.',
      'no_appointments': 'No appointments found.',
      'welcome': 'Welcome to Dyana Clinic',
      'professional_care': 'Professional Dental Care Management',
      'manage_patients': 'Manage Patients',
      'manage_appointments': 'Manage Appointments',
      'patients_management': 'Patients Management',
      'appointments_management': 'Appointments Management',
      'add_new_patient': 'Add New Patient',
      'schedule_appointment': 'Schedule New Appointment',
      'age': 'Age',
      'tooth_type': 'Tooth Type',
      'phone': 'Phone',
      'name': 'Name',
      'patient': 'Patient',
      'time': 'Time',
      'select_patient': 'Select Patient',
      'pick_date_time': 'Pick date and time',
      'no_date_chosen': 'No date/time chosen',
      'years': 'years',
      'refresh': 'Refresh',
      'edit': 'Edit',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'save': 'Save',
      'enter_name': 'Enter name',
      'enter_age': 'Enter age',
      'enter_valid_age': 'Enter valid age',
      'enter_tooth_type': 'Enter tooth type',
      'enter_phone': 'Enter phone number',
      'enter_valid_phone': 'Enter valid phone number (2-15 digits)',
      'add_your_first_patient': 'Add your first patient to get started',
      'schedule_your_first_appointment': 'Schedule your first appointment to get started',
      'patient_added_successfully': 'Patient added successfully!',
      'patient_updated_successfully': 'Patient updated successfully!',
      'error_updating_patient': 'Error updating patient',
      'no_appointments_found': 'No appointments found',
      'patient_colon': 'Patient',
      'time_colon': 'Time',
      'schedule_new_appointment': 'Schedule New Appointment',
      'no_date_time_chosen': 'No date/time chosen',
      'pick_date_and_time': 'Pick date and time',
    },
    'ar': {
      'patients': 'المرضى',
      'appointments': 'المواعيد',
      'dental_clinic': 'عيادة ديانا',
      'add_patient': 'إضافة مريض',
      'add_new_patients': 'إضافة مرضى جدد',
      'edit_patient': 'تعديل مريض',
      'add_appointment': 'إضافة موعد',
      'no_patients': 'لا يوجد مرضى.',
      'no_appointments': 'لا توجد مواعيد.',
      'welcome': 'مرحباً بك في عيادة ديانا',
      'professional_care': 'إدارة رعاية الأسنان الاحترافية',
      'manage_patients': 'إدارة المرضى',
      'manage_appointments': 'إدارة المواعيد',
      'patients_management': 'إدارة المرضى',
      'appointments_management': 'إدارة المواعيد',
      'add_new_patient': 'إضافة مريض جديد',
      'schedule_appointment': 'جدولة موعد جديد',
      'age': 'العمر',
      'tooth_type': 'نوع السن',
      'phone': 'الهاتف',
      'name': 'الاسم',
      'patient': 'المريض',
      'time': 'الوقت',
      'select_patient': 'اختر المريض',
      'pick_date_time': 'اختر التاريخ والوقت',
      'no_date_chosen': 'لم يتم اختيار تاريخ/وقت',
      'years': 'سنة',
      'refresh': 'تحديث',
      'edit': 'تعديل',
      'delete': 'حذف',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'enter_name': 'أدخل الاسم',
      'enter_age': 'أدخل العمر',
      'enter_valid_age': 'أدخل عمر صحيح',
      'enter_tooth_type': 'أدخل نوع السن',
      'enter_phone': 'أدخل رقم الهاتف',
      'enter_valid_phone': 'أدخل رقم هاتف صحيح (2-15 رقم)',
      'add_your_first_patient': 'أضف أول مريض للبدء',
      'schedule_your_first_appointment': 'جدول أول موعد للبدء',
      'patient_added_successfully': 'تم إضافة المريض بنجاح!',
      'patient_updated_successfully': 'تم تعديل المريض بنجاح!',
      'error_updating_patient': 'خطأ في تعديل المريض',
      'no_appointments_found': 'لا توجد مواعيد',
      'patient_colon': 'المريض',
      'time_colon': 'الوقت',
      'schedule_new_appointment': 'جدولة موعد جديد',
      'no_date_time_chosen': 'لم يتم اختيار تاريخ/وقت',
      'pick_date_and_time': 'اختر التاريخ والوقت',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 