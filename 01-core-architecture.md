# Khối nền tảng & Kiến trúc cốt lõi (Core Architecture)

> Sử dụng mô hình ứng dụng full-stack trên 1 repo (Next.js 15 + React 19). Không cần tách riêng Backend và Frontend.

---

## 1. Cấu trúc thư mục (File Structure)

Chúng ta sử dụng Pattern `Feature-Driven` kết hợp quy tắc của App Router (`app/`).

```bash
📦 next-restaurant-app
 ┣ 📂 app
 ┃ ┣ 📂 (shop)               # 1. GROUP CLIENT WEB (Khách hàng)
 ┃ ┃ ┣ 📂 menu               # Menu món ăn 
 ┃ ┃ ┣ 📂 checkout           # Thanh toán, Checkout, Địa chỉ
 ┃ ┃ ┣ 📂 booking            # Đặt bàn
 ┃ ┃ ┣ 📂 track              # Trang Live-tracking (Khách nhận Link từ Gmail)
 ┃ ┃ ┗ 📜 layout.tsx         # Navbar/Footer cho khách hàng
 ┃ ┣ 📂 (admin)              # 2. GROUP ADMIN WEB (Quản lý/Waiter)
 ┃ ┃ ┣ 📂 dashboard          # Thống kê, Doanh thu
 ┃ ┃ ┣ 📂 live-orders        # Live Kanban Board (Mới -> Đang Nấu -> Xong)
 ┃ ┃ ┣ 📂 reservations       # Lịch đặt bàn (Calendar view)
 ┃ ┃ ┗ 📜 layout.tsx         # Sidebar cho Admin
 ┃ ┗ 📂 api                  # Webhooks (Stripe Payment, v.v.)
 ┣ 📂 components
 ┃ ┣ 📂 ui                   # (Shadcn UI base components: button, dialog, form...)
 ┃ ┣ 📂 features             # (Complex UI: ShoppingCart, BookingCalendar...)
 ┃ ┗ 📂 layout               # (Navbar, Sidebar, Footer)
 ┣ 📂 lib                    # Thư viện core (db.ts, utils.ts, stripe.ts, resend.ts)
 ┣ 📂 actions                # SERVER ACTIONS (Thao tác Database không cần viết API)
 ┃ ┣ 📜 order-actions.ts 
 ┃ ┗ 📜 booking-actions.ts
 ┣ 📂 prisma
 ┃ ┗ 📜 schema.prisma        # Database Schema
 ┗ 📜 tailwind.config.ts     # Config v4 / Shadcn vars
```

## 2. Giao tiếp Dữ liệu (Server Actions)

Trong Next.js 15 / React 19, thay vì tạo các API Route (`/api/create-order`) và dùng `fetch` từ Frontend, ta dùng **Server Actions**:

**Flow ví dụ (Khách bấm Đặt Bàn):**
1. Client-Side: Tích hợp `react-hook-form` + `zod` bắt lỗi Form ngay lập tức.
2. Form gọi hàm `createBookingAction(formData)` được định nghĩa bằng `'use server'`.
3. Hành động chạy ngầm trên Server: Xác thực data, lưu vào DB bằng Prisma, gọi API Resend gửi Email.
4. Trả kết quả thành công/thất bại về Form bằng Hook mới của React 19 (`useActionState`).

Lợi ích: Khối lượng code giảm 40%, không lo lộ token lên Frontend, cực kỳ bảo mật (tương tự RPC call).

## 3. UI System & Theming (Shadcn + Tailwind)

### 3.1 Giao diện (Design Language)
- Bảng màu: Tuỳ biến dựa trên HSL variables (`--primary`, `--background`) chuẩn thiết kế nhà hàng sang trọng.
- Hiệu ứng: Dùng `framer-motion` cho các Loading State, Transitions.
- Component: Sử dụng thư viện gốc `shadcn/ui`. Các UI nguyên tử này (button, card, dialog) được ném thẳng vào source code chứa file `.tsx`, dễ dàng thay đổi CSS.

### 3.2 Responsive Sizing
- `< sm` (Mobile): Menu Bottom Navigation Bar. Khách dễ dàng dùng tay đặt món, xem giỏ hàng ở dưới đáy màn hình.
- `>= md` (Tablet): Rất quan trọng cho Waiter/Kitchen. Admin Live-orders hiển thị giao diện chia cột (Split View - Cột Đơn, Cột Chi tiết).
- `>= xl` (Desktop PC): Giao diện Kasse Admin hoặc cho Landing Page toàn cảnh.

## 4. Quản lý Trạng thái (State Management)

1. **Server State**: Những dữ liệu như Danh sách món ăn, Lịch Đặt bàn được Next.js fetch ở Server (RSC), truyền xuống UI. Nó tự động cache siêu tốc độ.
2. **Client State (Giỏ hàng - Cart)**: Sử dụng **Zustand** kết hợp `persist` middleware. Giỏ hàng lưu lại trong LocalStorage của trình duyệt. 
   - Khách đang gom đồ vào giỏ -> Lỡ tay đóng trình duyệt -> Mở lại Web giỏ hàng vẫn còn nguyên.
