# Flavormula - Flutter App với Firebase Authentication

Ứng dụng Flutter với hệ thống đăng nhập/đăng ký sử dụng Firebase Authentication và Firestore, cùng với tính năng quản lý công thức nấu ăn.

## Tính năng

- ✅ Đăng ký/Đăng nhập bằng Email/Password
- ✅ Đăng nhập bằng Google
- ✅ Lưu thông tin người dùng vào Firestore
- ✅ Quản lý state với Provider
- ✅ Giao diện đẹp và responsive
- ✅ Hỗ trợ Android và iOS
- ✅ **Tạo và quản lý công thức nấu ăn**
- ✅ **Tính toán chi phí nguyên liệu**
- ✅ **Tìm kiếm công thức**

## Cấu trúc dự án

```
lib/
├── models/
│   ├── user_model.dart          # Model cho thông tin người dùng
│   └── recipe_model.dart        # Model cho công thức nấu ăn
├── providers/
│   ├── auth_provider.dart       # Provider quản lý authentication state
│   └── recipe_provider.dart     # Provider quản lý recipe state
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # Màn hình đăng nhập
│   │   ├── register_screen.dart # Màn hình đăng ký
│   │   └── forgot_password_screen.dart # Màn hình quên mật khẩu
│   ├── recipe/
│   │   ├── recipe_form_screen.dart    # Màn hình tạo/chỉnh sửa công thức
│   │   ├── recipe_list_screen.dart    # Màn hình danh sách công thức
│   │   └── recipe_detail_screen.dart  # Màn hình chi tiết công thức
│   └── home_screen.dart         # Màn hình chính
├── services/
│   ├── auth_service.dart        # Service xử lý authentication
│   └── recipe_service.dart      # Service xử lý recipes
└── main.dart                    # Entry point của ứng dụng
```

## Cài đặt

### 1. Clone dự án
```bash
git clone <repository-url>
cd app_flavormula
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Cấu hình Firebase

#### Android
- File `android/app/google-services.json` đã được cấu hình sẵn
- Đảm bảo package name trong Firebase Console khớp với `com.example.app_flavormula`

#### iOS
- File `ios/Runner/GoogleService-Info.plist` đã được cấu hình sẵn
- Bundle ID: `com.example.appFlavormula`

### 4. Chạy ứng dụng
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

## Firebase Rules

Đảm bảo Firestore Rules được cấu hình như sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /users/{userId}/recipes/{recipeId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Sử dụng

### Đăng ký tài khoản mới
1. Mở ứng dụng
2. Chọn "Đăng ký ngay"
3. Điền thông tin: Họ tên, Email, Mật khẩu
4. Nhấn "Đăng ký"

### Đăng nhập
1. Nhập Email và Mật khẩu
2. Nhấn "Đăng nhập"
3. Hoặc chọn "Đăng nhập với Google"

### Quên mật khẩu
1. Từ màn hình đăng nhập, chọn "Quên mật khẩu?"
2. Nhập email
3. Nhấn "Gửi email đặt lại mật khẩu"

### Quản lý công thức nấu ăn

#### Tạo công thức mới
1. Từ màn hình chính, chọn "Tạo công thức" hoặc nhấn nút FAB
2. Nhập tên món ăn
3. Thêm nguyên liệu:
   - Tên nguyên liệu (ví dụ: Trà, Đào, Đường)
   - Tỉ lệ (ví dụ: 20)
   - Đơn vị (ví dụ: g, ml)
   - Giá (VNĐ) (ví dụ: 100000)
   - Số lượng cơ bản (ví dụ: 100)
4. Nhấn "Lưu công thức"

#### Xem danh sách công thức
1. Từ màn hình chính, chọn "Công thức nấu ăn"
2. Xem danh sách tất cả công thức đã tạo
3. Tìm kiếm công thức bằng tên
4. Chỉnh sửa hoặc xóa công thức

#### Xem chi tiết công thức
1. Từ danh sách công thức, nhấn vào công thức muốn xem
2. Xem thông tin chi tiết:
   - Tên món ăn
   - Danh sách nguyên liệu
   - Tổng chi phí
   - Ngày tạo/cập nhật

## Cấu trúc dữ liệu

### User Model
```dart
{
  "uid": "user_id",
  "email": "user@example.com",
  "displayName": "Tên người dùng",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### Recipe Model
```dart
{
  "title": "Trà đào",
  "ingredients": [
    {
      "name": "trà",
      "ratio": 20,
      "unit": "g",
      "price": 100000,
      "baseQuantity": 100
    },
    {
      "name": "đào",
      "ratio": 50,
      "unit": "g",
      "price": 80000,
      "baseQuantity": 100
    }
  ],
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

## Dependencies

- `firebase_core`: ^3.6.0
- `firebase_auth`: ^5.3.3
- `cloud_firestore`: ^5.5.0
- `google_sign_in`: ^6.2.1
- `provider`: ^6.1.2

## Lưu ý

- Đảm bảo đã bật Authentication trong Firebase Console
- Bật Email/Password và Google Sign-In providers
- Cấu hình SHA-1 fingerprint cho Android Google Sign-In
- Thêm GoogleService-Info.plist vào Xcode project cho iOS
- Cấu hình Firestore Rules để bảo mật dữ liệu

## Troubleshooting

### Lỗi Google Sign-In
- Kiểm tra SHA-1 fingerprint trong Firebase Console
- Đảm bảo GoogleService-Info.plist được thêm vào Xcode project
- Kiểm tra Bundle ID khớp với Firebase Console

### Lỗi Firestore
- Kiểm tra Firestore Rules
- Đảm bảo Firestore được bật trong Firebase Console

### Lỗi Recipe
- Kiểm tra quyền truy cập Firestore
- Đảm bảo user đã đăng nhập
- Kiểm tra cấu trúc dữ liệu

## Phát triển tiếp

- Thêm tính năng yêu thích công thức
- Thêm tính năng chia sẻ công thức
- Thêm tính năng đánh giá và bình luận
- Thêm push notifications
- Thêm offline support
- Thêm tính năng import/export công thức
- Thêm tính năng tính toán dinh dưỡng
