# Restaurant E-Commerce & Booking System — Next.js 15 Architecture

> **Mục tiêu**: Hệ thống đa năng (Web App) hoàn chỉnh cho nhà hàng, phục vụ Đặt bàn và Giao/Nhận đồ ăn trực tuyến (Delivery/Pickup), chạy trên **Desktop** và **Mobile Web** bằng **Next.js 15 & React 19** thuần — single codebase. Bao gồm Web tương tác cho khách hàng và một **Trang Quản Trị Riêng Biệt (Admin Live Dashboard)** chỉ dành cho nội bộ nhà hàng nắm giữ.

---

## 1. Tổng quan

### Vấn đề cần giải quyết
Nhà hàng Đức cần hệ thống Web hiện đại thay thế quy trình thủ công:
- Khách tự Đặt bàn trực tuyến, ngăn chặn over-booking theo công suất chứa thực tế.
- Khách tự Đặt món ăn online (Giao tận nơi hoặc Đến lấy) như một Mini-Ecommerce.
- Tuân thủ cực kỳ khắt khe luật Đức: DSGVO (Bảo vệ dữ liệu GDPR), LMIV (Chất phụ gia/Dị ứng), Steuern (Thuế 7% giao đi vs 19% ăn tại bàn).
- Hoạt động mượt mà trên điện thoại của khách. Đồng thời, hệ thống có một **Trang riêng cho Admin (Live Dashboard)** liên tục cập nhật trạng thái đơn (Kanban) do nhân viên/quản lý nhà hàng nắm quyền truy cập.

### Main Workflows (Luồng Vận Hành Chính)

**1. Booking Workflow (Luồng Đặt Bàn)**
```text
1. Khách Nhập: Chọn Thời gian (Date/Time) & Số lượng (Party Size)
       │
2. Client/Server Validate: Kiểm tra Capacity (Bàn trống)
   └── Nếu hệ thống nhận diện khung giờ đó đã "Full", đề xuất khung giờ khác.
       │
3. Thông tin Liên Hệ: Điền Tên, SĐT, Email & BẮT BUỘC Check DSGVO Consent
       │
4. Double Opt-in (Xác Thực Đức): 
   └── DB tạo Status PENDING -> Gửi Email Magic Link -> Khách ấn xác nhận -> Trở thành CONFIRMED.
       │
5. Cập nhật Dashboard:
   └── Lễ tân nghe âm báo Ting! từ iPad -> Check Admin View (Reservations) -> Phân bàn.
```

**2. E-Commerce Workflow (Luồng Đặt Món: Delivery / Pickup)**
```text
1. Lướt Thực Đơn Digital (Menu Catalog)
   └── Phân Category, hiện Allergen (A, G...) -> Thêm món vào Local Cart (Zustand).
       │
2. Nhấn Cart -> Mở Checkout
   └── Chọn { Delivery } hoặc { Pickup }.
   └── Nếu Delivery -> Nhập PLZ (Zipcode) -> Fetch API kiểm tra khu vực giao & Tính phí Ship.
       │
3. Cổng Thanh Toán (Payments)
   └── Khách chọn trả Stripe (Thẻ) HOẶC trả Bar/EC (Tiền Mặt lúc nhận đồ). Nút bấm "Zahlungspflichtig bestellen".
       │
4. Live Orders Kanban (Nhà Bếp Action)
   └── Màn hình Tablet Bếp Ting! báo đơn. Từ mốc [NEU] -> Kéo qua [IN ZUBEREITUNG].
       │
5. Cập nhật Live Tracking (Khách xem tiến độ)
   └── Khách nhận Email Receipt kèm URL Link theo dõi ngầm. Khi bếp kéo thẻ, màn hình Khách tiến mốc.
```

### Tại sao Next.js 15 + React 19?
| Vấn đề | Giải pháp của Next.js 15 |
|--------|----------------|
| Tốc độ Tải / SEO (Kéo khách khứa) | **App Router SSR + RSC**: Render toàn HTML tại Server. Chuẩn SEO 100%. Web load cực nhẹ cho 3G/4G trên phố. |
| Bảo mật Data gọi Database | **Server Actions**: Không lộ Endpoint `/api/` dễ bị Hack. React Hook Form ném thẳng dữ liệu lên Node.js. |
| Quản lý giao diện cực khổ | Dùng **Shadcn UI** và **TailwindCSS v4**, bốc Component Atomic cực kỳ sắc nét về thả vào app. Hoàn toàn override CSS trực tiếp được. |
| Server Backend rời rạc | Tích hợp **Prisma ORM** gọi đến PostgresQL. Thay thế Backend truyền thống. Deployment ở Vercel (1 nút ấn rẹt xong Front+Back). |

