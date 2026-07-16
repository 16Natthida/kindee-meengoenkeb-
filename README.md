# กินดี มีเงินเก็บ (kindee_meengoenkeb)

แอปแบ่งเงินเดือนอัตโนมัติ บันทึกรายจ่าย และวางแผนเมนูอาหารตามงบประมาณ
เขียนด้วย Flutter + Riverpod + GoRouter + Supabase

> **Part 1**: Architecture, Folder Structure, pubspec.yaml, SQL Migration + RLS, Theme, Router, Authentication, Dashboard
> **Part 2**: ระบบแบ่งเงินเดือน และระบบรายจ่ายฉบับเต็ม
> **Part 3**: ระบบวัตถุดิบ, ระบบวางแผนเมนูอาหาร, ระบบรายการซื้อของ
> **Part 4**: ประวัติและรายงาน + กราฟ และระบบการแจ้งเตือน
> **Part 5**: หน้าตั้งค่า (Theme/หน่วยเงิน/แจ้งเตือน) + GitHub Actions Keep-Alive
> **Part 6**: เชื่อม AI (Claude) แนะนำเมนูจริงผ่าน Supabase Edge Function แทนระบบสุ่ม พร้อม Fallback อัตโนมัติถ้า AI ใช้งานไม่ได้

---

## 1. ติดตั้งเครื่องมือ

- Flutter SDK >= 3.22 (Dart >= 3.3)
- Android Studio หรือ VS Code + Flutter extension
- บัญชี Supabase (ฟรี) ที่ https://supabase.com
- Supabase CLI (สำหรับ Deploy Edge Function ใน Part 6): https://supabase.com/docs/guides/cli

```bash
flutter doctor
```

## 2. ตั้งค่า Supabase

รัน SQL ตามลำดับใน **SQL Editor** (ไม่มีการเปลี่ยนแปลงจาก Part 1):
1. `supabase/migrations/001_initial_schema.sql`
2. `supabase/migrations/002_rls_policies.sql`
3. `supabase/seed/seed_meal_templates.sql`

คัดลอก `Project URL` และ `anon public key` จาก **Project Settings > API**

## 3. ตั้งค่า Storage

Bucket `receipts` และ `ingredient-images` ถูกสร้างจาก Migration แล้ว ไม่ต้องตั้งค่าเพิ่ม

## 4. ตั้งค่าไฟล์ .env

```bash
cp .env.example .env
```
แก้ไข `SUPABASE_URL` และ `SUPABASE_ANON_KEY`

**สำคัญ**: ห้ามใส่ `ANTHROPIC_API_KEY` ในไฟล์ `.env` นี้เด็ดขาด เพราะไฟล์นี้ถูกรวมเข้าไปในตัวแอป (APK) ถอดออกมาดูได้ — API Key ของ AI ต้องอยู่ใน Supabase Edge Function Secret เท่านั้น (ดูขั้นตอนข้อ 6)

## 5. ติดตั้ง Dependency

```bash
flutter pub get
```

## 6. Deploy Edge Function สำหรับ AI แนะนำเมนู (ใหม่ใน Part 6)

```bash
# ล็อกอิน Supabase CLI (ครั้งแรกเท่านั้น)
supabase login

# เชื่อมโปรเจกต์ (หา project-ref ได้จาก URL ใน Supabase Dashboard)
supabase link --project-ref YOUR_PROJECT_REF

# ตั้งค่า API Key ของ Claude เป็น Secret (ปลอดภัย ไม่เข้าไปอยู่ในแอป)
supabase secrets set ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxx

# (ไม่บังคับ) เลือกโมเดล ค่าเริ่มต้นคือ claude-sonnet-5
supabase secrets set ANTHROPIC_MODEL=claude-sonnet-5

# Deploy Edge Function
supabase functions deploy suggest-meal
```

ถ้ายังไม่ได้ Deploy หรือยังไม่ได้ตั้ง Secret ก็ไม่เป็นไร — แอปจะ **ใช้ระบบสุ่มเมนูจากฐานข้อมูลภายในแอปแทนโดยอัตโนมัติ** (ไม่มี Error โผล่ให้ผู้ใช้เห็น) ตามที่ออกแบบไว้ตั้งแต่ Part 1

## 7. รันบน Android Emulator

```bash
flutter run
```

## 8. Build APK

```bash
flutter build apk --release
```

## 9. บัญชีทดสอบ

สมัครด้วยอีเมลของคุณเองผ่านหน้า Register เช่น `tester1@example.com` / `Test1234`

### ทดสอบ Flow ของ Part 6

