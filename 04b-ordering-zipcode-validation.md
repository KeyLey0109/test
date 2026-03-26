# 04B - Delivery: Zipcode Validation (Kiểm duyệt Khu Vực Ship)

> Không thể ship đồ từ trung tâm Berlin lên tận Hamburg. Đây là trái tim của tính ship đồ nhà hàng.

---

## 1. Cơ chế Zipcode Bán Kính
Mỗi mã vùng Bưu điện ở Đức có 5 số (PLZ). Ví dụ: `10115`, `10405`. Cần phân Loại phí ship theo PLZ.

### Cấu Hình Vùng Của Quán (Admin Settings)
```ts
const DeliveryZones = {
  "10115": { feeCents: 0, minOrderCents: 1500 }, // Rất gần quán, Freeship, Hóa đơn > 15€ mới giao.
  "10405": { feeCents: 200, minOrderCents: 2000 }, // Giao khu kế bên, Phí 2€
  "10555": { feeCents: 500, minOrderCents: 4500 } // Xa, Phí ship 5€, bill phải 45€ mới bõ công.
}
```

## 2. Server Action Flow Của Checkout
Khách khi nhập Form địa chỉ có dòng "Postleitzahl" (Zipcode). Khi Form Validation Zod kiểm tra:

```ts
function validateDelivery(zipcode: string, currentTotal: number) {
  const zone = DeliveryZones[zipcode];
  if (!zone) {
    throw Error("Tut uns leid, wir liefern aktuell nicht in dieses Gebiet."); 
    // "Sorry ko ship chỗ này" -> Chặn nút Thanh toán của khách
  }
  if (currentTotal < zone.minOrderCents) {
    throw Error(`Mindestbestellwert für deine PLZ liegt bei ${(zone.minOrderCents/100).toFixed(2)}€`);
    // "Thiếu tiền để freeship" -> Chặn
  }
  return zone.feeCents; // Cấp tiền ship cuối.
}
```
Lợi Ích: Tránh việc khách order đồ 5€, nhưng quán đạp xe vượt bão tuyết 10km đi giao. Mất trắng tiền công.
