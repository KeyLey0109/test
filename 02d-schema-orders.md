# 02D - Database Schema: Orders & Delivery

> Trung tâm lưu trữ Đơn Vận Giao Nhận và Trạng Thái Bếp.

---

## 1. Schema Cốt Lõi (Đơn hàng)

Nó đóng vai trò như Bill (Hóa đơn) trong hệ thống POS.

```prisma
model Order {
  id              String   @id @default(uuid()) // Tracking ID Send to Email
  
  contactName     String
  contactEmail    String
  contactPhone    String

  orderType       OrderType     // PICKUP (Lấy) hoặc DELIVERY (Ship)
  status          OrderStatus   @default(RECEIVED)
  paymentStatus   PaymentStatus @default(PENDING) 
  paymentMethod   PaymentMethod // CASH, CARD_ONLINE, PAYPAL

  // Chỉ dành cho Giao Hàng (DELIVERY)
  deliveryAddress String?
  deliveryZip     String?
  deliveryCity    String?

  // Yêu cầu thời gian mong muốn của KH
  scheduledTime   String?      // VD: "Càng nhanh càng tốt" hoặc "19:00"

  // Tiền tệ
  subTotalCents   Int          // Tiền đồ ăn
  deliveryFeeCents Int         // Phí ship (VD: 200 = 2.00€)
  totalAmountCents Int         // Tổng

  items           OrderItem[]
  createdAt       DateTime @default(now())
}

enum OrderType { PICKUP, DELIVERY }

enum OrderStatus {
  RECEIVED     // Nhà hàng mới nhận
  COOKING      // Đang nấu
  READY        // Đã nấu xong, chờ lấy/chờ Ship
  IN_TRANSIT   // Đang giao trên đường (Chỉ dùng cho Delivery)
  COMPLETED    // Khách đã nhận đồ
  CANCELLED
}

enum PaymentStatus { PENDING, PAID, REFUNDED }
enum PaymentMethod { CASH, ONLINE_CARD, EC_BAR }

// Clone Data (Đóng băng món lúc gọi, đề phòng admin đổi giá)
model OrderItem {
  id         String   @id @default(uuid())
  orderId    String
  order      Order    @relation(fields: [orderId], references: [id])
  
  menuItemId String
  name       String   // Copy tên món lúc khách ấn Order
  quantity   Int
  priceCents Int      // Giá lịch sử lúc gọi món
}
```

## 2. Liên Kết Status (Live Tracking)
Trường `status` bên trên là chìa khoá cho trang Live Tracking (`06d`). Khi Admin đổi status `RECEIVED` -> `COOKING`, màn hình tracking của khách cũng đi theo Mốc số 2.
