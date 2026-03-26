# Feature: Email & Live Tracking (Thông Báo Thời Gian Thực) & Compliance

> Giao diện tương tác với khách qua Email đẹp mắt và Trang Link Tracking Đơn hàng cực "xịn" (Như UberEats / Lieferando).

---

## 1. Hệ Thống Email Resend & React Email

Ứng dụng `React Email` để thiết kế hóa đơn. So với HTML thô ngày xưa, code bằng JSX (như React components bình thường): `<Button>`, `<Heading>`, `<Column>`. Code cực dễ mà design email lên hòm thư rất đẹp.

### Danh mục Emails:
1. **Xác nhận Order (Gửi ngay khi đặt xong)** (Khách)
   - Hoá đơn chi tiết. Tổng tiền (cả phí ship/thuế).
   - Dòng chữ: "Bấm vào Nút bên dưới để theo dõi trạng thái món ăn!"
2. **Booking Double Opt-in** (Khách)
   - Gửi ngay lúc khách ấn đặt bàn -> Yêu cầu "Xác nhận tính xác thực Email của Bajn".
3. **Xác Nhận Giữ Bàn Thành Công** (Khách)
4. **Email Huỷ (Cancellation)** (Cho cả Order & Booking)

## 2. Live Tracking Đơn Hàng (Link theo dõi đặc biệt)

**Ví dụ Link:** `restaurant.de/track/ORD-391B-XC92` (Link ẩn, không đánh Index SEO). Khách truy cập Link này:

Giao diện hiển thị:
- Progress Bar (4 Bước): `[1] Nhận Đơn ---> [2] Bếp bắt đầu nấu ---> [3] Shipper Đang giao/Bạn Có thể tới lấy ---> [4] Hoàn Tất`.
- Các Step này thay đổi màu (Mờ -> Xanh Lá) lập tức khi Admin bám Next/hoàn thành trên bảng Dashboard. (Dùng tính năng Next.js RevalidatePath hoặc Poll request mỗi 10 giây).
- (Optional): Khách nhìn thấy số tiền cần trả (Tiền mặt / Thẻ) nhắc nhở khách khi Shipper tới.

## 3. Hoàn Thành Luật Đức (German Compliance Focus)

Trọng tâm thiết kế cho web ở Châu Âu:

1. **Impressum (Footer Website bắt buộc)**
   Tên cty, Tên giám đốc, Trú sở, Mã thuế (USt-IdNr / Steuernummer). Gắn dưới chân trang Website & Trong toàn bộ các Emails gửi đi.
   
2. **DSGVO / Data Protection / Datenschutz**
   Bảo mật dữ liệu nghiêm ngặt:
   - Nếu Cookie có dùng Analytics, khi bật Web lên phải hiện Banner "Đồng ý dùng Cookie?". Nếu làm Web thuần túy ko tracking -> Không cần Cookie Banner rắc rối.
   - User Checkout bắt buộc: Tick Checkbox đồng ý cho quán dùng Address/Email để xử lý đơn hàng.

3. **Thuế (Steuer/VAT)**
   Ở Đức nhà hàng có 2 thuế:
   - 7% Food (nếu mang về / ship) - Từ 2024. Đôi lúc Dine-in là 19%.
   - 19% Đồ uống (Trinken).
   Vì vậy Hộp tính tiền (Cart Total) phải bóc tách số tiền thuế (excl VAT / incl VAT 7% / incl VAT 19%). Đây là bắt buộc nếu gửi hóa đơn thương mại.

4. **Allergen (LMIV - Luật bảo vệ Thông tin Thực Phẩm)**
   Mọi Món dưới Menu phải khai báo chữ cái tắt chất dị ứng (Chữ Tới A-P, số 1-14). 
   Hỗ trợ Footer Tooltip ghi chú (Mẫu A: Gluten, G: Sữa...). 
