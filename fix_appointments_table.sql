-- إصلاح جدول المواعيد في Supabase
-- انسخ هذا الكود والصقه في SQL Editor في Supabase Dashboard

-- 1. تحقق من نوع البيانات في جدول المرضى
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'patients' AND column_name = 'id';

-- 2. احذف الجدول الحالي إذا كان موجوداً
DROP TABLE IF EXISTS appointments CASCADE;

-- 3. أعد إنشاء الجدول بالشكل الصحيح (يتوافق مع نوع بيانات المرضى)
CREATE TABLE appointments (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  patient_id bigint REFERENCES patients(id) ON DELETE CASCADE,
  appointment_time timestamptz NOT NULL,
  created_at timestamptz DEFAULT NOW()
);

-- 4. أضف فهارس لتحسين الأداء
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_time ON appointments(appointment_time);

-- 5. تحقق من إنشاء الجدول
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'appointments'
ORDER BY ordinal_position;

-- 6. أضف بيانات تجريبية (اختياري)
-- INSERT INTO appointments (patient_id, appointment_time) 
-- SELECT id, NOW() + INTERVAL '1 day' FROM patients LIMIT 1; 