---

## 2. Technology Stack Chi Tiết

| Tầng (Layer) | Lựa chọn Công nghệ | Mô tả Chuyên Sâu |
|-------|-----------|-------|
| **Core Framework**| **Next.js 15.x (App Router)** | Framework lõi. Chạy song song Client Component và Server Component. |
| **Language** | **TypeScript 5.x** | Kiểm soát Data Type tuyệt đối từ DB Prisma đến Props React. |
| **Architecture**| **Feature-Driven** | Nhóm thư mục File cấu trúc chuẩn Component. UI chia theo Layout & Page. |
| **State Mgt.** | **Zustand + Mid. Persist** | Lưu trữ Local Giỏ đồ ăn. Tránh mất Order khi Refesh trang (F5). |
| **Database** | **PostgreSQL (Neon/Vercel)** | Relational Data. Tuyệt đối hoàn hảo cho Schema E-commerce. |
| **ORM** | **Prisma** | Migration Database mượt, tự Gen TS Types, query cực dễ đọc. |
| **Auth** | **NextAuth.js (v5)** | Chỉ dùng đăng nhập (RBAC) cho Bếp/Owner Panel. JWT Token Cookie sấy SSL. |
| **Mailing** | **Resend + React Email**| Chấm dứt cảnh viết HTML E-mail đau mắt. Xây email bằng React `<Button>`. Tỉ lệ đấm vào Inbox chính 99%. |
| **Giao Diện** | **Shadcn UI + Framer Motion**| Component Radix UI gốc nguyên tử, Modal, Checkbox, Accordion siêu mượt. |
| **Validations** | **Zod + RHF** | Ngăn nhập rác số ĐTDĐ, mã Zipcode từ phía Server và Client 0.01ms. |

---

## 3. Architecture — Clean App Router Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                      Next.js Application                        │
│                                                                  │
│  ┌──── app/ (Các Giao Diện Website)──────────────────────────┐  │
│  │                                                            │  │
│  │   ┌──────────────────────┐   ┌──────────────────────┐     │  │
│  │   │  (shop) TRANG KHÁCH  │   │  (admin) TRANG RIÊNG │     │  │
│  │   │  /menu, /checkout    │   │  /dashboard, /orders │     │  │
│  │   │  /booking, /track    │   │  /reservations       │     │  │
│  │   └──────────┬───────────┘   └──────────┬───────────┘     │  │
│  │              │                          │                 │  │
│  │              ▼                          ▼                 │  │
│  │   ┌─────────────────────────────────────────────────────┐  │  │
│  │   │  SERVER ACTIONS (actions/)                          │  │  │
│  │   │  createOrderAction(), createBookingAction()         │  │  │
│  │   └─────────────────────┬───────────────────────────────┘  │  │
│  │                         │  Thực thi ngầm & Validate        │  │
│  │   ┌─────────────────────▼───────────────────────────────┐  │  │
│  │   │  SERVICES & DATABASE (lib/, prisma/schema)          │  │  │
│  │   │  Prisma Client, Resend Mailer, Delivery Math        │  │  │
│  │   └─────────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──── components/ (Các Cục UI tái sử dụng) ─────────────────┐  │
│  │  /ui (shadcn) · /features (CartSheet, CalendarWidget)     │  │
│  └────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Quy Tắc Clean Next.js**:
- DB Query (Prisma) và xử lý Giá cả bằng `Int` CHỈ xảy ra tại File `Server Action`.
- UI `Client Component` CHỈ truyền ID món ăn và Data thô qua gọi Server Action. Tuyệt đối không tính Tiền Ship/Discount trên Client.

---

## 4. Target Platforms & Views

| User | Thiết bị Hiển thị | Phạm Vi Truy Cập Màn Hình Cốt Lõi |
|--------|---------|---------|
| **Customer** | **Mobile Web (Chính)** / PC | Màn Landing (Giới thiệu), Màn `/menu` (Kéo lướt ngón tay gọi đồ), Màn `/booking` (Đặt chỗ), Màn `/track/:id` xem Ship live. |
| **Waiter** | Tablet / Desktop | **Trang Admin Riêng:** Màn Live-Status Orders Kanban, Lịch Calendar Khách Đặt Bàn trong ngày. |
| **Manager / Bếp** | iPad (Bếp) | **Trang Admin Riêng:** Màn Bếp Đơn Xếp Lốt, Check Doanh thu (`/admin/revenue`), Thay đổi Giao diện/Giá. |

