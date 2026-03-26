# 03B - Booking: Double Opt-in (Xác nhận Email)

> Bảo vệ hệ thống khỏi các bot spam booking hòng làm "kín bàn" giả tạo.

---

## 1. Luật Bảo Mật (Tại sao phải làm?)
Bất kỳ ai cũng có thể nhập email `angela.merkel@bundestag.de` để trêu chọc nhà hàng bạn. Nếu hệ thống tự động đẩy thư "Xác nhận Booking", nhà hàng phạm luật Spam email của EU.

## 2. Quy Trình Implementation Của Opt-in

1. Khách điền Form Đặt Bàn, ấn Submit.
2. Form lưu dữ liệu vào DB (Prisma) với trạng thái: `status = PENDING`.
3. Giao diện Website hiện ra trang "*Vielen Dank! Xin hãy kiểm tra hòm thư của bạn để Xác Nhận*".
4. Server (Resend SendMail) gửi đi 1 email kèm 1 Magic Link sinh ra từ UUID: 
   `https://nhahang.de/api/verify-booking?token=abc-123-xyz`
5. Trong 30 phút, nếu Khách mở Email đó ra bấm vào Link:
   - Request đâm vào Route `api/verify-booking` của Next.js.
   - Server đổi: `status = CONFIRMED`.
   - Ngay lúc này màn hình Admin Dashboard tại quán mới reo chuông "Ting! Có Booking mới".
6. Nếu sau 30 phút không bấm, Cron Job hoặc check ngầm tự xoá Booking đó rác vào sọt.
