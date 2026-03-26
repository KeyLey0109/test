# 05A - Admin: Live Kanban Board

> Màn hình Bếp (Kitchen) / Giao món (Delivery Screen) trực quan nhất hiện nay.

---

## 1. Giao Diện (Thành Phần Chính)

Màn hình ngang (Tablet/Desktop) chia 3 cột chính:
1. **NEU (Màu Vàng / Đỏ)**: Đơn khách mới tinh vừa quẹt thẻ, Nhà bếp chưa chạm vào. Mọi máy mở trang này Cing Ceng chuông báo (`audio` play HTML5). Ping mỗi 5 giây nếu không có người click.
2. **IN ZUBEREITUNG (Nấu Nướng / Màu Đỏ Phai)**: Bếp xác nhận đơn, đang chuẩn bị đồ. Ở cột này, in ra giấy "Bếp" (Kitchen Slip).
3. **FERTIG / AUF DEM WEG (Sẵn Sàng Giao)**: 
   - Nếu Khách Lấy (Pickup) -> Rớt xuống ô Hoàn thành/Nhận tiền.
   - Nếu Giao (Delivery) -> Đang trong quá trình shipper rục rịch đi giao đến nhà KH. Cột này theo độ dời thời gian mà báo Đỏ (Ship Quá Trễ).

## 2. Server Updates (Next.js Revalidation/Polling)

Để bảng Kanban nhảy đơn mới Real-Time:
- Có thể dùng `setInterval` + `React Query` (gọi Fetch check API lại theo chu kì 10s một lần). Đỡ tốn công thiết lập WebSocket Nodejs cồng kềnh.
- Hoặc hiện đại hơn: Webhook (Server-sent events) đẩy sự kiện lên client Next.js.

## 3. Cập Nhật Status Cho Khách (Webhook/Email)

Khi Waiter móc chuột cầm Tấm thẻ Đơn số `#1005` ném sang ô `IN ZUBEREITUNG` (Drag & Drop UI - `dnd-kit`).
- React kích hoạt `updateOrderStatusAction('#1005', 'COOKING');`.
- Database lưu lại thông số Order chuyển cờ (Flag) sang Status đang nấu.
- Màn hình Live Tracking của Khách sẽ thấy Bút trỏ tiến trình (Progress Bar) chạy tới Khúc `Đang Nấu`. (Giật nẩy vui nhộn).
