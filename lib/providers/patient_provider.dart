// providers/patient_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient.dart';
import '../services/supabase_service.dart';

final patientLoadingProvider = StateProvider<bool>((ref) => true);

final patientProvider = StateNotifierProvider<PatientNotifier, List<Patient>>((ref) {
  final notifier = PatientNotifier();
  notifier.loadPatients(); // Load patients when provider is created
  return notifier;
});

class PatientNotifier extends StateNotifier<List<Patient>> {
  final _service = SupabaseService();

  PatientNotifier() : super([]);

  Future<void> loadPatients() async {
    try {
      final patients = await _service.fetchPatients();
      print('Loaded ${patients.length} patients');
      state = patients;
    } catch (e) {
      print('Error loading patients: $e');
      state = []; // Set empty list on error
    }
  }

  void setLoading(bool loading) {
    // This will be called from the UI to set loading state
  }

  Future<void> loadPatientsWithLoading(WidgetRef ref) async {
    ref.read(patientLoadingProvider.notifier).state = true;
    try {
      final patients = await _service.fetchPatients();
      print('Loaded ${patients.length} patients');
      state = patients;
    } catch (e) {
      print('Error loading patients: $e');
      state = []; // Set empty list on error
    } finally {
      ref.read(patientLoadingProvider.notifier).state = false;
    }
  }

  Future<void> addPatient(Patient patient) async {
    try {
      await _service.addPatient(patient);
      await loadPatients();
    } catch (e) {
      print('Error in provider: $e');
      rethrow;
    }
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      print('Provider: Updating patient ${patient.name} with ID: ${patient.id}');
      await _service.updatePatient(patient);
      print('Provider: Patient updated successfully, reloading patients');
      await loadPatients();
      print('Provider: Patients reloaded successfully');
    } catch (e) {
      print('Error in provider updatePatient: $e');
      // Don't rethrow, just log the error
      print('Provider: Update failed, but continuing...');
    }
  }

  Future<void> deletePatient(String id) async {
    await _service.deletePatient(id);
    await loadPatients();
  }
} 