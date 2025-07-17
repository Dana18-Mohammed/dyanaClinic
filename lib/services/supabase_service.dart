// services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient.dart';
import '../models/appointment.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Patient CRUD
  Future<List<Patient>> fetchPatients() async {
    try {
      final response = await client.from('patients').select().order('name');
      return (response as List).map((e) => Patient.fromMap(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPatient(Patient patient) async {
    try {
      final dataToInsert = patient.toMap();
      // Remove id for new patients to let database auto-generate it
      if (patient.id.isEmpty) {
        dataToInsert.remove('id');
      }
      print('Adding patient: $dataToInsert');
      final result = await client.from('patients').insert(dataToInsert).select();
      print('Add result: $result');
    } catch (e) {
      print('Error adding patient: $e');
      rethrow;
    }
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      print('Updating patient with ID: ${patient.id}');
      final dataToUpdate = patient.toMap();
      print('Patient data to update: $dataToUpdate');
      
      // Remove id from data to update since we're using it in the where clause
      dataToUpdate.remove('id');
      
      final result = await client.from('patients').update(dataToUpdate).eq('id', patient.id);
      print('Update result: $result');
    } catch (e) {
      print('Error updating patient: $e');
      rethrow;
    }
  }

  Future<void> deletePatient(String id) async {
    await client.from('patients').delete().eq('id', id);
  }

  // Appointment CRUD
  Future<List<Appointment>> fetchAppointments() async {
    try {
      final response = await client.from('appointments').select().order('appointment_time');
      print('Fetched appointments: $response');
      return (response as List).map((e) => Appointment.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching appointments: $e');
      rethrow;
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    try {
      final dataToInsert = appointment.toMap();
      // Remove id for new appointments to let database auto-generate it
      if (appointment.id.isEmpty) {
        dataToInsert.remove('id');
      }
      print('Adding appointment: $dataToInsert');
      final result = await client.from('appointments').insert(dataToInsert).select();
      print('Add appointment result: $result');
    } catch (e) {
      print('Error adding appointment: $e');
      rethrow;
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    try {
      final dataToUpdate = appointment.toMap();
      if (dataToUpdate.containsKey('id')) {
        dataToUpdate.remove('id');
      }
      await client.from('appointments').update(dataToUpdate).eq('id', appointment.id);
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  Future<void> deleteAppointment(String id) async {
    await client.from('appointments').delete().eq('id', id);
  }

  Future<List<Appointment>> fetchAppointmentsForPatient(String patientId) async {
    try {
      final response = await client
          .from('appointments')
          .select()
          .eq('patient_id', patientId)
          .order('appointment_time', ascending: true);
      return (response as List).map((e) => Appointment.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching appointments for patient: $e');
      rethrow;
    }
  }
} 