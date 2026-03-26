# 05C - Admin: Quản Lý Khách Đặt Bàn (Reservations)

> Trọng Tầm của Lễ Tân Đứng Máy Tablet Cửa Hàng. Thấy Lịch Trống, Biến Ảo Sơ Đồ.

---

## 1. Giao Diện (Calendar View & Timeline)

Admin không dùng Kanban cho Đặt Bàn, mà dùng View Tuần / View Ngày (Fullcalendar.io hoặc viết Custom Grid Shadcn UI).

- Ở Dạng "Ngày (Daily)": Cắt theo Khung Giờ Mở Cửa (từ 11:00 đến 14:00 VÀ 17:00 đến 23:00).
- Khách hiển thị dưới dạng Block trên biểu đồ (VD: Nguyễn Văn A - 4 người - 18:00 tới 20:00).
- Biểu đồ thời gian (Timeline) sẽ trực quan hóa (Cụm Bàn trống, Cụm Nào đông ngút).

## 2. Xử Lý Tình Huống

**Khách gọi Zalo/SĐT kêu đặt mồm:** 
- Admin gõ vào form "Create Manual Booking". Tạo Book luôn không cần chạy qua Front-End. Hệ thống vẫn lưu Data. Vẫn trừ Capacity 50 ghế (VD Admin tạo khách B 10 người thì kho giảm xuống).

**Phê Duyệt Lệnh Pending:** 
- Không cài Opt-in (Xác nhận email 03B) mà dùng Admin Confirm Tay. List khách Booking có cờ màu Trắng, Lễ tân check có thật không, Lễ tân Bấm "Confirm" -> Cờ chuyển Đỏ, gửi mail từ mail Server cho khách: Bàn của quý khách đã giữ.

**Ngăn Chặn (Block Schedule):**
- Quán nghỉ lễ Giáng Sinh (24-12). Lễ tân kéo lịch bôi đen một hàng (Block 24-12 -> 25-12). Tự Server Prisma nạp vào dữ liệu: Ai chọn ngày trong Front-End Webapp, Hệ thống Block luôn DatePicker. Vô hiệu hóa Booking.
