# 06B - Compliance: Allergens & Additives (Dị Ứng)

> Đây Là Cứu Tinh Cho Việc Bạn Bị Kiện (10 Triệu Euro) Nếu Bạn Phục Vụ Đậu Phộng Cho Khách Dị Ứng Tử Vong.

---

## 1. Quy Trình Giao Diện Món Ăn Trong Next.js Của Khách

Tại Màn hình Menu (Shop) `/menu`. Món Ăn BẮT BUỘC hiện: 
- `Spaghetti Carbonara (A, C, G)`

Nhiều khách không hiểu (A, C, G) là gì, bạn cần có Tooltip (Dấu Chấm Hỏi - Hover Của Shadcn / Hoặc Nút Click giải thích). Hoặc 1 trang `/allergene` cắt nghĩa. Trong dự án Web này, ta dùng Tooltip:
- Khách dùng Máy Tính: Rê Chuột qua chữ A -> Hiện Chữ (Lúa mì/Gluten).
- Khách dùng Điện Thoại: Chạm ngón tay vào chữ A -> Pop over nhảy lên (Lúa mì/Gluten). Cực kỳ tiện.

## 2. Bảng Xếp Hạng Chức Danh Dị Ứng Cực Chuẩn Lưu Database

Admin Quán (Chủ) điền trường Mảng Text `[A, B, D]` trong Database `MenuItem` của Prisma.

```ts
const ALLERGEN_MAP = {
  A: "Glutenhaltiges Getreide (Lúa mì, lúa mạch...)",
  B: "Krebstiere (Động vật giáp xác / Tôm Cua)",
  C: "Eier (Trứng)",
  D: "Fische (Cá)",
  E: "Erdnüsse (Đậu Phộng)",
  F: "Sojabohnen (Đậu nành)",
  G: "Milch (Sữa bò / Sữa chứa Lactose)",
  H: "Schalenfrüchte (Hạt cứng dạng quả hoạch: Hạnh nhân, chà là)",
  L: "Sellerie (Cần tây)",
  M: "Senf (Mù tạc)",
  N: "Sesamsamen (Hạt vừng)",
  O: "Schwefeldioxid & Sulfite (Chất bảo quản lưu huỳnh SO2)",
  P: "Lupinen (Đậu Lupin)",
  R: "Weichtiere (Nhuyễn thể / Bạch tuộc / Nghêu Sò)"
};
```

## 3. Zusatzstoffe (Chất Phụ Gia) Bằng Số Tiếng Đức

Đi cạnh Chữ (Dị ứng), thường phải đi kèm Số (Phụ gia).
Ví dụ Xúc xích Đức (Currywurst) có Chất Bảo quản `(2)` và Phụ màu `(1)`. Thơm ngon nhưng không tốt. Nên Menu hiện: `Currywurst (1, 2)`.

Quy Định Khắc Nghiệt Đã Xong!
