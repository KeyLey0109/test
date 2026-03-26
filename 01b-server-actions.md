# 01B - Server Actions & State Management

> Tối ưu hoá luồng xử lý Data không cẩn viết API Route (Fetch).

---

## 1. Khái niệm Server Actions
Trong Next.js 15, thư mục `actions/` chứa các functions chạy trực tiếp trên Server của Node.js:

```ts
"use server"
// actions/booking.ts
export async function createBooking(formData: FormData) { ... }
```

Thay vì gọi `axios.post('/api/booking', payload)`, giao diện gọi trực tiếp: `const res = await createBooking(data)`.

## 2. State Management (Client)
Giỏ hàng (Cart) cần hoạt động trơn tru lúc khách Offline hoặc lướt Web.

- **Stack**: Zustand
- **Tính năng**: Middleware `persist` (tự động save vào LocalStorage).
- **Phạm vi**: Chỉ sử dụng trong Group `(shop)`. Không cần dùng bên `(admin)` vì Admin lấy dữ liệu Live từ Database chứ không có giỏ hàng.

## 3. React 19 Hooks
- Dùng `useActionState` để theo dõi Loading, Error message từ Server Action trả về.
- Dùng `useFormStatus` cho nút Submit Đặt Bàn chống Double Click. (Tránh khách Click "Đặt" 2 lần sinh ra 2 Booking).
