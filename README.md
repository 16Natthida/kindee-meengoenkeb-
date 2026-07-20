# กินดี มีเงินเก็บ 🍽️💰

แอปจัดการเงินและวางแผนมื้ออาหารสำหรับคนที่อยาก **กินดี ใช้เงินเป็น และมีเงินเก็บ**

กินดี มีเงินเก็บ ช่วยบันทึกรายรับ–รายจ่าย วางแผนงบประมาณ จัดการวัตถุดิบและเมนูอาหาร รวมถึงแนะนำเมนูด้วย AI โดยออกแบบให้ใช้งานง่ายในแอปเดียว

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.22%2B-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.3%2B-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase" alt="Supabase">
  <img src="https://img.shields.io/badge/Status-In%20development-orange" alt="Status">
</p>

## ✨ ฟีเจอร์หลัก

| หมวดหมู่ | รายละเอียด |
| --- | --- |
| 🔐 บัญชีผู้ใช้ | สมัครสมาชิก เข้าสู่ระบบ แก้ไขโปรไฟล์ และรีเซ็ตรหัสผ่าน |
| 📊 Dashboard | ดูภาพรวมรายรับ รายจ่าย งบประมาณ และสถานะการใช้เงิน |
| 💸 รายรับ–รายจ่าย | บันทึก แก้ไข ค้นหา กรองรายการ และรองรับรายจ่ายประจำ |
| 🧾 งบประมาณ | แบ่งเงินรายเดือน กำหนดหมวดหมู่ และติดตามวงเงิน |
| 🥕 วัตถุดิบ | จัดการคลังวัตถุดิบ วันหมดอายุ และรายการซื้อ |
| 🍳 แผนอาหาร | วางแผนเมนูตามวัน พร้อมเชื่อมโยงวัตถุดิบ |
| 🤖 AI แนะนำเมนู | แนะนำเมนูจากวัตถุดิบ งบประมาณ และข้อจำกัดด้านอาหาร |
| 📈 รายงาน | ดูประวัติ กราฟ และสรุปพฤติกรรมการใช้เงิน |
| 🔔 การแจ้งเตือน | แจ้งเตือนรายการสำคัญและวัตถุดิบใกล้หมดอายุ |

## 🛠️ เทคโนโลยีที่ใช้

- Flutter + Dart
- Riverpod สำหรับจัดการ State
- GoRouter สำหรับจัดการเส้นทาง
- Supabase สำหรับ Authentication, Database และ Storage
- Supabase Edge Functions สำหรับการเชื่อมต่อ AI

## 🚀 เริ่มต้นใช้งาน

### 1. เตรียมเครื่องมือ

- Flutter SDK 3.22 ขึ้นไป (Dart 3.3 ขึ้นไป)
- Android Studio หรือ VS Code พร้อม Flutter extension
- บัญชี [Supabase](https://supabase.com)
- Supabase CLI สำหรับ Deploy Edge Function

ตรวจสอบสภาพแวดล้อมด้วย:

```bash
flutter doctor
```

### 2. ติดตั้งโปรเจกต์

```bash
git clone https://github.com/16Natthida/kindee-meengoenkeb-.git
cd kindee-meengoenkeb-
flutter pub get
```

### 3. ตั้งค่า Supabase

รัน SQL ตามลำดับใน Supabase SQL Editor:

1. `supabase/migrations/001_initial_schema.sql`
2. `supabase/migrations/002_rls_policies.sql`
3. `supabase/migrations/003_recurring_expenses.sql`
4. `supabase/seed/seed_meal_templates.sql`

จากนั้นคัดลอกไฟล์ตัวอย่างและใส่ค่า Supabase:

```bash
cp .env.example .env
```

```env
SUPABASE_URL=ใส่_Project_URL_ที่นี่
SUPABASE_ANON_KEY=ใส่_anon_public_key_ที่นี่
```

> ⚠️ ห้ามใส่ `ANTHROPIC_API_KEY` ในไฟล์ `.env` ของแอป เพราะค่า API Key จะถูกฝังอยู่ใน APK ได้ ให้เก็บไว้ใน Supabase Edge Function Secrets เท่านั้น

### 4. รันแอป

```bash
flutter run
```

### 5. สร้างไฟล์ APK

```bash
flutter build apk --release
```

## 🤖 ตั้งค่า AI แนะนำเมนู (ไม่บังคับ)

หากต้องการใช้ Claude ผ่าน Supabase Edge Function:

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase secrets set ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxx
supabase functions deploy suggest-meal
```

หากยังไม่ได้ตั้งค่า AI แอปจะใช้ระบบ Fallback ภายในแอปเพื่อแนะนำเมนูแทน และยังใช้งานฟีเจอร์อื่นได้ตามปกติ

## 📁 โครงสร้างโปรเจกต์

```text
lib/
├── app/                 # App shell, theme และ routing
├── core/                # Constants, services และ shared widgets
└── features/            # ฟีเจอร์หลักของแอป
    ├── auth/
    ├── budget/
    ├── dashboard/
    ├── expenses/
    ├── ingredients/
    ├── meals/
    ├── notifications/
    ├── reports/
    ├── settings/
    └── shopping/

supabase/
├── functions/           # Edge Functions
├── migrations/          # Database schema และ RLS
└── seed/                # ข้อมูลเริ่มต้น
```

## ✅ สถานะฟีเจอร์

- [x] Authentication และ Dashboard
- [x] ระบบงบประมาณและรายรับ–รายจ่าย
- [x] วัตถุดิบ แผนอาหาร และรายการซื้อ
- [x] ประวัติ รายงาน กราฟ และการแจ้งเตือน
- [x] หน้าตั้งค่าและระบบ Theme
- [x] AI แนะนำเมนูพร้อมระบบ Fallback

## 🧪 บัญชีทดสอบ

สมัครบัญชีใหม่ผ่านหน้า Register หรือใช้บัญชีทดสอบ:

```text
Email: tester1@example.com
Password: Test1234
```

## 📄 หมายเหตุด้านความปลอดภัย

- ห้าม Commit ไฟล์ `.env`
- ห้ามใส่ API Key ลับไว้ในโค้ด Flutter
- ตรวจสอบ Row Level Security (RLS) ก่อนใช้งานจริง

## 👩‍💻 ผู้พัฒนา

พัฒนาโดย [16Natthida](https://github.com/16Natthida)
