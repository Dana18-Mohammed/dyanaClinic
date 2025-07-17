# 🦷 Dental Clinic Desktop App (Flutter)

تطبيق مكتبي بسيط لإدارة عيادة الأسنان، تم تطويره باستخدام **Flutter** و**Supabase**. يتيح إدارة المرضى والمواعيد بواجهة عربية تفاعلية ومتجاوبة.

---

## 🛠️ مميزات التطبيق

| الوظيفة              | الوصف |
|----------------------|-------|
| 👨‍⚕️ إدارة المرضى       | إضافة / تعديل / حذف / عرض قائمة المرضى |
| 📅 جدولة المواعيد       | إضافة مواعيد وربطها بالمرضى تلقائيًا |
| 🗄️ قاعدة بيانات Supabase | تخزين البيانات باستخدام PostgreSQL |
| 🔄 Riverpod            | لإدارة الحالة بشكل مرن ومنظم |
| 🌐 دعم RTL             | واجهة كاملة باللغة العربية ومتجاوبة |

---

## 🖼️ صور من التطبيق

| الصفحة الرئيسية | قائمة المرضى |
|----------------|---------------|
| <img width="1364" height="695" alt="home" src="https://github.com/user-attachments/assets/b0964afd-d493-44b3-8e6c-5daf4f112ab3" /> | <img width="1337" height="736" alt="patients" src="https://github.com/user-attachments/assets/a76b1e8b-0ed6-4fb9-9424-b9ac190651a0" /> |

| جدولة المواعيد - 1 | جدولة المواعيد - 2 |
|-------------------|--------------------|
| <img width="1356" height="654" alt="appointment 1" src="https://github.com/user-attachments/assets/feb826f8-a7cf-473a-9da3-4709088a68f3" /> | <img width="1356" height="654" alt="appointment 2" src="https://github.com/user-attachments/assets/1185d4be-60bf-420d-bb6a-fef483cf0382" /> |

---

## 🔧 إعداد Supabase

1. [أنشئ مشروعًا على Supabase](https://supabase.com).
2. أنشئ الجداول التالية:

### جدول المرضى
```sql
create table patients (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  age int not null,
  tooth_type text not null,
  phone text not null
);
