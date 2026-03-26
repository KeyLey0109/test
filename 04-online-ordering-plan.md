# Kế hoạch Kỹ Thuật: Chức Năng Đặt Món Trực Tuyến (Delivery & Pickup)

> **Mục tiêu**: Xây dựng module E-Commerce thu nhỏ (khách hàng tự đặt món ăn) tích hợp trực tiếp vào Next.js App Router. Phục vụ hai hình thức: **Đến Lấy (Pickup)** và **Giao Hàng (Delivery)**. 

---

## 1. Tổng Quan Luồng Người Dùng (User Flow)

**Luồng Thêm Vào Giỏ & Thanh Toán**
```text
1. Khách Hàng lướt Menu (Client Component)
   ├── Bấm "Thêm vào giỏ" -> Zustand Store cập nhật Global State (cộng dồn số lượng, tổng tiền ảo).
   └── Hiển thị Floating Badge số lượng giỏ hàng dưới góc màn hình.

2. Trạng thái Checkout Khởi Tạo
   ├── Hệ thống hỏi: "Bạn muốn Giao Hàng (Delivery) hay Đến Lấy (Pickup)?"
   ├── [Nếu Pickup]: Bỏ qua bước nhập địa chỉ. Chỉ nhập Giờ Đến Lấy & Tên/SĐT.
   └── [Nếu Delivery]: Bắt buộc nhập Zipcode (PLZ) -> Call Server Validate -> Trả về Phí Ship.

3. Tính Toán Tiền Cuối (Subtotal + Tip + Phí Ship - Discount)
   ├── Client-side truyền danh sách `CartItem(id, quantity)` lên Server Action.
   └── Server lấy giá chuẩn từ Database DB tính lại (tránh hack giá ở LocalStorage).

4. Thanh Toán (Payment & Complete)
   ├── Trả Tiền Mặt lúc nhận (Bar/EC): Tạo Order trạng thái [NEW] -> Gửi Email -> Xong.
   └── Trả Thẻ (Stripe): Redirect qua 1-click Checkout -> Webhook trả Status [PAID] -> Xong.
```

---

## 2. Quản Lý Trạng Thái Khách Cục Bộ (State Management)

Dùng **Zustand** cùng middleware `persist` để giữ Cart không bị trôi khi f5 trang.

### Zustand Store Structure
```typescript
interface CartItem {
  menuItemId: string;
  name: string;
  price: number; // Lưu dạng Cent (VD: 1290 = 12.90€)
  quantity: number;
  extras?: string[]; // ID các Option thêm (Vd: Thêm phô mai, cay...)
}

interface CartState {
  items: CartItem[];
  orderType: 'delivery' | 'pickup' | null;
  customerZipcode: string | null;
  
  // Actions
  addItem: (item: CartItem) => void;
  removeItem: (itemId: string) => void;
  setOrderType: (type: 'delivery' | 'pickup') => void;
  clearCart: () => void;
}
```

**Quy tắc ngầm**: 
Chỉ dùng Zustand để chạy UI phản hồi nhanh. Bất cứ khi nào Khách nhấn sang bước "Xác nhận đơn", toàn bộ Object `items` này phải đưa lên `Server Action` kiểm duyệt chéo.

---

## 3. Quản Lý Thuế Steuern & Giao Hàng (Zipcode Math)

Đức có luật Steuern quy định Thuế VAT khác nhau:
- Ăn tại quán: 19% MwSt.
- Mua mang về (Delivery / Pickup): 7% MwSt.

Vì module này là Online Ordering, mức thuế mặc định trong hóa đơn PDF phải tính là **7%**.

### Khớp Bán Kính Giao Hàng (Zipcode Validation)
Nhà hàng chỉ giao cho một số mã bưu điện nhất định. Cần tạo 1 mảng tĩnh (hoặc lôi trực tiếp từ Settings Database):
```typescript
// map-delivery.ts
export const DELIVERY_ZONES = [
  { zip: "10115", minOrder: 1500, fee: 200 }, // Cents (15€ min, 2€ ship)
  { zip: "10117", minOrder: 2000, fee: 350 },
  { zip: "10119", minOrder: 3000, fee: 0 }    // Đặt > 30€ freeship
];
```

**Thuật toán chặn Zipcode**:
- Nếu `orderType === 'delivery'` -> Validate `Form (Zipcode)` với Data Array trên.
- Nếu Không tồn tại Zip -> Báo lỗi rực đỏ: *"Xin lỗi, chúng tôi chưa nhận giao đến khu vực của bạn."*

---

## 4. Xử Lý Giao Dịch Bằng Server Action (Bảo Mật)

Bức tường an toàn nhất của dự án là không lưu bất kỳ tiền mặt nào gửi từ Client mà không tính lại.

1. **Client gửi**: `[{ id: 'item_1', qty: 2 }]` & thông tin `Delivery Address`.
2. **Server Action `createOrder(data)`**:
   - `SELECT price FROM Menu WHERE id IN ('item_1')`
   - Tính TỔNG: `(Price * qty) = SubTotal`
   - Tính SHIP: Tìm Zipcode trong `DELIVERY_ZONES` -> Check `SubTotal >= minOrder`? Cộng Phí Ship : Báo lỗi Min Order chưa đủ.
   - Insert Database: Tạo bảng Orders + OrderItems. Trả về `orderId`.

---

## 5. Prisma Schema (Khuôn Số Liệu Đơn Nhanh)

Đề xuất Schema cho DB chứa thông tin Đơn món ăn:

```prisma
model Order {
  id              String   @id @default(cuid())
  orderNumber     Int      @unique @default(autoincrement()) // Dùng in hóa đơn ngắn (VD: #1004)
  
  // Phân loại: pickup, delivery
  orderType       String   
  
  // Tiền tệ CENTS, Int
  subTotal        Int      
  deliveryFee     Int      @default(0)
  totalAmount     Int      // subTotal + deliveryFee
  
  // Trạng thái đơn (NEW -> PREPARING -> READY -> COMPLETED)
  status          String   @default("NEW")
  
  // Thông tin giao nhận khách hàng
  customerName    String
  customerPhone   String
  customerEmail   String
  customerAddress String?  // NULL nếu là Pickup
  zipcode         String?  
  
  // Thời gian đặt
  requestedTime   DateTime? // Lúc khách muốn nhận (VD: Lúc 19h00)
  createdAt       DateTime  @default(now())

  // Mối quan hệ
  items           OrderItem[]
}

model OrderItem {
  id          String   @id @default(cuid())
  orderId     String
  menuItemId  String
  name        String   // Lưu snapshot tên đề phòng Menu đổi tên sau này
  priceCents  Int      // Lưu snapshot giá hiện tại lúc khách mua
  quantity    Int
  
  order       Order    @relation(fields: [orderId], references: [id], onDelete: Cascade)
}
```

---

## 6. Các Quyết Định Hoạch Định Tiếp Theo
- [ ] Tính năng chọn thời gian nhận hàng (VD: Lấy "Càng Sớm Càng Tốt" vs Đặt hàng trước nhận lúc 19:30).
- [ ] Gửi Email Hóa Đơn (PDF hoặc mã HTML resend.com đẹp) cho khách.
- [ ] Chức năng thanh toán có cần móc thẳng Stripe ở phiên bản V1 không hay chỉ trả tiền mặt (CASH)?
