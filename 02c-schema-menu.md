# 02C - Database Schema: Menu & Catalog

> Bảng thực đơn số, quản lý món ăn và chất gây dị ứng.

---

## 1. Phân Cấp: Category -> Product

```prisma
model Category {
  id          String     @id @default(cuid())
  name        String     // Vorspeisen, Hauptgerichte...
  sortOrder   Int        // Xếp hạng thứ tự hiển thị Menu
  
  menuItems   MenuItem[]
}

model MenuItem {
  id          String   @id @default(cuid())
  categoryId  String
  category    Category @relation(fields: [categoryId], references: [id])
  
  name        String   // "Pho Bo Dặc Biệt"
  description String?  // Mô tả thành phần
  
  priceCents  Int      // Tính bằng Cents. 10.50 Euro = 1050 (Int)
  image       String?  // Link URL (AWS S3 hoặc Uploadthing)

  // Liên quan đến Luật Thực Phẩm LMIV Đức
  allergens   String[] // VD: ["A", "C", "F"]
  additives   String[] // VD: ["1", "4"] (Màu thực phẩm, Phụ gia vị)

  // Trạng thái món
  isAvailable Boolean  @default(true) 
}
```

## 2. Xử lý Giá Tiền Bằng Cents (Integer)
Trong thương mại điện tử (Kể cả Stripe), 100% dòng tiền giao dịch gốc phải dùng số nguyên `INT`. Dùng Float (Dấu phẩy động) trong Database sẽ phát sinh sai số 1 Cent khi tính toán VAT 7% / 19%. 
- `priceCents = 1290` tương đương `12.90 €`. Lợi ích tuyệt đối cho Steuern (Thuế).
