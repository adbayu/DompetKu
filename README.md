# Dompetku

Dompetku adalah aplikasi mobile Flutter untuk manajemen keuangan pribadi (project akademik). README ini merangkum fitur, arsitektur singkat, instruksi setup, dan file penting untuk pengembang.

**Ringkasan singkat**: Pencatatan transaksi (income/expense), kategori, dompet, budget bulanan, target finansial, utang/piutang, statistik sederhana, serta preferensi pengguna.

**Fitur utama**

- **Splash & Onboarding**: Tampilan awal dan konfigurasi pertama.
- **Dashboard**: Total saldo, pemasukan, pengeluaran, transaksi terbaru, progress budget, dan donut chart pengeluaran.
- **Transaksi**: CRUD transaksi dengan filter dan relasi ke kategori & dompet.
- **Kategori & Dompet**: CRUD kategori dan dompet (saldo, tipe).
- **Budget & Goal**: Budget bulanan dan target finansial dengan progress.
- **Utang/Piutang**: CRUD dan tandai lunas.
- **Settings**: Dark mode, simbol mata uang, nama pengguna, bahasa, dan notifikasi budget.

**Teknologi**

- **Flutter**: UI.
- **sqflite**: SQLite untuk penyimpanan lokal.
- **sqflite_common_ffi_web**: Adapter agar database berjalan di Flutter Web.
- **path_provider**, **shared_preferences**, **provider**, **intl**, **lottie**.

**Database (singkat)**

- Implementasi ada di [lib/database/database_helper.dart](lib/database/database_helper.dart).
- Tabel utama: `transactions`, `categories`, `wallets`, `budgets`, `financial_goals`, `debts`.
- Operasi umum disediakan lewat helper generic (`insert`, `update`, `delete`) dan query khusus (`getTransactions`, `getCategories`, dll.).

**File & Lokasi Penting**

- Database helper: [lib/database/database_helper.dart](lib/database/database_helper.dart)
- Shared preferences service: [lib/services/preferences_service.dart](lib/services/preferences_service.dart)
- App provider (state): [lib/providers/app_provider.dart](lib/providers/app_provider.dart)
- Donut chart widget: [lib/widgets/finance_donut_chart.dart](lib/widgets/finance_donut_chart.dart)
- Formatters util: [lib/utils/formatters.dart](lib/utils/formatters.dart)
- Entry point: [lib/main.dart](lib/main.dart)

**Struktur proyek (ringkas)**

```text
lib/
├─ core/
├─ database/
├─ models/
├─ providers/
├─ screens/
├─ services/
├─ themes/
├─ utils/
└─ widgets/
```

**Instruksi Setup & Menjalankan**

- Install dependensi:

```bash
flutter pub get
```

- Jalankan di perangkat/ emulator:

```bash
flutter run
```

- Menjalankan versi web (catatan: gunakan adapter Web SQLite):

```bash
dart run sqflite_common_ffi_web:setup
flutter run -d chrome
```

**Periksa kualitas & pengujian**

```bash
dart format .
flutter analyze
flutter test
```

**Catatan pengembang**

- Preferensi pengguna disimpan di [lib/services/preferences_service.dart](lib/services/preferences_service.dart) dan di-observe oleh `AppProvider`.
- Donut chart menggunakan `CustomPainter` di [lib/widgets/finance_donut_chart.dart](lib/widgets/finance_donut_chart.dart) untuk memenuhi requirement custom drawing.
- Untuk debugging database di web, ikuti instruksi `sqflite_common_ffi_web` pada dokumentasinya.
