# Tầng Dữ Liệu & Prisma Schema (Database Layer)

> Nền tảng sử dụng PostgreSQL kết nối qua Prisma ORM.

---

## 1. Tổng quan các Model cốt lõi

Nhà hàng Đức cần kiểm soát 3 thực thể lớn: **Users (User/Admin/Customer)**, **Bookings (Đặt Bàn)**, **Orders (Đặt món Pickup/Delivery)**.

### Model 1: User / Customer
Hệ thống cho phép khách vãng lai (Guest) tự đặt bàn/món mà không cần tạo tải khoản (thường dùng ở Đức lưu bằng Email+SĐT). Tuy nhiên Admin cần tài khoản.

```prisma
model User {
  id            String   @id @default(uuid())
  name          String?
  email         String   @unique
  passwordHash  String?  // Admin/Staff login
  role          Role     @default(CUSTOMER) // CUSTOMER, WAITER, MANAGER
  createdAt     DateTime @default(now())

  bookings      Booking[]
  orders        Order[]
}

enum Role {
  CUSTOMER
  WAITER
  MANAGER
}
```

### Model 2: Booking (Bàn đặt)
Kiểm soát Khách đặt bàn có đến hay không, số lượng người, và DSGVO.

```prisma
model Booking {
  id              String   @id @default(uuid())
  userId          String?  // Có thể null nếu là Guest, liên kết qua contactEmail
  contactName     String
  contactEmail    String
  contactPhone    String?
  
  partySize       Int      // Số lượng khách (ví dụ: 4)
  bookingDate     DateTime // Ngày khách đến (ví dụ: 2026-10-15)
  bookingTime     String   // Giờ đến (ví dụ: 19:30)
  
  dsgvoConsent    Boolean  // (Luật Đức) Bắt buộc true: Đồng ý xử lý dữ liệu

  status          BookingStatus @default(PENDING) // PENDING, CONFIRMED, CANCELLED, COMPLETED
  specialRequests String?

  createdAt       DateTime @default(now())
}

enum BookingStatus {
  PENDING    // Đợi xác nhận Double Opt-in hoặc Admin duyệt
  CONFIRMED  // Đã xác nhận giữ bàn
  CANCELLED  // Khách hoặc Admin hủy
  COMPLETED  // Khách đã đến dùng bữa xong
}
```

### Model 3: Catalog (Món ăn & Danh mục)
Món ăn của Đức/Việt, có các yếu tố Luật Đức như Allergen (chất dị ứng).

```prisma
model Category {
  id       String     @id @default(uuid())
  name     String     // Ví dụ: Vorspeisen, Hauptgerichte...
  items    MenuItem[]
}

model MenuItem {
  id          String   @id @default(uuid())
  categoryId  String
  category    Category @relation(fields: [categoryId], references: [id])
  
  name        String   // "Pho Bo", "Currywurst"
  description String?  
  price       Int      // Lưu TIỀN CENTS. Ví dụ: 12.50€ -> lưu 1250 (Bắt buộc với Ecommerce)
  image       String?

  allergens   String[] // Ví dụ: ["A", "C", "G"] (Luật LMWMV)
  isAvailable Boolean  @default(true) // Ẩn/hiện khi hết món
}
```

### Model 4: Order (Đặt món & Track Delivery)
Một đơn đặt món tích hợp Live Tracking qua Enums.

```prisma
model Order {
  id              String   @id @default(uuid()) // Tracking ID gửi qua Mail
  contactName     String
  contactEmail    String
  contactPhone    String

  orderType       OrderType    // PICKUP, DELIVERY
  orderStatus     OrderStatus  @default(RECEIVED)
  paymentStatus   PaymentStatus @default(PENDING) // (Tiền cọc hoặc trả online)

  // Delivery Info
  deliveryAddress String?
  deliveryZip     String?
  deliveryCity    String?
  scheduledTime   String?      // Giao lúc mấy giờ? Hoặc lấy lúc mấy giờ.

  totalAmount     Int          // Tiền cents
  items           OrderItem[]

  createdAt       DateTime @default(now())
}

enum OrderType {
  PICKUP       // Khách đến quán lấy
  DELIVERY     // Quán ship đi
  // DINE_IN   // Tương lai nếu dùng iPad tại bàn
}

enum OrderStatus {
  RECEIVED     // Nhà hàng mới nhận
  COOKING      // Đang nấu
  READY        // Đã nấu xong, chờ lấy/chờ Ship
  IN_TRANSIT   // Đang giao trên đường (Chỉ dùng cho Delivery)
  COMPLETED    // Khách đã nhận
  CANCELLED
}

enum PaymentStatus {
  PENDING
  PAID
  REFUNDED
}

model OrderItem {
  id         String   @id @default(uuid())
  orderId    String
  order      Order    @relation(fields: [orderId], references: [id])
  menuItemId String
  name       String   // Copy tên món lúc đặt (để đề phòng sau này đổi tên món trên Menu)
  quantity   Int
  priceAtTime Int     // Giá lịch sử lúc đặt
}
```

## 2. Chiến lược Tối ưu DB (Tương thích Desktop & Serverless)

- Prisma tự động kiểm tra Type.
- Mọi đơn vị tiền tệ phải dùng số nguyên `Int` (Tính theo Cents). Ở Đức, 15,99€ thì lưu DB là `1599`. Khi in ra giao diện dùng Next.js Utils format format `(giá / 100).toFixed(2)` € để tránh lỗi làm tròn dấu phẩy động 0.1+0.2=0.300004.
