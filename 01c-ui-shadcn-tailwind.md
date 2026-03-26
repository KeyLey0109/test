# 01C - UI System (Shadcn + TailwindCSS)

> Kiến tạo UI chuẩn xác, thanh lịch và khả năng Tuỳ biến (Customize) mạnh mẽ.

---

## 1. Tại sao là Shadcn UI?
Shadcn không phải thư viện cài qua NPM (như Material UI). Components được cài trực tiếp thành Source Code (vào thư mục `components/ui`). Lợi ích:
- Dễ dàng sửa đổi CSS thuần tuý cho phù hợp bộ nhận diện Thương hiệu (Màu nhà hàng, Font chữ).
- Rất nhẹ vì chỉ import những cái gì thực sự dùng.

## 2. Design Tokens (CSS Variables)

Cấu hình bộ HSL colors trong `globals.css`:
```css
:root {
  --primary: 25 100% 50%; /* Màu Cam / Nâu của nhà hàng */
  --secondary: ...
  --background: 0 0% 100%;
}
.dark {
  /* Hỗ trợ Dark Mode tự động */
}
```

## 3. Components Nguyên Tử (Atomic Setup)
Danh sách cài hạt nhân cho Form Đặt món & Đặt bàn:
- `Button` (Nút)
- `Input`, `Textarea`
- `Dialog` / `Sheet` (Popup giỏ hàng vuốt từ dưới lên trên Mobile)
- `Calendar` / `Popover` (Bộ chọn ngày giờ)
- `Toast` / `Sonner` (Thông báo Pop-up: "Order thành công!")

## 4. Typography (Font)
Nhà hàng Đức thường theo style Premium:
- Headings: `Playfair Display` hoặc `Cinzel`.
- Body Text: `Inter` hoặc `Roboto`.
Cấu hình trực tiếp trong `tailwind.config.ts`. (Sử dụng `next/font/google` chống Layout Shift).
