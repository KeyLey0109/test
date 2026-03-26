# 02B - Database Schema: Booking (Đặt Bàn)

> Quản lý thời gian, sức chứa và kiểm duyệt DSGVO.

---

## 1. Schema Booking

```prisma
model Booking {
  id              String        @id @default(uuid())
  
  // Thông tin liên hệ Khách
  contactName     String
  contactEmail    String        // Dùng để Gửi mail xác nhận
  contactPhone    String
  
  // Nội dung Booking
  partySize       Int           // VD: 4 người
  bookingDate     DateTime      // Lưu chuẩn ISO-8601 (VD: 2026-10-15)
  bookingTime     String        // Lưu Text để dễ search (VD: "19:00")
  
  // Trạng thái Lifecycle
  status          BookingStatus @default(PENDING)
  
  // Pháp lý Đức
  dsgvoConsent    Boolean       // True
  
  // Custom request
  specialRequests String?

  createdAt       DateTime      @default(now())
}

enum BookingStatus {
  PENDING    // Mới đặt, đợi Confirm Email từ khách
  CONFIRMED  // Khách ấn link trong Email (Double Optin) -> Giữ bàn
  CANCELLED  // Hủy
  COMPLETED  // Đã đến và ăn xong
}
```

## 2. Ghi chú về Múi Giờ (Timezone)
Server lưu `bookingDate` là giờ `UTC`. Khi render lại bảng Kanban cho Admin tại Đức, Next.js sẽ ép kiểu giờ (Format) về `Europe/Berlin` (+1/+2 CEST) để tránh Admin bị lệch 1 tiếng so với khách đặt.
