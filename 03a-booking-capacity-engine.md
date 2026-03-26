# 03A - Booking: Capacity Engine (Kiểm soát năng lực bàn)

> Loại bỏ việc gắn chết khách vào Bàn số mấy (Fixed Table) khi khách đặt online. Thay vào đó, kiểm soát Tổng Sức Chứa (Capacity).

---

## 1. Cơ chế Capacity Base Logic

- Thực tế nhà hàng: Khách đông đôi khi kéo ghế ghép bàn, khách đặt Bàn số 2 nhưng lúc đến lại đòi ngồi Bàn số 4.
- Giải pháp phần mềm: Quản lý **Tổng số người tối đa** (Max Capacity) theo một Session giờ.

Ví dụ Hệ thống cấu hình: 
- `Max_Guests = 60 người` lúc `18:00`.

## 2. Truy Vấn Tính Toán Khi Booking
Mỗi khi khách chọn Giờ `19:00` trong `DatePicker`, Next.js gọi Server Action ngầm `checkAvailability(date, time, partySize)`:

```ts
// 1. Tính tổng số khách đã xác nhận tại khung giờ 19:00
const currentBooked = await prisma.booking.aggregate({
  _sum: { partySize: true },
  where: { 
    bookingDate: "2026-10-15",
    bookingTime: "19:00",
    status: { in: ['CONFIRMED', 'COMPLETED'] }
  }
}); // => Kết quả: 50 người đang giữ chỗ

// 2. Xét partySize của khách mới
// Nếu khách mới đi 12 người -> 50 + 12 = 62 > 60 (Over-capacity)
// => Server Action trả lời: "Sorry, we are full at 19:00" -> Render lại Shadcn DatePicker để mờ nút bấm.
```

## 3. Quản lý Khóa Ngày (Blocks / Holidays)
Ngoài việc check số lượng, hệ thống có 1 bảng `BlockedDate` cho Admin khoá ngày nghỉ lễ (Feiertage).
```prisma
model BlockedDate {
  date     DateTime
  reason   String?  // Ghi chú: "Urlaub"
}
```
Lúc gen lịch cho khách, những ngày này bị `disabled`.
