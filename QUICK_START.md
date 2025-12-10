# 🚀 QUICK START - Laviade App

## ⚡ 60 Second Setup

```bash
# 1. Navigate to project
cd d:\Codingan\Mobile\tubes\laviade_mobile

# 2. Install dependencies
flutter pub get

# 3. Run app
flutter run
```

## 📱 First Time Usage

### Test Flow:
1. **Register** → Name: "John Doe", Email: "john@example.com", Password: "123456"
2. **Login** → Use registered credentials
3. **Browse** → Swipe carousel, click products
4. **Add to Wishlist** → Click heart icon
5. **Add to Cart** → Click "Add to Cart"
6. **Checkout** → Fill form, confirm order
7. **Verify Persistence** → Restart app, still logged in

---

## 📂 Project Structure (Summary)

```
lib/
├── main.dart                 # App entry & routing
├── core/styles/theme.dart   # Design system
├── models/                   # Product, User
├── repository/               # ProductRepository
├── screens/                  # All pages
│   ├── auth/                # Login, Register
│   ├── home/                # Home + carousel
│   ├── product/             # List + Detail
│   ├── wishlist/            # Wishlist
│   ├── cart/                # Cart + Checkout
│   └── main_navigation_page # Bottom nav controller
└── widgets/                  # Reusable components
```

---

## 🎯 Key Features

✅ **Auth** - Register/Login with persistent state
✅ **Browse** - Carousel, grid view, detail page
✅ **Wishlist** - Add/remove, persistent storage
✅ **Cart** - Quantity control, total calculation
✅ **Checkout** - Form validation, cart clear
✅ **Navigation** - Bottom nav, proper routing

---

## 💾 Data Storage

- **SharedPreferences** for user data, wishlist, cart
- **Local JSON** for product data
- Auto-persist & restore on app restart

---

## 🔗 Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Routes, splash check |
| `lib/core/styles/theme.dart` | Design tokens |
| `assets/data/products.json` | Product data |
| `pubspec.yaml` | Dependencies |

---

## ✨ Testing Checklist

- [ ] Register works
- [ ] Login persists after restart
- [ ] Carousel slides
- [ ] Wishlist adds/removes
- [ ] Cart quantity works
- [ ] Checkout clears cart
- [ ] Bottom nav switches pages
- [ ] All navigation works

---

**Ready to use! Build & test immediately.** 🎉
