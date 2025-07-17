// screens/patients_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../widgets/patient_form.dart';
import '../widgets/patient_shimmer.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import '../providers/appointment_provider.dart';
import 'patient_details_screen.dart';
import 'patients_dashboard_screen.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set loading to true when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patientLoadingProvider.notifier).state = true;
      // Load patients after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        ref.read(patientProvider.notifier).loadPatientsWithLoading(ref);
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
    final patients = ref.watch(patientProvider);
    final isLoading = ref.watch(patientLoadingProvider);
    final currentLocale = ref.watch(localeProvider);
    final localizations = AppLocalizations(currentLocale);
    final isArabic = currentLocale.languageCode == 'ar';
    final filteredPatients = _searchQuery.isEmpty
        ? patients
        : patients.where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.phone.contains(_searchQuery)
          ).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.get('patients')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(patientProvider.notifier).loadPatientsWithLoading(ref),
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
            ? const PatientShimmer()
            : filteredPatients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.get('no_patients'),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.get('add_your_first_patient'),
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: isArabic ? 'ابحث باسم المريض أو رقم الهاتف' : 'Search by name or phone',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = filteredPatients[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () async {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PatientDetailsScreen(
                                        patient: patient,
                                        appointment: null,
                                        consultationFee: patient.examinationPrice ?? 0,
                                        isPaid: patient.isPaid,
                                        initialDoctorNote: '',
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Color(0xFF8e24aa),
                                        child: Text(
                                          patient.name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              patient.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.cake, size: 18, color: Colors.blueGrey),
                                                const SizedBox(width: 4),
                                                Text('${patient.age}', style: const TextStyle(fontSize: 14)),
                                                const SizedBox(width: 12),
                                                const Icon(Icons.medical_services, size: 18, color: Colors.blueGrey),
                                                const SizedBox(width: 4),
                                                Text(patient.toothType, style: const TextStyle(fontSize: 14)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.phone, size: 18, color: Colors.blueGrey),
                                                const SizedBox(width: 4),
                                                Text(patient.phone, style: const TextStyle(fontSize: 14)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Color(0xFF1976D2)),
                                            onPressed: () async {
                                              await showDialog(
                                                context: context,
                                                builder: (_) => PatientForm(
                                                  patient: patient,
                                                  onSave: (updated) async {
                                                    try {
                                                      await ref.read(patientProvider.notifier).updatePatient(updated);
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('${localizations.get('error_updating_patient')}: $e'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              );
                                            },
                                            tooltip: localizations.get('edit'),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => ref.read(patientProvider.notifier).deletePatient(patient.id),
                                            tooltip: localizations.get('delete'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
        onPressed: () => showDialog(
          context: context,
          builder: (_) => PatientForm(
            onSave: (newPatient) => ref.read(patientProvider.notifier).addPatient(newPatient),
          ),
        ),
        icon: const Icon(Icons.add),
        label: Text(localizations.get('add_patient')),
      ),
    );
  }
} 