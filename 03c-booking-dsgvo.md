# 03C - Booking: Consent & DSGVO Form

> Trọng tâm Pháp lý ở EU, áp dụng cho Shadcn React Hook Form.

---

## 1. Thiết Kế Form Đặt Bàn (Zod)

Chúng ta dùng `zod` để ép chuẩn nhập liệu trực tiếp không khoan nhượng. Không cần code IF-ELSE dài dòng.

```ts
import { z } from "zod";

export const bookingSchema = z.object({
  contactName: z.string().min(2, "Name ist zu kurz"), // Tóm cổ input ngắn
  contactEmail: z.string().email("Ungültige E-Mail"), // Tóm cổ email sai form
  contactPhone: z.string().optional(),
  
  partySize: z.number().min(1).max(20), // Quá 20 người bắt gọi đt cho quán
  
  // LUẬT ĐỨC BẮT BUỘC CHECKBOX DSGVO NÀY:
  dsgvoConsent: z.boolean().refine(val => val === true, {
    message: "Sie müssen der Datenschutzerklärung zustimmen."
  })
});
```

## 2. Render Checkbox Nhạy Cảm (DSGVO)
UI render của Form bắt buộc tách riêng Checkbox xác nhận ra nằm sát dòng *"Zahlungspflichtig"*. 
Chữ trong Checkbox có Text Link:
`<Link href="/datenschutz">Datenschutzerklärung</Link>`. Client ấn vào phải nhảy ra Privacy Policy.

*Lưu ý: Không bao giờ được đặt check sẵn (defaultChecked = true) vì EU Cấm.*
