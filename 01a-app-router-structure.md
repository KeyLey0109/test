# 01A - Cấu trúc App Router (Thư mục)

> Lõi dự án Next.js 15 chia theo Route Groups để tối ưu Layout.

---

## 1. Route Groups `(shop)` vs `(admin)`
Bằng cách dùng ngoặc đơn `()`, đường dẫn URL không bị ảnh hưởng, nhưng chúng ta tách được 2 Layout hoàn toàn khác nhau.

```bash
app/
 ┣ (shop)/
 ┃ ┣ layout.tsx       # Navbar Khách hàng + Footer (Impressum)
 ┃ ┣ page.tsx         # Landing Page giới thiệu nhà hàng
 ┃ ┣ menu/page.tsx    # Digital Menu
 ┃ ┣ checkout/page.tsx
 ┃ ┗ booking/page.tsx
```

Giao diện Quản lý:
```bash
app/
 ┣ (admin)/
 ┃ ┣ layout.tsx       # Sidebar 2 cột + Topbar User Profile
 ┃ ┣ dashboard/       # Báo cáo doanh thu
 ┃ ┣ live-orders/     # Màn hình cho Bếp & Lễ tân
 ┃ ┗ cms/             # Sửa Menu món ăn
```

## 2. Dynamic Routing cho Tracking Đơn Hàng
Đối với luồng Gửi link theo dõi đơn hàng:

```bash
app/
 ┣ track/
 ┃ ┗ [orderId]/
 ┃   ┗ page.tsx      # VD: /track/uuid-xxx
```
Trang này sẽ liên tục fetch realtime tiến độ đơn hàng.

## 3. SEO & Metadata
- Các thư mục trong `(shop)` như `menu` hay `booking` bắt buộc export Metadata tĩnh hợp lệ.
- File `robots.txt` chặn ngầm `/(admin)` và `/track/[orderId]` để Google không crawl link đơn cá nhân của khách.
