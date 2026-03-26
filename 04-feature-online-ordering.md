# Feature: Đặt Món Trực Tuyến (Online Delivery & Pickup)

> Biến Website thành App giao đồ ăn (E-commerce Mini) chuyên nghiệp. Khách có thể xem Menu, lọc phân loại, cho vào Giỏ, và checkout tận nhà.

---

## 1. Cấu trúc UI Menu (Thực Đơn Thông Minh)

1. **Hiển thị Categories (Sticky Tabs)**
   - Cột trái hoặc Tab cuộn ngang trên Mobile: Vorspeisen (Khai vị), Hauptgerichte (Món chính), Trinken (Đồ uống).
   - Click vào Tab, tự động trượt (Smooth Scroll) tới nhóm Món ăn tương ứng.
2. **Allergen (Chất dị ứng) DE Law**
   - Theo luật nhà hàng Đức, tên món phải nhúng kèm ký hiệu dị ứng nhỏ. 
   - VD: `Pho Bo (A, F, G)     12.50€`.
3. **Thêm vào giỏ (Add to Cart)**
   - Khách thấy món -> Bấm [+] -> Một Bottom Sheet/Dialog Shadcn bật lên.
   - Form yêu cầu khách muốn cấu hình gì thêm? (Ví dụ: Thêm thịt +2€, Cay ít, Không hành).

## 2. Quản lý Giỏ Hàng (Zustand Local Storage)

Sử dụng `Zustand`. Giỏ hàng chỉ tồn tại trong máy khách (Trình duyệt) cho đến lúc Checkout.

```ts
interface CartState {
  items: CartItem[];
  addToCart: (item: CartItem) => void;
  removeFromCart: (id: string) => void;
  clearCart: () => void;
  cartTotal: () => number;
}
```
- Khi user add món, ICON Giỏ Hàng ở góc trên màn hình Website nảy (Bounce animation) và xuất hiện số lượng (Badge count). Giống hệt UX của Shopee/Lieferando.

## 3. Luồng Checkout (Delivery & Pickup)

Ngay khi vào trang `/checkout`, User được chọn 1 trong 2 Tab: **ABHOLUNG (Pickup)** hoặc **LIEFERUNG (Delivery)**.

### Tab: Abholung (Đến lấy)
- Nhập Tên, Điện thoại.
- Chọn giờ đến lấy. (Select Box hiển thị khoảng giờ. Ví dụ "Asap" (Nhanh nhất có thể), hoặc "18:00").

### Tab: Lieferung (Giao hàng)
Đây là phần khó nhất:
1. **Kiểm tra khu vực giao hàng (Zipcode / PLZ Validator)**
   - Chủ quán cài trước trong Admin: *"Tôi chỉ giao cho PLZ 10115, 10117 (Trung tâm Berlin), và tối thiểu (Mindestbestellwert) phải 20€."*
   - Nếu Khách nhập PLZ khác -> Hệ thống báo lỗi Alert đỏ: *"Rất tiếc chúng tôi chưa mờ dịch vụ tới PLZ của bạn."* Chặn Checkout.
2. **Tính Phí Ship (Lieferkosten)**
   - Có thể cấu hình Order < 30€: Phí ship 2€. Dưới 20€ không giao. Trên 30€ free ship.
3. **Nhập địa chỉ nhà** (Đường, số nhà, tầng, ghi chú chuông cửa).

## 4. Thanh Toán (Stripe & Cash)

- **Thanh toán tiền mặt / Thẻ tận nơi (Bar / EC-Karte)**: Phổ biến nhất ở Đức. Khách trả khi nhận hàng.
- **Online (Stripe)**: Bật tích hợp Stripe React. Khách quẹt Credit Card, Apple Pay, PayPal trực tiếp trên Web. 
- Nhấn *Zahlungspflichtig bestellen* -> Order bay vút về Database, bắn Event cho Admin hiển thị. Màn hình tự nhảy qua trang "Cảm ơn & Link Tracking Đơn Hàng" (Sẽ kết hợp Gửi Email ở File `06`).
