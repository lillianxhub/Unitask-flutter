# 🎯 UniTask - Flutter

Unitask is a collaborative task management application built with Flutter and Firebase.

## 📱 Download Application
**You can download the latest Android app (APK) here:**
### [📥 Download UniTask.apk](https://github.com/lillianxhub/Unitask-flutter/releases/latest)

---

## 🚀 Features
- **Smart Progress Tracking**: Tasks are only completed when everyone assigned marks them as done.
- **Smart Priority Badges**: See overall project workload or your personal tasks at a glance.
- **Real-time Notifications**: Get notified on role changes, invites, and task updates.
- **Smart UI**: Read-only task viewing with quick edit/delete access for owners.

## 🛠️ รายละเอียดฟังก์ชันตามบทบาท (Role Functions)

### 👥 ผู้ใช้ทั่วไป (Role: User)
*ทุกบทบาทสามารถทำสิ่งเหล่านี้ได้:*
- **ดูภาพรวม**: ดูโปรเจกต์และงานทั้งหมดที่ได้รับมอบหมาย
- **สถิติ**: ดูสรุปผลการทำงานและอัตราความสำเร็จของตัวเอง
- **การแจ้งเตือน**: รับการแจ้งเตือนแบบเรียลไทม์เมื่อมีการอัปเดตงานหรือคำเชิญ
- **แสดงความเห็น**: เขียนความคิดเห็นในโปรเจกต์หรืองานต่างๆ
- **ตั้งค่าส่วนตัว**: แก้ไขข้อมูลส่วนตัว เปลี่ยนรหัสผ่าน และเลือกธีม (Light/Dark Mode)

### 👑 เจ้าของโครงการ (Role: Owner)
- **จัดการโปรเจกต์**: สร้าง แก้ไข และลบโปรเจกต์ได้ทั้งหมด
- **จัดการสมาชิก**: เชิญสมาชิกใหม่ และกำหนดบทบาท (Editor/Viewer)
- **จัดการสถานะ**: เปลี่ยนสถานะโปรเจกต์ (ทำอยู่/เสร็จสิ้น) หรือเปิดโปรเจกต์ใหม่
- **ควบคุมสูงสุด**: มีสิทธิ์ในการจัดการงานทุกอย่างในโปรเจกต์

### 📝 ผู้แก้ไข (Role: Editor)
- **จัดการงาน**: สร้าง แก้ไข และลบทาสก์ (Task) ภายในโปรเจกต์
- **มอบหมายงาน**: ระบุผู้รับผิดชอบและกำหนดวันส่งงาน (Due Date)
- **อัปเดตงาน**: เปลี่ยนสถานะความคืบหน้าของงาน

### 👁️ ผู้เข้าชม (Role: Viewer)
- **อ่านอย่างเดียว**: ดูรายละเอียดของโปรเจกต์และงานทั้งหมดได้ แต่ไม่สามารถแก้ไขหรือลบข้อมูลได้
- **มีส่วนร่วม**: สามารถเขียนความคิดเห็น (Comment) เพื่อสื่อสารกับทีมได้

## 🛠️ Tech Stack
- **Framework**: Flutter
- **Backend**: Firebase (Firestore, Auth, Cloud Messaging)
- **State Management**: Provider

---

## 👨‍💻 Getting Started
1. Clone the repository
2. Run `flutter pub get`
3. Set up your Firebase project and add `google-services.json`
4. Run `flutter run`
