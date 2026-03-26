# 05B - Admin: Phân Quyền Nhân Sự (RBAC)

> Bảo mật chức năng, ai làm gì được cấp phép rạch ròi. Tích hợp thông qua JWT Token của NextAuth v5.

---

## 1. Cơ Chế Roles

```ts
enum Role {
  WAITER, // Nhân viên chạy bàn
  COOK,   // Bếp
  ADMIN   // Ông Chủ Quán / Kế Toán
}
```

## 2. Các Giới Hạn Cụ Thể

1. **WAITER (Nhân viên phục vụ/lễ tân)**: Đăng nhập được vào `/admin/live-orders` và `/admin/reservations`. Không được xoá món ăn. Không được hủy đơn (Cancel Order), không được mở Báo cáo tài chính (Dashboard Revenue). Chỉ được thao tác Trạng Thái (Kéo thả Kanban).
2. **COOK (Nhà bếp)**: Đăng nhập được giao diện iPad nằm ở phía trong bếp `admin/kitchen-display`. Cấm nhìn thông tin Nhận tiền, Địa chỉ, Số điện thoại Khách (Chỉ có tên Món Ăn/Yêu cầu làm ngọt hay nhạt). (Đây gọi là Tách bạch Dữ liệu theo Privacy - Need-to-know basic).
3. **ADMIN**: Mở mọi cấm kị. Mở Quản lý Danh mục Món (Thêm phở, bớt miến). Thấy tất cả User. Checkout Dashboard Thống Kê (E-charts).

## 3. Middleware Next.js Bảo Vệ (Guards)

Sử dụng Middleware mạnh vô hạn của Next.js, viết file `middleware.ts`. Cứ người nào không có token Login (Null) mà cố đấm ăn xôi mò gõ URL `/admin/...` sẽ bị Next.js Server tự động đạp văng ra: `/login`. Không render bất kì một file HTML nào cho xem. Cực kì An Toàn và Dứt Khoát.
