# Feature: Live Orders Dashboard (Admin Panel)

> Một Kanban UI hiện đại dành cho Giao diện quản lý của nhân viên (Nhà bếp/Waiter).

---

## 1. Màn Hình Quản Lý Đơn Gọi Món (Màn Dọc cho Tablet)

Tại đây, thay vì load lại trang F5 nhiều lần, chúng ta áp dụng **Server-Sent Events (SSE)** hoặc Websocket cơ bản, hoặc React Query Poll dữ liệu mỗi 5s để Update tự động (vừa đủ mượt mà không quá chi phí).

Admin nhận 1 màn hình chia làm 3 cột Kanban khổng lồ (Kéo - Thả / Click Status):
1. **NEU (Mới Nhận)**
2. **IN ZUBEREITUNG (Đang xử lý / Đang nấu)**
3. **FERTIG / UNTERWEGS (Xong / Đang Giao)**

**Quy trình Waiter thao tác:**
- Khi đơn mã `#ORD-902` hiện trên Cột 1 (Có chuông Ping báo đơn mới). 
- Waiter bấm "Chấp Nhận", đơn chuyển sang Cột 2. 
- Ngay lúc bấm "Chấp Nhận", Server chạy hàm đổi Status DB và Gửi Update Status Tracking cho Khách.

## 2. Quản Lý Đặt Bàn (Reservations View)

Không dùng cột Kanban như Đơn hẹn, dùng **Lịch Tuần (Weekly / Daily Table View)**.
- Liệt kê theo Giờ trong Ngày (VD Ngày 12/10 có 10 bàn).
- Tính tổng Capacity (Số người đến ăn) theo từng Slot giờ để Nhân viên biết khi nào quá tải.
- Waiter nhấn nút "Confirmed" để gỡ trạng thái Pending, gửi Mail báo khách "Bàn của bạn đã được chúng tôi giữ chỗ".

## 3. Quản Lý Danh Mục & Món (CMS)
- Thêm xoá sửa món (CRUD) bằng Server Actions + Shadcn Forms.
- Upload hình ảnh. (Mẹo: Có thể không cần đăng ảnh món, text-menu giống các nhà hàng Fine-dining hoặc dùng ảnh minh họa từ UploadThing/AWS S3).
- Chỉnh sửa giá cả dễ dàng (Nhớ nhập EUR nhưng DB cất là CENTS).

## 4. Xác Thực Quyền (Authentication & RBAC)

Dùng NextAuth v5 cho /admin.

- Không cần đăng ký tự do, Admin phải tự tạo tk cho Nhân viên bằng dòng lệnh hoặc tạo tài khoản cứng từ trước.
- **Roles:**
   - Waiter: Chỉ được coi Bảng Orders và ấn "Chấp nhận, Xong". Không được xoá bill.
   - Manager: Xem tổng doanh xu, thay đổi tên món trên Menu, xoá hoặc đổi món.
   - Khách (Customer): Không được vào /admin, bị tự động đẩy về trang chủ (Middleware bảo vệ).
