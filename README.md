# Dental Clinic Desktop App (Flutter)

A simple desktop app for dental clinic management (patients & appointments) using Flutter and Supabase.

## Features
- Patient management (add, edit, delete, list)
- Appointment scheduling
- Supabase/PostgreSQL backend
- Riverpod state management
- RTL (Arabic) and responsive UI

## Supabase Setup
1. [Create a Supabase project](https://supabase.com/).
2. Create tables:

### Patients Table
```sql
create table patients (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  age int not null,
  tooth_type text not null,
  phone text not null
);
```

### Appointments Table
```sql
create table appointments (
  id uuid primary key default uuid_generate_v4(),
  patient_id uuid references patients(id) on delete cascade,
  appointment_time timestamptz not null
);
```

3. Get your Supabase URL and anon/public API key from Project Settings > API.

## Flutter Setup
- Install Flutter (Windows/macOS/Linux)
- Enable desktop: `flutter config --enable-windows-desktop --enable-macos-desktop --enable-linux-desktop`
- Run `flutter pub get`
- Set your Supabase URL and API key in `main.dart` (see comments)
- Run: `flutter run -d windows` (or `-d macos`/`-d linux`)

## Sample Data
Insert via Supabase SQL editor:
```sql
insert into patients (name, age, tooth_type, phone) values
('Ali Hassan', 30, 'Molar', '0551234567'),
('Sara Ahmed', 25, 'Incisor', '0559876543');
```

## Notes
- Desktop only (no mobile/web)
- All code is commented for clarity