1. ตั้งค่าการกิน (จำนวนคน, งบต่อวัน, อุปกรณ์, อาหารที่แพ้) ที่เมนู "อื่น ๆ" > "ตั้งค่าการกิน"
2. เพิ่มวัตถุดิบสัก 2-3 อย่างในคลัง ลองตั้งวันหมดอายุใกล้ ๆ วันนี้อย่างน้อย 1 รายการ
3. ไปที่แท็บ "แผนอาหาร" เลือกวันและมื้อที่ต้องการ กดไอคอนประกาย ✨ ("แนะนำเมนูด้วย AI")
4. ถ้า Deploy Edge Function แล้ว: AI จะเลือกเมนูจากฐานข้อมูล 44 เมนู หรือคิดเมนูใหม่ให้ โดยพยายามใช้วัตถุดิบใกล้หมดอายุที่มี และจะโชว์เหตุผลสั้น ๆ ใน SnackBar
5. ถ้ายังไม่ได้ Deploy: ระบบจะสุ่มจากฐานข้อมูลแทนเงียบ ๆ โดยผู้ใช้ไม่เห็น Error ใด ๆ (ทดสอบ Fallback ได้โดยยังไม่ต้องตั้งค่า Edge Function เลย)
6. ลองตั้งวัตถุดิบที่แพ้เป็นชื่อที่ตรงกับเมนูยอดนิยม (เช่น "ไข่") แล้วกดแนะนำเมนูซ้ำ ๆ หลายรอบ → เมนูที่มีไข่ต้องไม่ถูกแนะนำเลยแม้แต่ครั้งเดียว (ระบบเช็กซ้ำทั้งฝั่ง Edge Function และฝั่งแอป)

## 10. Test Checklist

### Part 1-5 (คงเดิม — ดู Checklist เดิมในเวอร์ชันก่อนหน้า)

### Part 6 (ใหม่)
- [ ] ยังไม่ Deploy Edge Function: กดแนะนำเมนูด้วย AI ยังใช้งานได้ปกติ (Fallback เป็นระบบสุ่มจากฐานข้อมูล) ไม่มี Error โผล่ให้ผู้ใช้เห็น
- [ ] Deploy Edge Function + ตั้ง Secret แล้ว: กดแนะนำเมนูด้วย AI ได้คำแนะนำจริงจาก Claude พร้อมเหตุผลใน SnackBar
- [ ] เมนูที่ AI เลือกจากฐานข้อมูล (source=template) บันทึกด้วย `meal_template_id` ที่ถูกต้อง เชื่อมกับ "เพิ่มวัตถุดิบลงรายการซื้อของ" ได้ตามปกติ
- [ ] เมนูที่ AI คิดใหม่ (source=custom) บันทึกชื่อ/ราคา/เวลาเตรียม/ความยากถูกต้อง และวัตถุดิบที่ AI แนะนำถูกใส่ไว้ในหมายเหตุให้อ่านได้
- [ ] ตั้งวัตถุดิบที่แพ้แล้วกดแนะนำเมนูซ้ำหลายรอบ ไม่มีครั้งไหนแนะนำเมนูที่มีวัตถุดิบที่แพ้เลย (ตรวจสอบทั้ง Edge Function และฝั่งแอป)
- [ ] AI พยายามแนะนำเมนูที่ใช้วัตถุดิบใกล้หมดอายุที่มีอยู่ก่อน (ทดสอบเชิงคุณภาพ ไม่ใช่ Deterministic 100%)
- [ ] ปิดอินเทอร์เน็ตแล้วกดแนะนำเมนูด้วย AI → Fallback ไปใช้ระบบสุ่มในเครื่องได้ ไม่ค้างหรือ Crash
- [ ] `ANTHROPIC_API_KEY` ไม่ปรากฏอยู่ในไฟล์ใด ๆ ของโปรเจกต์ Flutter เลย (ตรวจสอบด้วย `grep -r "ANTHROPIC_API_KEY" lib/` ต้องไม่เจอ)

## 11. สถานะ Feature

| Feature | สถานะ |
|---|---|
| Auth, Dashboard, SQL Schema, Seed เมนู | ✅ Part 1 |
| แบ่งเงินเดือน, รายจ่ายฉบับเต็ม | ✅ Part 2 |
| วัตถุดิบ, แผนอาหาร, รายการซื้อของ | ✅ Part 3 |
| ประวัติ/รายงาน + กราฟ, ระบบแจ้งเตือน | ✅ Part 4 |
| ตั้งค่า, Keep-Alive | ✅ Part 5 |
| AI แนะนำเมนูจริง (Claude ผ่าน Edge Function) พร้อม Fallback | ✅ Part 6 |

**ครบทุกหัวข้อตามสเปกเดิม บวกการเชื่อม AI ที่ระบุไว้ว่า "ไว้ทำในอนาคต" เรียบร้อยแล้ว**

---

**หมายเหตุ**: ห้ามแก้ไขชื่อ Table, Column, Class หรือ Route ที่มีอยู่แล้วใน Part ถัดไป เพื่อรักษาความเข้ากันได้
#   k i n d e e - m e e n g o e n k e b -  
 