# 🎵 Music App - Một ứng dụng nghe nhạc đa nền tảng

Một dự án full-stack xây dựng ứng dụng nghe nhạc đa nền tảng bằng Flutter và Python (Flask)

## 📖 Giới thiệu

Dự án này được xây dựng nhằm giải quyết bài toán cung cấp một trải nghiệm nghe nhạc chuyên dụng, miễn phí và không quảng cáo cho người dùng. Bằng cách xây dựng một backend trung gian, ứng dụng có khả năng lấy dữ liệu và luồng âm thanh trực tiếp sử dụng yt_dlp và ytmusicapi, sau đó cung cấp cho một giao diện client được tối ưu hóa cho việc nghe nhạc, được xây dựng bằng Flutter.

## ✨ Các tính năng chính

- **Xác thực người dùng:** Đăng ký, đăng nhập, đăng xuất sử dụng Firebase Authentication.
- **Trang chủ:** Hiển thị các danh sách được cá nhân hóa như "Bài hát thịnh hành", "Nghệ sĩ nổi bật".
- **Tìm kiếm đa năng:** Tìm kiếm và trả về kết quả đã được phân loại gồm Bài hát, Nghệ sĩ, và Playlist.
- **Trang chi tiết nghệ sĩ:** Hiển thị thông tin, mô tả và danh sách các bài hát hàng đầu của một nghệ sĩ.
- **Trình phát nhạc đầy đủ:**
    - Giao diện chơi nhạc hiện đại với ảnh bìa, tên bài hát.
    - Thanh tiến trình (progress bar) có thể tua nhạc (seek).
    - Các nút điều khiển đầy đủ: Play, Pause, Repeat, Next, Previous, Shuffle,...
    - Tự động chuyển bài khi kết thúc.
- **Backend mạnh mẽ:**
    - API được xây dựng bằng Flask (Python).
    - Tích hợp `ytmusicapi` để lấy dữ liệu đã tuyển chọn.
    - Tích hợp `yt-dlp` để lấy luồng audio.
    - Cơ chế Proxy cho hình ảnh để tránh lỗi CORS/hotlinking.
    - Cơ chế Caching phía server để tối ưu hiệu năng.

## 🚀 Kiến trúc công nghệ

- **Frontend:** Flutter (Dart)
- **Backend:** Flask (Python)
- **Xác thực:** Firebase Authentication
- **Database:** Cloud Firestore
- **Nguồn dữ liệu:** `ytmusicapi`, `yt-dlp`