---

## 5. Core Principles

1. **Law Strict Compliance (Đức)**: 
   - Không được có checkbox *"Đăng ký nhận KM"* Tick tự động sẵn.
   - Luôn kèm ID Món ăn dị ứng (A, F, G). Footer luôn gắn Impressum và Datenschutzerklärung.
   - Nút cuối checkout Đặt món bắt buộc tên là *"Zahlungspflichtig bestellen"*.
2. **Double Opt-In Anti-Spam (Booking)**: Không cấp giữ chỗ ngay ở Đức để trừ đi Bot/Spam cướp bàn. Confirm Email bắt buộc.
3. **Integer Currency (`Int`)**: Database không lưu giá tiền `Euro` với kiểu Float (`12.99`). Phải lưu thành Tiền Cents kiểu Int (`1299`). Tránh mọi trường hợp Lỗi Cộng Dồn Dấu Phẩy Động trong E-Commerce.
4. **Zustand Offline First**: Giỏ hàng (Menu Cart) phải lưu ở Trình Duyệt Local. Khách tắt Website mở lại, Giỏ phải còn số Lượng món y nguyên để không mất doanh thu mỏ lỡ.

---

## 6. Feature Catalog (10 Functional Modules)

| # | Feature Target | Nhiệm Vụ Modun | Priority |
|---|-----------|--------|----------|
| 1 | `menu-catalog`| Build Catalog Đồ Ăn, Phân Tab, Render Client Mượt. | 🔴 P0 |
| 2 | `shopping-cart`| Hook Zustand. Bơm/Bớt/Xoá Sản Phẩm. Badge Giỏ Hàng. | 🔴 P0 |
| 3 | `checkout-calc`| Module Tính Phí Ship: Quét Map Zipcode. Tính Toán SubTotal, Thuế. | 🔴 P0 |
| 4 | `booking-form`| React Calendar Chọn Lịch. Action Query Count Capacity Database. | 🔴 P0 |
| 5 | `kanban-orders`| Admin Action. Kéo Thả Trạng thái. Websocket/Poll Đơn Nhập Bếp Mới. | 🔴 P0 |
| 6 | `calendar-booking`| View Lịch Booking Cho Lễ Tân. Huỷ Form. Xác Thực Bàn Đến Ăn. | 🔴 P0 |
| 7 | `auth-staff` | NextAuth Login Dành Riêng Admin Dashboard (Hash BCrypt). | 🟡 P1 |
| 8 | `email-resend`| React Email Template Hóa Đơn & Xác Nhận Đặt Bàn Double Optin. | 🟡 P1 |
| 9 | `tracking-live`| Routing Trang Track-order theo UUID Giấu Hành Tung Khách. | 🟡 P1 |
| 10| `content-seo` | Gen Sitemap Nhà Hàng. Render Pop-up Cookie DSGVO, Impressum Text. | 🟢 P2 |

---

## 7. Development Phases

| Phase | Scope Giai Đoạn | Các Action Chính |
|-------|-------|----------|
| **Phase 1** | **Base Scaffold & UI** | - `npx create-next-app` & Cài Shadcn/Zustand. <br>- Vẽ 3 Grid Layout chính (Menu Grid, Cart Sidebar, Booking Wizard). |
| **Phase 2** | **Prisma & Store Engine**| - Deploy PostgresQL & Push Prisma Schema 4 Object Chính (Users, Booking, Order, MenuItem). <br>- Viết Logic Zustand Cart Local. |
| **Phase 3** | **Checkout & Logic** | - Dựng Luồng Đặt Bàn (Check Database Rỗng) và E-Commerce Checkout Địa chỉ Khách Đặt Đi. <br>- Xử Lý Steuern (V.A.T) & Zipcode Phí Ship bằng Zod. |
| **Phase 4** | **Admin Terminal** | - Login Auth Staff. Kanban Màn ngang cho Tablet (Trang Bếp Mới Gọi/Đang Nấu). Lịch Calendar Lễ Tân. |
| **Phase 5** | **Mail & Track Polish**| - Dán Chìa Khoá `resend.com` Gọi API Thư điện tử kèm Layout React Mã Trơn. Dựng UI Track Order Live Khách. Xong. |

