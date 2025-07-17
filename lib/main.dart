// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hlftoxhjiugosemctcut.supabase.co', // <-- Set your Supabase URL here
    anonKey:  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsZnRveGhqaXVnb3NlbWN0Y3V0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwNTI2NTIsImV4cCI6MjA2NzYyODY1Mn0.AZqztp-XaEd75a5rViFNecbZqqZTjg4NRT24cUT32zM'
  );
  runApp(const ProviderScope(child: DentalClinicApp()));
}
