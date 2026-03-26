# 02A - Database Schema: Users & Roles

> Hệ thống phân quyền chặt chẽ giữa Khách Hàng và Ban Quản Lý.

---

## 1. Khách Hãng (Guest vs Registered)
Web-Shop đặt món/bàn hiếm khi bắt khách tạo tài khoản (Đức coi trọng DSGVO và sự ẩn danh). Do đó, Model User phục vụ chủ yếu cho Admin. Mọi Booking/Order của Khách liên kết qua `Email` và `SĐT`.

```prisma
model User {
  id            String    @id @default(cuid())
  name          String?
  email         String    @unique
  passwordHash  String?   // Bcrypt hash
  
  role          UserRole  @default(CUSTOMER)
  
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
}

enum UserRole {
  CUSTOMER  // Khách tạo tài khoản (Tích điểm tương lai)
  WAITER    // Nhân viên bàn / Bếp
  MANAGER   // Quản lý cửa hàng
}
```

## 2. Bảo mật (Authentication)
Bảng Database này kết nối 1-1 với thư viện `NextAuth v5`:
- Dùng `credentials_provider` cho Manager đăng nhập bằng mật khẩu (Hash).
- Session JWT lưu trong Cookie (HttpOnly). Web không bị đánh cắp SessionID.
