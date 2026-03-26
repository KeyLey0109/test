# Feature: Booking Engine (Hệ thống đặt bàn & DSGVO)

> Website nhận đặt bàn trực tuyến, chặn over-booking, tối ưu hoá form với luật bảo vệ dữ liệu Châu Âu.

---

## 1. Giao diện Đặt bàn trên Web Khách Hàng

Sử dụng bộ kịch bản **Bước từng bước (Wizard UI)**, thân thiện cho Mobile:

1. **Step 1: Chọn ngày & giờ & Người**
   - Dùng thành phần `Calendar` của Shadcn UI (DatePicker).
   - Chọn Số lượng khách (Party size) bằng Nút +/-.
   - Trực tiếp fetch xuống Server Action kiểm tra xem ca (Lunch 11-14h, Dinner 17-22h) còn khả dụng không. 

2. **Step 2: Nhập thông tin & Yêu cầu**
   - Các field thiết yếu: Tên, Email, SĐT.
   - Textarea: "Bạn có đem theo chó? Yêu cầu ăn chay? Dị ứng?".

3. **Step 3 (Critical Đức): DSGVO Consent & Check**
   - `<Checkbox>`: *"Ich habe die Datenschutzerklärung gelesen und stimme der Verarbeitung meiner Daten zu."*
   - Khách **phải tick** checkbox này mới nháy sáng nút "Jetzt Reservieren" (Book Now).

## 2. Server Action (Kiểm duyệt đằng sau)

```ts
"use server";

export async function createBookingAction(formData: FormData) {
   // 1. Zod validation trên server (Check độ dài email, format số điện thoại DE: bắt đầu bằng +49 hoặc 0)
   // 2. Chặn Request rác (Rate limit middleware)
   // 3. Save to Prisma DB với Status = PENDING
   // 4. Kích hoạt Email Service (Gửi mail Double Opt-in hoặc Gửi thẳng Booking ID).
}
```

## 3. Quản lý Availability (Capacity / Bàn trống)

- Hệ thống không gán bàn ảo (Ví dụ ghép khách vào Bàn số 5) ngay lúc khách đặt. Điều này gây khó dễ cho Nhà hàng trong thực tế.
- Hệ thống dùng thuật toán **Capacity Based**:
  - Nhà hàng cấu hình: Tối đa phục vụ 50 người cùng 1 thời điểm.
  - Khách A đặt 4 người lúc 18:00.
  - Khách B đặt 10 người lúc 18:00.
  - Tổng đang chứa: 14/50. 
  - Nếu số đạt 50, Slot 18:00 tự động mờ đi (Disabled) không cho khách tiêp theo booking giờ đó.

## 4. Double Opt-in (Tùy chọn Anti-Spam của Đức)

Ở Châu Âu, rất nhiều đối thủ cạnh tranh hoặc Bot có thể nhập email giả (ví dụ email của Thủ tướng) để đặt bàn. Điều này làm nhà hàng mất slot trống và vi phạm DSGVO nếu spam mail cho người ko đặt.

**Giải pháp đề xuất:**
1. Khách điền Form.
2. Web báo: *"Chúng tôi đã gửi 1 Email xác nhận. Vui lòng click link trong email."*
3. DB ghi: `status = PENDING`. Guest nhận Mail qua Resend, ấn nút "CONFIRM BOOKING".
4. DB chuyển: `status = CONFIRMED`. Lúc này Manager Dashboard mới thông báo có khách. Trang web Admin đổ chuông thông báo (Sound notification).
