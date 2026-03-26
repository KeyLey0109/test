# 06A - Compliance: DSGVO & Impressum (Quy Chuẩn Pháp Luật Đức Siêu Cứng)

> Ở Mỹ bạn build tuỳ ý, nhưng ở Đức, Impressum mà giấu thì bạn cầm chắc Giấy Phạt Hàng Nghìn Euro Kèm Cảnh Sát Đập Cửa.

---

## 1. Impressum (Thông Tin Bắt Buộc)

Chúng ta luôn phải có Link `Nhàhàng.de/impressum` hoặc Footer `Nhàhàng.de`. Footer này nằm hẵn ở **tất cả** Layout Khách (Shop) và cả Layout Hóa đơn (In Biên Lai / Hóa đơn mail).

- Tên Công Ty / Chủ cá nhân (Inhaber).
- Địa chỉ Đăng ký kinh doanh.
- Email, Số Điện Thoại Quán (Không được thiếu Số Hotline).
- Steuer-Nummer (Mã số thuế) HOẶC USt-IdNr (Mã Thuế Giá Trị Gia Tăng).
- Tên Cơ Quan Giám Sát Kinh Doanh (Gewerbeamt - ở vài trường hợp).

Mục này Code thành một Thành phần Tĩnh Tái Sử Dụng Hoàn Hảo (Next.js Static Component).

## 2. Cookie Consent Banner (Pop-up Theo Dõi)

Nếu Bạn KHÔNG DÙNG Google Analytics / Facebook Pixel / Ghi âm User Hotjar -> Bạn không cần Bật Banner Cookie Rác này. Quán nhỏ thường không cần.

Nếu DÙNG (Để đo chuyển đổi chạy Ads):
- Cấm để Next.js load script Google. Phải load thư viện `cookie-consent` ra màn hình, nút bấm: `"Ablehnen" (Từ chối)` VÀ `"Akzeptieren" (Đồng Ý)`. (Chữ Ablehnen và Đồng ý phải to, rõ đều nhau theo phán quyết mới).
- Chỉ khi State == "Đồng ý", Script `<GoogleTagManager>` mới được kích hoạt chạy ở thẻ Header (Next.js Script Component).

## 3. Form Rào Chắn (DSGVO Checkbox)

Lỗi nặng nhất của Thợ Coder là làm Checkbox Check sẵn dấu V, người Việt Lười ấn để cho khách tiện đi luôn. EU Đập Phạt Rất Nặng nếu `defaultChecked = true`.
=> Validation Zod ép: Khách ấn tay `(Checkbox click)` mới mở nút Trả Tiền Checkout/Thanh toán. Kể cả luồng Đặt Món và Đặt Bàn.
