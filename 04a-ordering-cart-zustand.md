# 04A - E-Commerce: Zustand Local Shopping Cart

> Lưu Giỏ Đồ ăn trong Trình duyệt người dùng mượt như Shopee. Không fetch Database lúc add đồ vào giỏ.

---

## 1. Store Setup (Zustand + Persist)

Chúng ta không muốn user Reload trang F5 bị mất các dĩa Cơm Chiên trong giỏ. Sử dụng Store Zustand.

```ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

type StoreType = {
  cart: OrderItem[];
  addToCart: (item: OrderItem) => void;
  removeFromCart: (id: string) => void;
  clear: () => void;
}

export const useCartStore = create<StoreType>()(
  persist(
    (set) => ({
      cart: [],
      addToCart: (item) => set((state) => {
        // Find trùng -> ++Quantity, không trùng thì Tống item mới vào.
      }),
      clear: () => set({ cart: [] }),
    }),
    { name: "restaurant-food-cart" } // Save tự động vô window.localStorage
  )
)
```

## 2. Shopping Cart Sheet (Mobile)
- Biểu tượng Giỏ hàng nằm ở Góc trên cùng (Badge số 2 đỏ chót).
- Khi bấm, một `Sheet` (Dạng Pop-up trượt ngang của Shadcn) phi từ mép màn hình phải vào giữa màn.
- Hiển thị list Món + `Subtotal Cents`. Nút bấm to đùng chà bá: `"Zur Kasse gehen"` (Thanh Toán).
