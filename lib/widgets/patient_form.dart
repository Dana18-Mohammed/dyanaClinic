// widgets/patient_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient.dart';
import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';

class PatientForm extends ConsumerStatefulWidget {
  final Patient? patient;
  final void Function(Patient) onSave;
  final Key? formKey;
  const PatientForm({Key? key, this.patient, required this.onSave, this.formKey}) : super(key: key);

  @override
  ConsumerState<PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends ConsumerState<PatientForm> {
  late final GlobalKey<FormState> _formKey;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _toothTypeController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _formKey = (widget.formKey is GlobalKey<FormState>) ? widget.formKey as GlobalKey<FormState> : GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.patient?.name ?? '');
    _ageController = TextEditingController(text: widget.patient?.age.toString() ?? '');
    _toothTypeController = TextEditingController(text: widget.patient?.toothType ?? '');
    _phoneController = TextEditingController(text: widget.patient?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _toothTypeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentLocale = ref.watch(localeProvider);
        final localizations = AppLocalizations(currentLocale);
        
        final patient = Patient(
          id: widget.patient?.id ?? '', // Use existing ID for updates, empty for new patients
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          toothType: _toothTypeController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        print('Form: Creating/Updating patient: ${patient.toMap()}');
        print('Form: Patient ID: ${patient.id}');
        print('Form: Original patient ID: ${widget.patient?.id}');
        print('Form: Is editing: ${widget.patient != null}');
        print('Form: Original patient data: ${widget.patient?.toMap()}');
        
        widget.onSave(patient);
        
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.patient == null 
                ? localizations.get('patient_added_successfully') 
                : localizations.get('patient_updated_successfully')
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error creating/updating patient: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final localizations = AppLocalizations(currentLocale);
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.patient == null ? Icons.person_add : Icons.edit,
            color: const Color(0xFF1976D2),
          ),
          const SizedBox(width: 8),
          Text(
            widget.patient == null ? localizations.get('add_new_patient') : localizations.get('edit_patient'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: localizations.get('name')),
                validator: (v) => v == null || v.isEmpty ? localizations.get('enter_name') : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: localizations.get('age')),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return localizations.get('enter_age');
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return localizations.get('enter_valid_age');
                  return null;
                },
              ),
              TextFormField(
                controller: _toothTypeController,
                decoration: InputDecoration(labelText: localizations.get('tooth_type')),
                validator: (v) => v == null || v.isEmpty ? localizations.get('enter_tooth_type') : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: localizations.get('phone')),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return localizations.get('enter_phone');
                  // Allow phone numbers with 2-15 digits (more flexible)
                  final phoneReg = RegExp(r'^\d{2,15}$');
                  if (!phoneReg.hasMatch(v)) return localizations.get('enter_valid_phone');
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: Text(localizations.get('cancel'))
        ),
        ElevatedButton(
          onPressed: _submit, 
          child: Text(localizations.get('save'))
        ),
      ],
    );
  }
} 