---

## 8. Document Index

Kho Tàng Kế Hoạch Đã Được Chia Thể Chất Vô Cùng Cân Kiện ở 20 File Nhỏ Sau Đây:

**A. Core & System**
| Mã | Nội dung Tài Liệu (Markdown) |
|---|---------|
| `00-overview.md` | Bản Tổng Quan Vĩ Mô (Văn bản bạn đang đọc) |
| `01a-app-router-structure.md` | Định Nghĩa Sống Còn của Route Nhóm `(shop)` vs `(admin)` |
| `01b-server-actions.md` | Cấu Hình React 19 State & Móc Action Giao Xử Trực Tiếp Database |
| `01c-ui-shadcn-tailwind.md`| Token Design CSS, Atomic Form Components Chọn Bố Cục Chuyên Sang Trọng |

**B. Database Layer (Postgres Prisma)**
| Mã | Nội dung Tài Liệu (Markdown) |
|---|---------|
| `02a-schema-users.md` | Quản Trị Cấu Hình User (Cho Manager/Bếp) Role-Based |
| `02b-schema-booking.md` | Thuộc tính CSDL Đặt Bàn Số người, DSGVO Consent, Ngày Giờ Lịch |
| `02c-schema-menu.md` | CSDL Cấu Trúc Nhóm Ăn, Món, Chất Phụ Gia, Giá Dạng Integer Cents |
| `02d-schema-orders.md` | CSDL Siêu Bảng Hóa Đơn Trạng Thái Nấu Ship, Total Cents, Zipcode Giao Hàng |

**C. Business Logic: Booking (Máy Chủ Đặt Bàn)**
| Mã | Nội dung Tài Liệu (Markdown) |
|---|---------|
| `03a-booking-capacity-engine.md` | Giải Thuật Tính Capacity Rảnh/Đầy Tại Khung Giờ Booking Đặt Cược |
| `03b-booking-double-opt-in.md` | Quy chuẩn Mail 2 Chiều Gửi Magic Link Confirm UUID |
| `03c-booking-dsgvo.md` | CheckBox Validation Khắc Nghiệt Cho Form Bằng Zod |

**D. Business Logic: Online Ordering (Ecommerce Nhỏ)**
| Mã | Nội dung Tài Liệu (Markdown) |
|---|---------|
| `04a-ordering-cart-zustand.md`| State Store Local Persist (Lưu Trình Duyệt Bất Tử) Cho Món Khách Cho Vào Giỏ |
| `04b-ordering-zipcode-validation.md`| Lọc Bán Kính / Bưu Điện (Zipcode DE) Tính Ra Bảng Quãng Tiền Ship Cụ Thể Từng Vùng |
| `04c-ordering-checkout.md` | Bốc Form Đặt Hàng Trả Tiền Mặt / Cửa Quẹt Thẻ Stripe Trả Cổng |

**E. CMS & Tracking (Nội Bo Administrations)**
| Mã | Nội dung Tài Liệu (Markdown) |
|---|---------|
| `05a-admin-kanban-board.md` | Code Màn Hình iPad Xếp Cột Kéo Đơn Hàng Neu -> Fertig Tốc Độ Cao |
| `05b-admin-rbac.md` | Bức Tường Lửa Middleware Nextjs Bảo Vệ 100% Cổng Không Có Quyền Thì Cấm Xem Báo Cáo |
| `05c-admin-table-reservations.md`| View Khảo Sát Tình Hình Khách Tại Quán Timeline Bar Chart Thẳng Tắp |

**F. Compliance (Đức) & Notification**
| Mã | Nội dung Tài Liệu (Markdown) |
|---|---------|
| `06a-compliance-dsgvo.md` | Ấn Chỉ Impressum Tối Cao & Luật Banner Đồng Ý Cookie Check Chuẩn Mực Âu |
| `06b-compliance-allergens.md` | Hiển Thị PopUp Của Từng Nút Ràng Cột Tên Món Di Ứng (A, F, L..) LMIV Pháp Trạng |
| `06c-email-live-tracking.md` | Code Mẫu Layout Thư React Components Bắn Qua Resend API Và Trang Báo Giao Đơn Live Action |
