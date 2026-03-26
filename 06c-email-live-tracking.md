# 06C - Resend Email & Live Tracking System (Tinh Hoa Next.js)

> Email React Thiết Kế Quá Thanh Lịch Và Nút Xem Theo Dõi Lộ Trình Phân Đỉnh Như App Shopee / Grab.

---

## 1. Thiết Kế Email Component Bằng React Email

Thư viện: `npm install react-email @react-email/components`.
Đây là Cuộc CM Hệ Thống Nhúng Mới nhất (Viết email bằng code y hệt website nhưng nạp ra mã HTML table thô thiển 100% tuân thủ mọi inbox kể cả Microsoft Outlook 2003 Cổ Lỗ).

```tsx
import { Html, Text, Button, Container, Heading } from '@react-email/components';

export function OrderConfirmEmail({ customerName, orderId, totalCents }) {
  return (
    <Html>
      <Container>
        <Heading>Danke für deine Bestellung, {customerName}!</Heading>
        <Text>Đơn hàng của bản trị giá ${(totalCents/100).toFixed(2)}€ đã được tiếp nhận.</Text>
        
        {/* Nút bấm vĩ đại nhảy Cóc sang Website - Trải Nghiệm 5 Sao Khách Không Phải Tải App */}
        <Button href={`https://nhahangtrongoi.de/track/${orderId}`}>
          Status Verfolgen (Xem Tiến Trình Giao Hàng Live)
        </Button>
      </Container>
    </Html>
  );
}
```

## 2. Quy Trình Cập Nhật Track Đơn (Poller Hoặc Websocket Stream) Trang `/track`

Khách Bấm Mở màn `/track/[orderId]` (Khách là Anonymous, URL có chứa Mã ID Chìa Khóa Quá Khó Doán: /track/cd82-acbd-...).

Giao diện Web Khách Có Trục Ngang Progress Bar Shadcn:
- **0%** [Biểu Tượng Tay Tiếp Lệnh] -> MỚI NHẬN.
- **50%** [Biểu Tượng Ngọn Lửa] -> ĐANG TRONG BẾP.
- **100%** [Bie Tượng Tài Xế Đạp Xe] -> TÀI XẾ DIE ĐANG GIAO HOẶC KHÁCH TỚI LẤY ĐƯỢC RỒI.

Nó dùng Next.js SWR (Stale-While-Revalidate) hoặc `React Query` ping tới Action Check database nhẹ một cái (`orderStatus = ?`) mỗi 5s. Nếu Đổi thành COOKING, Màn Trình Duyệt Nhích ProgressBar Lên 50% Có Màu Nhấp Nháy Hào Quang.

Mọi Cảnh Truyện Ở Web Này Cấm Dùng Cửa Sổ Rung Lên Quá Đáng, Thanh Hiện Thông Báo Quá Phô, Chói Ló. Nên Đẹp Tinh Tế Kiểu Của Mapple/Uber. Hoàn Đảo!
