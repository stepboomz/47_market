# วิธีปิด Email Confirmation ใน Supabase

## ปัญหา
เมื่อสมัครสมาชิกแล้วขึ้น error: "Email not confirmed" 

## วิธีแก้ไข

### วิธีที่ 1: ปิด Email Confirmation ใน Supabase Dashboard (แนะนำ)

1. ไปที่ [Supabase Dashboard](https://app.supabase.com)
2. เลือก Project ของคุณ
3. ไปที่เมนู **Authentication** (ด้านซ้าย)
4. คลิก **Settings** (หรือ **Providers**)
5. หา section **Email Auth**
6. **ปิด (Toggle OFF)** "Enable email confirmations"
7. คลิก **Save**

### วิธีที่ 2: ใช้ Database Function (ถ้าไม่สามารถเข้าถึง Dashboard)

1. ไปที่ Supabase Dashboard > **SQL Editor**
2. รันไฟล์ `disable_email_confirmation.sql`
3. Function นี้จะ auto-confirm users ทันทีหลังสมัคร

### วิธีที่ 3: ใช้ Service Role Key (สำหรับ Development เท่านั้น)

⚠️ **คำเตือน**: วิธีนี้ใช้ได้เฉพาะใน Development เท่านั้น ไม่ควรใช้ใน Production

1. ไปที่ Supabase Dashboard > **Settings** > **API**
2. คัดลอก **service_role key** (ไม่ใช่ anon key)
3. ใช้ service_role key ในโค้ดเพื่อ auto-confirm users

## ตรวจสอบว่าปิดแล้วหรือยัง

หลังจากปิด email confirmation แล้ว:
1. ลองสมัครสมาชิกใหม่
2. ควรจะสามารถ login ได้ทันทีโดยไม่ต้องยืนยันอีเมล

## หมายเหตุ

- การปิด email confirmation จะทำให้ผู้ใช้สามารถ login ได้ทันทีหลังสมัคร
- สำหรับ Production อาจจะต้องการเปิด email confirmation เพื่อความปลอดภัย
- ถ้ายังมีปัญหา ให้ตรวจสอบว่าได้รัน SQL migration แล้วหรือยัง

