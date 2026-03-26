# 04C - Checkout & Payments (Thanh Toán & Chốt Đơn)

> Luồng cuối để Cứa khách trả tiền và Xóa LocalStorage.

---

## 1. Lựa Chọn Của Khách Trả Online (Stripe - Thẻ Credit/Apple Pay)
Nếu nhà hàng muốn thu phí trước: Cài SDK `Stripe` của Next.js (Server-side module + Client Component form).
Khi khách ấn `Zahlungspflichtig bestellen` (Bắt buộc nhấn mạnh từ này vào nút Checkout Đức).
- Next.js Checkout Action sinh ra 1 link gọi là `Stripe Checkout Session URL`.
- Đẩy trình duyệt khách sang trang Thanh Toán của máy chủ Châu Âu. 
- Khách cà thẻ rẹt rẹt. Máy chủ Stripe gửi 1 webhook gõ cửa `app/api/webhook/stripe`. Code Stripe bắt đầu đổi trạng thái đơn `paymentStatus = PAID`.

## 2. Lựa Chọn Thường Xuyên Đoán Nhận Lại Nhà Bếp (Thanh toán Bar / Máy EC)
Vì Đức có tính hoài cổ, phần lớn nhà hàng vẫn thanh toán tiền mặt (Cash) hoặc thẻ Debit ngay cửa/qua tay Shipper (Bar/EC).
Trong trường hợp này, Checkout form có Radio Selection (Tiền Mặt/Thẻ lúc Nhận hàng). 
- Bấm nút là Server Action `createOrder` tạo Bill đâm thẳng vào Prisma luôn, `paymentStatus = PENDING`. Trả lại màn hình "Success!".
- Khi Waiter giao đồ cho Khách xong, Waiter tự cầm điện thoại bấm chữ "ĐÃ THU XONG TIỀN" (`paymentStatus = PAID`).

## 3. Hoàn Tất (Thắng lợi Checkout)
Ngay cả lúc Stripe hay Trả Sau kết thúc, code ở FrontEnd lập tức gọi `useCartStore.getState().clear()` để dọn dẹp Đĩa đồ thừa mứa nằm trong trình duyệt của người ta. Đẩy khách sang màn `Track ID: ORD-abc`.
