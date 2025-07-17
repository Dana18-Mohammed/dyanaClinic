// providers/appointment_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../services/supabase_service.dart';

final appointmentLoadingProvider = StateProvider<bool>((ref) => true);

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, List<Appointment>>((ref) {
  final notifier = AppointmentNotifier();
  notifier.loadAppointments(); // Load appointments when provider is created
  return notifier;
});

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  final _service = SupabaseService();

  AppointmentNotifier() : super([]);

  Future<void> loadAppointments() async {
    try {
      final appointments = await _service.fetchAppointments();
      print('Loaded ${appointments.length} appointments');
      state = appointments;
    } catch (e) {
      print('Error loading appointments: $e');
      state = [];
    }
  }

  Future<void> loadAppointmentsWithLoading(WidgetRef ref) async {
    ref.read(appointmentLoadingProvider.notifier).state = true;
    try {
      final appointments = await _service.fetchAppointments();
      print('Loaded ${appointments.length} appointments');
      state = appointments;
    } catch (e) {
      print('Error loading appointments: $e');
      state = [];
    } finally {
      ref.read(appointmentLoadingProvider.notifier).state = false;
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    try {
      print('Provider: Adding appointment for patient: ${appointment.patientId}');
      await _service.addAppointment(appointment);
      print('Provider: Appointment added successfully, reloading appointments');
      await loadAppointments();
      print('Provider: Appointments reloaded successfully');
    } catch (e) {
      print('Error in appointment provider: $e');
      rethrow;
    }
  }

  Future<void> deleteAppointment(String id) async {
    await _service.deleteAppointment(id);
    await loadAppointments();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _service.updateAppointment(appointment);
      // حدث القائمة محلياً
      state = [
        for (final a in state)
          if (a.id == appointment.id) appointment else a
      ];
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }
} 