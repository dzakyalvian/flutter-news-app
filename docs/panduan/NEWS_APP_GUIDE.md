# NEWS APP FLUTTER

## Dokumen Panduan Kerja Terpadu Pertemuan 1--5

**Sumber utama:** Lima dokumen *Panduan Belajar Mandiri News App
Flutter* dari guru, Pertemuan 1 sampai 5.\
**Fungsi dokumen ini:** Ringkasan operasional untuk membantu membaca
persyaratan dan mengerjakan proyek secara bertahap.\
**Prioritas:** Jika ada perbedaan atau detail yang tidak tercakup di
dokumen ini, ikuti PDF asli pada `docs/panduan/`.

> Dokumen ini merangkum instruksi guru. Ini bukan pengganti PDF asli.
> Jangan menganggap fitur selesai hanya karena tercantum di sini. Status
> penyelesaian harus dibuktikan dari kode dan pengujian aktual.

------------------------------------------------------------------------

## 1. Aturan umum pengerjaan

1.  Lanjutkan proyek News App yang sama dari pertemuan sebelumnya.
    Jangan membuat proyek baru untuk pertemuan lanjutan.
2.  Kerjakan pertemuan secara berurutan, mulai dari kondisi proyek yang
    benar-benar tersedia.
3.  Sebelum mengubah kode, baca panduan pertemuan yang diminta dan
    periksa implementasi saat ini.
4.  Pertahankan fitur yang sudah berjalan. Jangan menghapus atau
    mengganti struktur tanpa alasan yang jelas.
5.  Sesuaikan contoh kode guru dengan struktur proyek yang sudah ada.
    Jangan menyalin contoh secara membabi buta jika akan membuat
    deklarasi, fungsi, atau `dispose()` ganda.
6.  Jangan membuat request HTTP langsung di dalam
    `FutureBuilder.builder`. Simpan `Future` pada state dan perbarui
    saat dibutuhkan.
7.  Bedakan data kosong dari error. Jangan mengubah semua error menjadi
    daftar kosong.
8.  Jangan menampilkan API key atau informasi rahasia pada pesan error,
    screenshot, dokumen, atau repository publik.
9.  Jangan mengarang hasil pengujian. Catat hasil aktual, termasuk yang
    gagal atau belum diuji.
10. Jelaskan perubahan kode dengan bahasa sederhana agar siswa dapat
    memahami dan menjelaskannya.

## 2. Gambaran alur aplikasi

Alur data dasar:

`NewsAPI → NewsService → JSON → List<Article> → NewsPage → daftar berita`

Fitur berkembang secara berurutan:

-   Pertemuan 1: mengambil dan menampilkan berita.
-   Pertemuan 2: kategori, pencarian API, dan filter judul lokal.
-   Pertemuan 3: halaman detail dan navigasi.
-   Pertemuan 4: integrasi, error handling, tombol coba lagi, dan
    pengujian.
-   Pertemuan 5: pemisahan konfigurasi API key menggunakan
    `flutter_dotenv`.

## 3. Persyaratan per pertemuan

# Pertemuan 1: Mengambil dan Menampilkan Berita dari NewsAPI

**Durasi panduan:** 3 JP atau 135 menit.

### 3.1 Tujuan

Siswa mampu: - Menyiapkan proyek Flutter dan memasang package `http`. -
Membuat model `Article`. - Mengambil berita dari NewsAPI melalui
`NewsService`. - Mengubah respons JSON menjadi objek Dart. - Menampilkan
daftar menggunakan `FutureBuilder` dan `ListView.builder`. - Menangani
loading, error, data kosong, dan gambar yang gagal dimuat.

### 3.2 Persiapan dan struktur dasar

Panduan awal menggunakan perintah:

``` bash
flutter create news_app
cd news_app
flutter pub add http
```

Struktur file yang dicontohkan:

``` text
lib/
├── main.dart
├── models/
│   └── article.dart
├── services/
│   └── news_service.dart
└── pages/
    └── news_page.dart
```

Fungsi folder: - `models`: menyimpan model data. - `services`: menangani
request API. - `pages`: menyimpan halaman UI. - `main.dart`: titik awal
aplikasi.

Gunakan API key NewsAPI milik sendiri. Jangan unggah key ke repository
publik.

### 3.3 Model Article

File acuan: `lib/models/article.dart`.

Model harus merepresentasikan satu berita dengan properti: - `title` -
`description` - `imageUrl` - `sourceName` - `publishedAt` - `url`

Panduan meminta constructor dengan properti tersebut dan factory
`Article.fromJson(Map<String, dynamic> json)`.

Pemetaan JSON yang dicontohkan: - `title` → `title`, fallback
`Judul tidak tersedia`. - `description` → `description`, fallback string
kosong. - `urlToImage` → `imageUrl`, fallback string kosong. -
`source.name` → `sourceName`, fallback `Sumber tidak diketahui`. -
`publishedAt` → `publishedAt`, fallback string kosong. - `url` → `url`,
fallback string kosong.

Hal yang perlu dipahami: - `Article` menyimpan data satu berita. -
`Article.fromJson()` mengubah `Map` hasil decode JSON menjadi objek
`Article`. - Operator `??` memberikan nilai pengganti ketika nilai di
kiri `null`. - `source?['name']` mengantisipasi objek `source` yang
tidak tersedia.

### 3.4 NewsService

File acuan: `lib/services/news_service.dart`.

Tugas `NewsService.fetchTopHeadlines()`: 1. Menyusun URI endpoint
`https://newsapi.org/v2/top-headlines`. 2. Menggunakan parameter contoh
`country: us` dan `pageSize: 20`. 3. Mengirim HTTP GET dengan header
`X-Api-Key`. 4. Memeriksa `response.statusCode`. Jika bukan `200`,
lempar exception yang menjelaskan kode HTTP. 5. Decode response JSON
menjadi `Map<String, dynamic>`. 6. Memeriksa `data['status'] == 'ok'`.
Jika tidak, gunakan pesan API atau pesan error yang sesuai. 7. Mengambil
`articles`, memetakan setiap item melalui `Article.fromJson()`, lalu
mengembalikan `List<Article>`.

Catatan dari panduan: akses endpoint, negara, dan jumlah request dapat
bergantung pada paket akun NewsAPI.

### 3.5 NewsPage dan tampilan daftar

File acuan: `lib/pages/news_page.dart`.

Panduan mencontohkan: - `NewsPage` menggunakan `StatefulWidget`. -
Membuat instance `NewsService`. - Menyimpan request pada
`Future<List<Article>> _newsFuture`. - Memulai request pertama di
`initState()`. - Menggunakan `FutureBuilder<List<Article>>` untuk
mengamati Future. - Menggunakan `ListView.builder` untuk daftar berita.

Kondisi UI: - **Loading:** tampilkan `CircularProgressIndicator`. -
**Error:** tampilkan pesan gagal, informasi error yang sesuai, dan
tombol `Coba Lagi`. - **Data kosong:** tampilkan pesan seperti
`Tidak ada berita tersedia.` - **Berhasil:** tampilkan daftar artikel.

Kartu berita pada contoh menampilkan: - Gambar berita jika `imageUrl`
tidak kosong. - Sumber berita. - Judul. - Deskripsi, atau teks
`Deskripsi tidak tersedia.` jika deskripsi kosong.

Gunakan `Image.network` dengan `errorBuilder` agar kegagalan gambar
tidak menyebabkan UI rusak. Panduan memberi contoh ikon gambar rusak
sebagai pengganti.

Tombol `Coba Lagi` memperbarui `_newsFuture` melalui `setState()` dengan
request baru.

### 3.6 Integrasi aplikasi

`main.dart` menghubungkan `MaterialApp` dengan `NewsPage` sebagai
halaman utama. Pertahankan nama widget utama yang benar-benar digunakan
proyek.

Jika aplikasi Android tidak dapat mengakses internet, panduan meminta
pemeriksaan permission berikut di
`android/app/src/main/AndroidManifest.xml`. Letakkan di dalam tag
`manifest` dan di luar tag `application`:

``` xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 3.7 Troubleshooting

  -----------------------------------------------------------------------
  Gejala                              Pemeriksaan menurut panduan
  ----------------------------------- -----------------------------------
  401 Unauthorized                    Periksa API key, penulisan key, dan
                                      metode autentikasi.

  403 Forbidden                       Periksa paket akun dan akses
                                      endpoint.

  429 Too Many Requests               Periksa batas request dan hindari
                                      menekan Coba Lagi berulang kali.

  Gagal koneksi                       Periksa internet, permission
                                      Android, dan endpoint.

  Berita tidak ada                    Periksa respons API, parameter
                                      request, dan apakah `articles`
                                      kosong.

  Gambar tidak muncul                 URL gambar mungkin kosong/tidak
                                      valid atau server gambar tidak
                                      dapat diakses.

  Compile error                       Periksa nama file, import, tanda
                                      kurung, dan package `http`.
  -----------------------------------------------------------------------

### 3.8 Checklist keberhasilan

-   [ ] Proyek Flutter berhasil dibuat dan dijalankan.
-   [ ] Package `http` berhasil dipasang.
-   [ ] Model `Article` berhasil dibuat.
-   [ ] `NewsService` berhasil mengambil data.
-   [ ] Daftar berita tampil dari API, bukan hanya data dummy.
-   [ ] Judul, sumber, dan deskripsi terlihat.
-   [ ] Loading tampil saat data sedang diambil.
-   [ ] Error dapat ditampilkan dan tombol Coba Lagi berfungsi.
-   [ ] Gambar kosong atau gagal dimuat tidak membuat aplikasi crash.

### 3.9 Bukti dan refleksi

Bukti yang diminta: - Screenshot aplikasi yang menampilkan daftar berita
dari NewsAPI. - Screenshot struktur folder `lib`. - File proyek atau
repository sesuai arahan guru. Jangan sertakan API key pada repository
publik. - Jawaban refleksi dengan kata-kata sendiri.

Refleksi: 1. Jelaskan alur data dari NewsAPI sampai tampil di layar. 2.
Apa fungsi class `Article` dan method `Article.fromJson()`? 3. Apa arti
`Future<List<Article>>` pada fungsi `fetchTopHeadlines()`? 4. Mengapa
request dijalankan di `initState()`, bukan langsung di `build()`? 5. Apa
perbedaan loading, error, dan data kosong? 6. Sebutkan minimal dua
penyebab data berita gagal ditampilkan.

Bobot kriteria keberhasilan: - Berhasil mengambil data API: 30%. -
Struktur kode sesuai panduan dan terpisah per file: 20%. - Daftar berita
tampil dengan benar: 25%. - Loading/error dan gambar ditangani: 15%. -
Mampu menjawab refleksi dengan kata-kata sendiri: 10%.

------------------------------------------------------------------------

# Pertemuan 2: Kategori, Pencarian, dan Filter

**Durasi:** tidak dicantumkan pada bagian ringkasan panduan.

### 4.1 Tujuan

-   Menambahkan pilihan kategori berita.
-   Mencari berita menggunakan kata kunci melalui NewsAPI.
-   Membedakan filter API dan filter lokal.
-   Menguji fitur serta menangani loading, error, dan hasil kosong.

### 4.2 Prasyarat

Lanjutkan proyek dari Pertemuan 1. Pastikan daftar berita sebelumnya
sudah tampil. Gunakan API key milik sendiri dan jangan mengunggahnya ke
repository publik.

### 4.3 Dua jenis filter

  -----------------------------------------------------------------------
  Jenis                   Cara kerja              Contoh
  ----------------------- ----------------------- -----------------------
  Filter API              Flutter mengirim        Memilih kategori
                          request dan API         Technology atau mencari
                          mengembalikan hasil     kata kunci.
                          yang cocok.             

  Filter lokal            Flutter menyaring data  Menampilkan judul yang
                          yang sudah diterima     mengandung `AI`.
                          tanpa request baru.     
  -----------------------------------------------------------------------

### 4.4 NewsService

File acuan: `lib/services/news_service.dart`.

Panduan meminta tiga fungsi utama:

**`fetchTopHeadlines({String category = 'general'})`** - Menggunakan
endpoint `/v2/top-headlines`. - Parameter contoh: `country: us`,
`category`, `pageSize: 20`. - Mengembalikan hasil melalui fungsi request
bersama `_getArticles(uri)`.

**`searchArticles({required String query})`** - Menggunakan endpoint
`/v2/everything`. - Parameter contoh: `q: query`, `pageSize: 20`,
`sortBy: publishedAt`. - Mengembalikan hasil melalui
`_getArticles(uri)`.

**`_getArticles(Uri uri)`** - Mengirim HTTP GET dengan header
`X-Api-Key`. - Decode JSON. - Memeriksa status HTTP `200` dan status
NewsAPI `ok`. - Jika gagal, lempar exception menggunakan pesan API atau
pesan fallback. - Memetakan daftar `articles` ke `Article`. - Dipakai
bersama agar kode request dan parsing tidak diduplikasi.

Kategori NewsAPI yang dicontohkan: - `general` - `business` -
`entertainment` - `health` - `science` - `sports` - `technology`

Akses kategori dapat bergantung pada paket akun.

### 4.5 State dan fungsi pada NewsPage

File acuan: `lib/pages/news_page.dart`.

Pastikan tidak ada deklarasi ganda. Variabel/fungsi yang dicontohkan: -
`_newsService` - `_newsFuture` - `_selectedCategory`, nilai awal
`general` - `_categories`, berisi label dan value kategori -
`_searchController` - `_selectCategory(String category)` -
`_searchNews()`

Daftar label kategori: \| Label UI \| Value API \| \|---\|---\| \| Umum
\| `general` \| \| Bisnis \| `business` \| \| Hiburan \| `entertainment`
\| \| Kesehatan \| `health` \| \| Sains \| `science` \| \| Olahraga \|
`sports` \| \| Teknologi \| `technology` \|

`_selectCategory(category)`: - Memperbarui `_selectedCategory`. -
Mengisi `_newsFuture` dengan request
`fetchTopHeadlines(category: category)` di dalam `setState()`.

`_searchNews()`: - Mengambil teks dari `_searchController` dan
menjalankan `trim()`. - Jika kosong, panggil
`_selectCategory(_selectedCategory)` lalu berhenti. - Jika tidak kosong,
isi `_newsFuture` dengan `searchArticles(query: query)` di dalam
`setState()`.

Pertahankan `initState()` agar berita awal tetap dimuat.

### 4.6 UI pencarian dan kategori

Panduan menyusun `body` sebagai `Column`: 1. TextField pencarian API. 2.
Daftar kategori horizontal menggunakan `ChoiceChip`. 3. `Expanded`
berisi `FutureBuilder` yang sudah ada.

Pencarian API: - Gunakan `_searchController`. -
`textInputAction: TextInputAction.search`. - `onSubmitted` memanggil
`_searchNews()`. - Tombol pada `suffixIcon` juga memanggil
`_searchNews()`.

Kategori: - Tampilkan kategori secara horizontal. - Tandai kategori
aktif melalui properti `selected`. - Saat kategori dipilih, panggil
`_selectCategory()`.

`FutureBuilder` perlu berada di dalam `Expanded` agar `Column` tidak
mengalami layout overflow. Pindahkan builder Pertemuan 1 ke bagian
tersebut dan pertahankan penanganan loading, error, data kosong, serta
`ListView.builder`.

### 4.7 Filter lokal berdasarkan judul

Tambahkan: - `TextEditingController _localFilterController`. -
`String _localKeyword = ''`. - Fungsi
`filterByTitle(List<Article> articles, String keyword)`.

Perilaku `filterByTitle`: - Jika keyword kosong setelah `trim()`,
kembalikan semua artikel. - Gunakan `where()` untuk memeriksa setiap
artikel. - Bandingkan `article.title.toLowerCase()` dengan
`keyword.trim().toLowerCase()`. - Gunakan `contains()` untuk mencari
kecocokan. - Gunakan `toList()` untuk menghasilkan `List<Article>`.

Tambahkan TextField filter lokal: - Label: `Filter judul berita`. -
Contoh hint: `AI, technology, sports`. - `onChanged` memperbarui
`_localKeyword` melalui `setState()`. - Tombol clear mengosongkan
controller dan `_localKeyword`.

Di bagian data berhasil pada `FutureBuilder`: 1. Ambil `articles` dari
`snapshot.data ?? []`. 2. Buat
`filteredArticles = filterByTitle(articles, _localKeyword)`. 3. Jika
`filteredArticles.isEmpty`, tampilkan `Tidak ada berita yang cocok.` 4.
Gunakan `filteredArticles` sebagai sumber `itemCount` dan item pada
`ListView.builder`.

Contoh `ListTile` pada panduan hanya contoh sederhana. Jika proyek sudah
memiliki kartu berita dengan gambar, deskripsi, dan sumber, pertahankan
desain tersebut dan cukup gunakan `filteredArticles`.

### 4.8 Lifecycle controller

Gabungkan pembersihan controller di satu method `dispose()`: -
`_searchController.dispose()`. - `_localFilterController.dispose()`. -
`super.dispose()`.

Jika controller belum ada, jangan menambahkan baris dispose untuk
controller tersebut. Jika `dispose()` sudah ada, gabungkan. Jangan
membuat dua method `dispose()`.

### 4.9 Pengujian wajib

-   [ ] Pilih kategori Teknologi. Aplikasi meminta berita kategori
    `technology`.
-   [ ] Pilih kategori Olahraga. Kategori aktif berubah dan berita
    dimuat ulang.
-   [ ] Cari `artificial intelligence`. Aplikasi meminta hasil pencarian
    API.
-   [ ] Jalankan pencarian dengan input kosong. Aplikasi kembali ke
    kategori aktif.
-   [ ] Coba memuat data tanpa koneksi. Aplikasi menampilkan penanganan
    error.

### 4.10 Troubleshooting

  -----------------------------------------------------------------------
  Kendala                             Pemeriksaan
  ----------------------------------- -----------------------------------
  401 Unauthorized                    API key salah atau belum diganti.

  403 Forbidden                       Periksa akses endpoint dan
                                      ketentuan paket API.

  429 Too Many Requests               Batas request mungkin terlampaui.
                                      Jangan menekan tombol berulang.

  Compile error                       Periksa import, kurung, koma, nama
                                      variabel, dan duplikasi
                                      `dispose()`.

  Layout overflow                     Pastikan `FutureBuilder` berada di
                                      dalam `Expanded`.

  Hasil kosong                        Coba kata kunci lain dan periksa
                                      respons API.
  -----------------------------------------------------------------------

### 4.11 Bukti, refleksi, dan checklist

Bukti: - Screenshot pilihan kategori. - Screenshot hasil pencarian kata
kunci. - File kode `NewsService` dan `NewsPage` yang diperbarui. -
Jawaban refleksi.

Refleksi: 1. Apa perbedaan endpoint `/v2/top-headlines` dan
`/v2/everything`? 2. Mengapa memilih kategori mengirim request baru pada
aplikasi ini? 3. Mengapa filter lokal tidak membutuhkan request API? 4.
Apa fungsi `trim()`, `toLowerCase()`, `contains()`, dan `where()`? 5.
Bagian mana yang paling sulit dan bagaimana kamu menyelesaikannya?

Checklist: - \[ \] Aplikasi berjalan tanpa compile error. - \[ \]
Kategori Umum, Bisnis, Olahraga, dan Teknologi dapat dipilih. - \[ \]
Pencarian API berjalan dengan kata kunci tidak kosong. - \[ \] Input
kosong ditangani. - \[ \] Loading, error, dan data kosong tetap
ditangani. - \[ \] API key tidak dibagikan di repository publik.

------------------------------------------------------------------------

# Pertemuan 3: Halaman Detail Berita dan Navigasi

### 5.1 Tujuan dan konsep utama

Pertemuan 3 melanjutkan proyek dari Pertemuan 2. Fitur kategori dan
pencarian yang sudah ada harus tetap dipertahankan.

Tujuan pengerjaan: - Membuat halaman detail untuk satu berita. -
Mengirim objek `Article` yang dipilih ke halaman detail. - Menghubungkan
daftar berita dan halaman detail menggunakan navigasi Flutter. -
Menampilkan informasi berita yang sesuai dengan item yang dipilih.

### 5.2 Halaman detail

File yang diminta: `article_detail_page.dart` di dalam struktur halaman
proyek, mengikuti pola folder proyek yang sudah digunakan.

Panduan meminta halaman detail menerima objek `Article` melalui
parameter `article`. Halaman detail menampilkan: 1. Gambar berita. 2.
Judul berita. 3. Nama sumber berita. 4. Tanggal publikasi. 5. Deskripsi
berita.

Gunakan `StatelessWidget` untuk halaman detail sesuai panduan.

Konten detail perlu dapat digulir menggunakan `SingleChildScrollView`,
terutama ketika deskripsi panjang. Gambar menggunakan penanganan
kegagalan seperti `errorBuilder` agar URL gambar yang kosong atau tidak
valid tidak merusak tampilan.

### 5.3 Navigasi

Hubungkan kartu berita pada daftar dengan halaman detail: - Gunakan
`Navigator.push()`. - Kirim objek `Article` yang benar melalui parameter
`article`. - Objek harus berasal dari item yang dipilih pada
`ListView.builder`, bukan objek tetap atau objek berita yang sama untuk
semua kartu. - Navigasi kembali menggunakan mekanisme kembali Flutter,
yang bekerja melalui `Navigator.pop()`.

Pastikan halaman detail menampilkan data dari berita yang dipilih.

### 5.4 Fitur tambahan opsional

Panduan menyebut tombol untuk membuka artikel asli menggunakan package
`url_launcher` sebagai materi tambahan/opsional: - Pasang package jika
memilih mengerjakan fitur ini. - Gunakan URL artikel dari
`article.url`. - Tombol contoh berlabel `Baca Artikel Asli`. - Uji pada
berita dengan URL valid. - Keberhasilan membuka halaman bergantung pada
URL dan aplikasi browser perangkat.

Jika package atau tombol belum berhasil, siswa boleh menyelesaikan
bagian wajib terlebih dahulu.

### 5.5 Pengujian

-   [ ] Aplikasi dapat dijalankan tanpa error.
-   [ ] Daftar berita tetap tampil seperti pada Pertemuan 2.
-   [ ] Kategori dan pencarian berita tidak rusak.
-   [ ] Setiap kartu berita yang dipilih membuka halaman detail.
-   [ ] Judul detail sesuai dengan berita yang dipilih.
-   [ ] Sumber berita ditampilkan dengan benar.
-   [ ] Tanggal publikasi ditampilkan.
-   [ ] Deskripsi ditampilkan jika tersedia.
-   [ ] Halaman dapat digulir ketika konten panjang.
-   [ ] Gambar yang gagal dimuat tidak merusak tampilan.
-   [ ] Tombol kembali mengembalikan pengguna ke daftar berita.
-   [ ] Jika fitur tambahan dikerjakan, tombol artikel asli diuji.

Uji minimal tiga berita berbeda. Catat apakah judul dan informasi detail
sesuai dengan berita yang dipilih.

### 5.6 Troubleshooting

  ----------------------------------------------------------------------------------------
  Kendala                 Kemungkinan penyebab    Pemeriksaan/solusi
  ----------------------- ----------------------- ----------------------------------------
  `ArticleDetailPage`     Import belum            Periksa import dan nama file.
  tidak dikenal           ditambahkan atau nama   
                          file salah              

  `article` tidak dikenal Variabel belum          Pastikan objek berasal dari item pada
                          dideklarasikan pada     `ListView.builder`.
                          builder                 

  Error pada constructor  Parameter `article`     Kirim
                          belum dikirim           `ArticleDetailPage(article: article)`.

  Semua detail berita     Data yang dikirim bukan Kirim objek `article` dari item yang
  sama                    objek yang dipilih      diketuk.

  Gambar tidak muncul     URL kosong/tidak valid  Periksa URL dan gunakan `errorBuilder`.
                          atau koneksi bermasalah 

  Konten terpotong        Tampilan tidak bisa     Gunakan `SingleChildScrollView`.
                          digulir                 

  Tombol kembali tidak    AppBar dikustomisasi    Periksa alur navigasi dan konfigurasi
  terlihat                atau halaman dibuka     AppBar.
                          tanpa rute sebelumnya   

  Tombol artikel asli     Package belum terpasang Periksa package dan `article.url`.
  tidak berfungsi         atau URL tidak valid    
  ----------------------------------------------------------------------------------------

### 5.7 Tugas, bukti, dan refleksi

Tugas: 1. Buat halaman `article_detail_page.dart`. 2. Hubungkan kartu
berita dengan halaman detail menggunakan `Navigator.push()`. 3. Kirim
objek berita yang dipilih melalui parameter `article`. 4. Uji minimal
tiga berita berbeda. 5. Pertahankan fitur Pertemuan 1 dan 2. Jangan
membuat proyek baru.

Bukti: - Screenshot halaman daftar berita. - Screenshot halaman detail
berita. - Screenshot kode navigasi pada `news_page.dart`. - Screenshot
kode halaman detail. - Video demo singkat yang memperlihatkan memilih
berita, membuka detail, dan kembali ke daftar.

Refleksi: 1. Apa fungsi halaman detail berita pada aplikasi News App? 2.
Apa perbedaan fungsi `Navigator.push()` dan `Navigator.pop()`? 3.
Mengapa objek `Article` perlu dikirim ke halaman detail? 4. Apa yang
terjadi jika data yang dikirim selalu menggunakan objek berita yang
sama? 5. Mengapa `SingleChildScrollView` diperlukan pada halaman detail?
6. Apa manfaat `errorBuilder` pada gambar berita? 7. Kendala apa yang
ditemui dan bagaimana cara mengatasinya?

### 5.8 Kriteria keberhasilan

-   [ ] Halaman detail dapat dibuka dari daftar berita.
-   [ ] Data berita yang ditampilkan sesuai dengan berita yang dipilih.
-   [ ] Navigasi kembali berjalan.
-   [ ] Aplikasi tetap mempertahankan fitur utama pertemuan sebelumnya.
-   [ ] Bukti pengerjaan dikumpulkan dan refleksi dijawab.

------------------------------------------------------------------------

# Pertemuan 4: Error Handling, Integrasi, dan Pengujian

**Durasi:** 3 JP atau 135 menit.

### 6.1 Tujuan

Siswa mampu: - Membedakan loading, berhasil, data kosong, dan gagal. -
Menangani kesalahan HTTP dan masalah jaringan dengan pesan yang jelas. -
Menyediakan tombol Coba Lagi. - Mengintegrasikan berita utama, kategori,
pencarian, filter lokal, dan detail. - Menguji aplikasi secara
sistematis dan mencatat hasilnya.

### 6.2 Persiapan

Lanjutkan proyek dari Pertemuan 3. Jangan membuat proyek baru atau
menghapus fitur yang sudah selesai.

Sebelum mengubah kode: 1. Jalankan aplikasi dan pastikan daftar berita
serta halaman detail berfungsi. 2. Pastikan model `Article`,
`NewsService`, `NewsPage`, dan `ArticleDetailPage` tersedia sesuai
struktur proyek. 3. Pastikan API key tidak diunggah ke repository
publik. 4. Jika terjadi error, baca pesan di Debug Console sebelum
mengubah kode.

### 6.3 Empat kondisi UI

  -----------------------------------------------------------------------
  Kondisi                 Makna                   Respons UI
  ----------------------- ----------------------- -----------------------
  Loading                 Permintaan sedang       Indikator proses.
                          diproses.               

  Success                 Data berhasil diterima. Daftar berita.

  Empty                   Permintaan berhasil,    Pesan berita tidak
                          tetapi tidak ada        ditemukan.
                          artikel.                

  Error                   Permintaan gagal atau   Pesan error dan tombol
                          terjadi masalah.        Coba Lagi.
  -----------------------------------------------------------------------

Penting: - Data kosong berarti request berhasil tetapi tidak
menghasilkan artikel. - Error berarti request atau pemrosesan gagal. -
Pada `FutureBuilder`, periksa error, status koneksi, lalu data. - Jangan
mengubah semua error menjadi list kosong.

### 6.4 FutureBuilder

Perbaiki `FutureBuilder` yang sudah ada di `news_page.dart`. Pertahankan
kode daftar dan filter yang sudah tersedia.

Urutan penanganan yang dicontohkan: 1. Jika `ConnectionState.waiting`,
tampilkan `CircularProgressIndicator`. 2. Jika `snapshot.hasError`,
tampilkan pesan yang jelas dan tombol Coba Lagi. 3. Ambil data dari
`snapshot.data ?? []`. 4. Jika daftar kosong, tampilkan pesan data
kosong. 5. Jika data tersedia, tampilkan filter dan `ListView.builder`
milik proyek.

Nama fungsi contoh seperti `buildArticleList` pada PDF hanya ilustrasi.
Sesuaikan dengan struktur proyek. Jika kode daftar sudah berada langsung
di dalam builder, pertahankan dan sesuaikan penanganan state.

### 6.5 Tombol Coba Lagi

Tombol harus menjalankan ulang Future yang dipakai `FutureBuilder`.

-   Simpan Future pada state, misalnya `_newsFuture`.
-   Perbarui Future melalui `setState()`.
-   Jika kategori aktif, ulangi request kategori yang sama.
-   Jika sedang mencari, ulangi pencarian dengan kata kunci yang sama.
    Jangan kembali ke berita utama.
-   Jika `NewsService` sudah disimpan sebagai objek, gunakan objek
    tersebut.
-   Jangan membuat instance atau request yang tidak diperlukan.

### 6.6 Error handling di NewsService

`NewsService` bertanggung jawab mengirim HTTP request dan mengubah JSON
menjadi `Article`.

Pada fungsi request bersama seperti `_getArticles(Uri uri)`: 1. Kirim
HTTP request. 2. Periksa status HTTP sebelum membaca daftar artikel. 3.
Jika status HTTP bukan `200`, lempar exception dengan kode HTTP. 4.
Decode JSON. 5. Periksa `jsonData['status'] == 'ok'`. 6. Jika status API
gagal, gunakan pesan API atau pesan fallback. 7. Ambil `articles`
sebagai list, dengan fallback list kosong hanya untuk respons sukses
yang memang tidak memiliki artikel. 8. Petakan setiap item ke `Article`.

Ketentuan penting dari panduan: - HTTP 200 biasanya menandakan request
berhasil, tetapi struktur respons tetap harus diperiksa. - Respons error
API mungkin tidak memiliki field `articles`. - Masalah jaringan dapat
menghasilkan exception sebelum respons diterima. - Jangan tampilkan API
key atau informasi rahasia dalam pesan error. - Jangan mengubah semua
error menjadi list kosong karena kegagalan akan terlihat seperti tidak
ada berita. - Jangan menambahkan return kedua atau menduplikasi parsing
JSON.

### 6.7 Mencegah request berulang

Simpan `Future<List<Article>> _newsFuture` pada state. - Inisialisasi
request awal di `initState()`. - Perbarui Future saat kategori dipilih,
pencarian dilakukan, atau tombol Coba Lagi ditekan. - Hindari membuat
request HTTP langsung di dalam `FutureBuilder.builder`, karena builder
dapat dipanggil berkali-kali. - Jika variabel dan `initState()` sudah
ada, jangan menambahkannya lagi.

### 6.8 Integrasi fitur Pertemuan 1--3

Pastikan seluruh hal berikut bekerja: - Berita utama dimuat dari
NewsAPI. - Kategori memperbarui daftar berita sesuai pilihan. -
Pencarian API mengirim kata kunci yang benar. - Filter lokal menyaring
data yang sudah diterima tanpa request baru. - Kartu berita membuka
halaman detail dengan objek `Article` yang tepat. - Tombol kembali
mengembalikan pengguna ke daftar. - Loading, error, data kosong, dan
success tampil sesuai keadaan. - Coba Lagi mengulangi request yang
relevan dengan kategori atau pencarian aktif.

### 6.9 Skenario pengujian

Panduan meminta minimal delapan dari sepuluh skenario berikut. Sebaiknya
uji seluruhnya jika memungkinkan.

  -----------------------------------------------------------------------
  No.               Skenario          Langkah           Hasil yang
                                                        diharapkan
  ----------------- ----------------- ----------------- -----------------
  1                 Berita utama      Buka aplikasi.    Daftar berita
                                                        atau pesan error
                                                        yang sesuai.

  2                 Kategori          Pilih kategori    Daftar
                                      lain.             menyesuaikan
                                                        kategori.

  3                 Pencarian API     Cari kata kunci   Hasil pencarian
                                      relevan.          tampil.

  4                 Filter lokal      Masukkan kata     Daftar tersaring
                                      pada filter       tanpa request
                                      lokal.            baru.

  5                 Detail            Ketuk salah satu  Informasi sesuai
                                      berita.           berita yang
                                                        dipilih.

  6                 Kembali           Kembali dari      Daftar berita
                                      detail.           dapat digunakan
                                                        lagi.

  7                 Data kosong       Gunakan kata      Pesan data kosong
                                      kunci yang        tampil jika
                                      kemungkinan tidak respons berhasil
                                      menghasilkan      tanpa artikel.
                                      hasil.            

  8                 Error jaringan    Putuskan koneksi  Pesan error dan
                                      perangkat         Coba Lagi tampil.
                                      sementara.        

  9                 Coba Lagi         Pulihkan koneksi  Permintaan
                                      lalu tekan Coba   diulang.
                                      Lagi.             

  10                Gambar gagal      Uji URL gambar    Widget pengganti
                                      yang tidak        gambar tampil.
                                      tersedia jika     
                                      memungkinkan.     
  -----------------------------------------------------------------------

Lakukan uji jaringan secara terkendali dan pulihkan koneksi setelahnya.
Jangan mengubah API key atau menghapus data proyek untuk menguji error.

Catat hasil setiap skenario secara jujur, misalnya: Berhasil, Gagal,
atau Belum diuji, beserta catatan singkat.

### 6.10 Tugas dan refleksi

Tugas: 1. Lengkapi tampilan loading, berhasil, data kosong, dan error.
2. Pastikan `NewsService` memeriksa status HTTP dan meneruskan error
yang relevan. 3. Tambahkan tombol Coba Lagi yang mengulang request
sesuai kategori atau pencarian aktif. 4. Uji integrasi berita utama,
kategori, pencarian API, filter lokal, detail, dan navigasi kembali. 5.
Jalankan minimal delapan skenario pengujian pada bagian 6.9 dan catat
hasilnya.

Refleksi: 1. Apa perbedaan kondisi error dan data kosong? 2. Mengapa
pemeriksaan status HTTP perlu dilakukan di `NewsService`? 3. Apa fungsi
tombol Coba Lagi? 4. Mengapa Future sebaiknya tidak dibuat berulang kali
di dalam builder `FutureBuilder`? 5. Bagaimana memastikan halaman detail
menampilkan berita yang benar? 6. Sebutkan satu bug yang ditemukan saat
pengujian dan cara memperbaikinya.

### 6.11 Kriteria keberhasilan

-   [ ] Aplikasi tetap menjalankan fitur dari Pertemuan 1--3.
-   [ ] UI membedakan loading, berhasil, data kosong, dan error.
-   [ ] Kegagalan request tidak membuat aplikasi berhenti tanpa
    penjelasan.
-   [ ] Tombol Coba Lagi berfungsi.
-   [ ] Hasil pengujian dicatat dengan jujur, termasuk bagian yang belum
    berhasil.
-   [ ] Siswa dapat menjelaskan perubahan kode yang dibuat.

------------------------------------------------------------------------

# Pertemuan 5: Pengelolaan API Key dengan flutter_dotenv

### 7.1 Tujuan

Pertemuan ini memindahkan konfigurasi API key dari kode Dart ke file
`.env` menggunakan package `flutter_dotenv`.

Tujuan praktik: - Memasang `flutter_dotenv`. - Membuat file `.env`. -
Mendaftarkan `.env` sebagai asset. - Memuat `.env` sebelum `runApp()`. -
Membaca `NEWS_API_KEY` dari `NewsService`. - Mengatur `.gitignore`. -
Membuat `.env.example` tanpa key asli. - Menguji fitur dan memeriksa
Git.

### 7.2 Konsep keamanan

Panduan membandingkan: \| Pendekatan \| Kegunaan \| Catatan \|
\|---\|---\|---\| \| Flutter + `.env` \| Latihan pemisahan konfigurasi
dan mencegah key ter-commit. \| Tidak menyembunyikan key dari pengguna
aplikasi. \| \| Backend/server \| Menyimpan key di server dan meneruskan
permintaan. \| Lebih tepat untuk rahasia aplikasi produksi. \|

Catatan penting dari guru: `.env` bukan brankas rahasia. File
konfigurasi yang dimasukkan ke aplikasi Flutter tetap dapat diekstrak
oleh pengguna aplikasi. Untuk aplikasi produksi, simpan API key yang
benar-benar rahasia di backend/server.

Sebelum perubahan: - Pastikan aplikasi dapat mengambil berita sebelum
perubahan. - Temukan file service yang saat ini menyimpan API key. -
Jangan menuliskan atau mengirim key asli ke chat, screenshot, dokumen
tugas, atau repository.

### 7.3 Langkah implementasi

**Langkah 1: Pasang package**

Jalankan di direktori utama proyek, yaitu folder yang berisi
`pubspec.yaml`:

``` bash
flutter pub add flutter_dotenv
```

**Langkah 2: Buat `.env`**

Buat file `.env` di root proyek, sejajar dengan `pubspec.yaml`:

``` env
NEWS_API_KEY=ISI_API_KEY_MILIKMU_DI_SINI
```

Ganti placeholder secara lokal dengan key milik sendiri. Jangan
memasukkan key asli ke dokumen atau template yang dibagikan.

**Langkah 3: Daftarkan `.env` di `pubspec.yaml`**

Di bagian `flutter:`, daftarkan:

``` yaml
flutter:
  assets:
    - .env
```

Ini hanya contoh susunan. Jika `flutter:` dan `assets:` sudah ada,
tambahkan `- .env` ke daftar assets yang tersedia. Jangan membuat bagian
`flutter:` kedua. Pertahankan konfigurasi lain seperti
`uses-material-design: true`.

Setelah mengubah `pubspec.yaml`, jalankan:

``` bash
flutter pub get
```

**Langkah 4: Muat `.env` sebelum `runApp()`**

Tambahkan import:

``` dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
```

Pastikan `main()` memuat konfigurasi terlebih dahulu:

``` dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}
```

`MyApp` hanya contoh. Pertahankan nama widget utama proyek. Jika
`main()` sudah memiliki proses inisialisasi lain, gabungkan tanpa
menghapus proses yang masih dibutuhkan. `dotenv.load` harus selesai
sebelum service membaca konfigurasi.

**Langkah 5: Ambil key di NewsService**

Di `lib/services/news_service.dart`, tambahkan import:

``` dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
```

Hapus deklarasi key yang ditulis langsung di file Dart. Baca key:

``` dart
final String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

if (apiKey.isEmpty) {
  throw Exception(
    'NEWS_API_KEY belum diatur. Periksa file .env.',
  );
}
```

Gunakan `apiKey` pada request yang sudah ada. Jika proyek memakai header
`X-Api-Key`, gunakan key pada header tersebut.

Terapkan pembacaan key pada fungsi request bersama yang digunakan
`fetchTopHeadlines` dan `searchArticles`. Jangan membuat request baru
atau menduplikasi parsing JSON.

**Langkah 6: Atur `.gitignore`**

Tambahkan aturan berikut di `.gitignore` pada root proyek:

``` gitignore
# Local environment configuration
.env
.env.*
!.env.example
```

Aturan ini mengabaikan `.env` dan file konfigurasi lokal lain yang
diawali `.env.`, tetapi tetap mengizinkan `.env.example`.

Catatan: - `.gitignore` tidak otomatis menghapus file yang sudah pernah
di-commit. - Jika key pernah terunggah, beri tahu guru/pengelola
repository dan cabut atau rotasi key tersebut. - Penanganan riwayat Git
perlu dilakukan dengan pendampingan.

**Langkah 7: Buat `.env.example`**

Buat `.env.example` di root proyek:

``` env
NEWS_API_KEY=your_news_api_key_here
```

File ini boleh dibagikan ke GitHub sebagai template. Anggota tim dapat
menyalinnya menjadi `.env` lalu mengisi key milik masing-masing. Jangan
pernah memasukkan key asli ke `.env.example`.

### 7.4 Tugas mandiri

1.  Pasang `flutter_dotenv`.
2.  Buat `.env` dan pindahkan API key dari `NewsService` ke file
    tersebut.
3.  Pastikan `main.dart` memuat `.env` sebelum `runApp()`.
4.  Ubah `NewsService` agar membaca `NEWS_API_KEY` melalui `dotenv.env`.
5.  Tambahkan `.env` ke `.gitignore`.
6.  Buat `.env.example` tanpa key asli.
7.  Uji berita utama, kategori, pencarian API, dan halaman detail.
8.  Periksa `git status` dan pastikan `.env` tidak akan ikut di-commit.

### 7.5 Troubleshooting

  ----------------------------------------------------------------------------------
  Gejala                              Pemeriksaan menurut panduan
  ----------------------------------- ----------------------------------------------
  `NEWS_API_KEY` kosong               Periksa nama variabel di `.env`, penulisan
                                      key, dan pemuatan dotenv sebelum `runApp()`.

  `.env` tidak ditemukan              Pastikan file ada di root proyek dan terdaftar
                                      sebagai asset di `pubspec.yaml`.

  Error saat startup                  Periksa `dotenv.load`,
                                      `WidgetsFlutterBinding.ensureInitialized()`,
                                      dan konfigurasi asset.

  API mengembalikan 401               Periksa key dan header request.

  `.env` muncul di Git status         Periksa aturan `.gitignore` dan apakah file
                                      pernah dilacak Git.

  Teman tidak bisa menjalankan        `.env` memang tidak ikut di-clone. Salin
  aplikasi                            `.env.example` menjadi `.env` dan isi key
                                      sendiri.
  ----------------------------------------------------------------------------------

### 7.6 Pengujian dan kriteria keberhasilan

Pengujian: - \[ \] Berita utama berhasil dimuat. - \[ \] Kategori tetap
bekerja. - \[ \] Pencarian API tetap bekerja. - \[ \] Halaman detail
tetap bekerja. - \[ \] Aplikasi membaca konfigurasi saat startup. - \[
\] `git status` diperiksa. - \[ \] `.env` tidak masuk commit baru.

Kriteria keberhasilan: - \[ \] API key tidak lagi ditulis langsung di
file Dart. - \[ \] Aplikasi membaca konfigurasi saat startup. - \[ \]
News App tetap dapat mengambil berita dan menjalankan fitur
sebelumnya. - \[ \] `.env` diabaikan Git dan tidak masuk commit baru. -
\[ \] `.env.example` tersedia tanpa nilai rahasia. - \[ \] Siswa
memahami bahwa `.env` bukan perlindungan rahasia yang kuat untuk
aplikasi produksi.

### 7.7 Refleksi

1.  Mengapa API key sebaiknya tidak ditulis langsung di file service?
2.  Apa fungsi `flutter_dotenv`?
3.  Apa perbedaan `.env` dan `.env.example`?
4.  Mengapa `.env` ditambahkan ke `.gitignore`?
5.  Apakah `.env` membuat API key benar-benar aman dari pengguna
    aplikasi Flutter? Jelaskan.
6.  Bagaimana backend membantu melindungi API key pada aplikasi
    produksi?
7.  Apa yang harus dilakukan jika API key terlanjur diunggah ke
    repository publik?

------------------------------------------------------------------------

## 8. Checklist akhir seluruh proyek

Gunakan checklist ini sebagai rekap. Jangan tandai selesai sebelum
memeriksa kode dan menjalankan pengujian.

### Fondasi API dan daftar berita

-   [ ] `Article` memiliki field sesuai panduan.
-   [ ] JSON dipetakan melalui `Article.fromJson()`.
-   [ ] `NewsService` mengambil berita dari NewsAPI.
-   [ ] `NewsPage` menampilkan berita API.
-   [ ] Loading, error, data kosong, dan gambar gagal dimuat ditangani.

### Kategori dan pencarian

-   [ ] Kategori berita dapat dipilih.
-   [ ] Pencarian API mengirim query yang benar.
-   [ ] Input pencarian kosong ditangani.
-   [ ] Filter lokal mencari pada judul tanpa request baru.
-   [ ] Controller dibersihkan melalui satu `dispose()`.

### Detail dan navigasi

-   [ ] Halaman detail menampilkan gambar, judul, sumber, tanggal, dan
    deskripsi.
-   [ ] Objek `Article` yang dipilih dikirim ke halaman detail.
-   [ ] Konten detail dapat digulir.
-   [ ] Gambar detail memiliki fallback.
-   [ ] Navigasi kembali berfungsi.

### Integrasi dan pengujian

-   [ ] Future disimpan di state, bukan dibuat berulang di builder.
-   [ ] Retry sesuai kategori atau query aktif.
-   [ ] Error HTTP dan error API ditangani.
-   [ ] Minimal delapan skenario pengujian Pertemuan 4 dicatat.
-   [ ] Hasil uji mencerminkan kondisi sebenarnya.

### Konfigurasi API key

-   [ ] `flutter_dotenv` terpasang.
-   [ ] `.env` berada di root dan terdaftar sebagai asset.
-   [ ] `.env` dimuat sebelum `runApp()`.
-   [ ] `NewsService` membaca `NEWS_API_KEY` dari dotenv.
-   [ ] `.env` dan file `.env.*` diabaikan Git.
-   [ ] `.env.example` tersedia tanpa key asli.
-   [ ] `git status` sudah diperiksa.

------------------------------------------------------------------------

## 9. Aturan kerja untuk AI coding agent

Saat menerima instruksi untuk mengerjakan salah satu pertemuan:

1.  Baca bagian pertemuan terkait dalam dokumen ini.
2.  Baca PDF asli pertemuan tersebut di `docs/panduan/` untuk
    memverifikasi detail.
3.  Periksa kondisi proyek saat ini sebelum mengubah file.
4.  Laporkan persyaratan yang sudah terpenuhi, sebagian terpenuhi, dan
    belum terpenuhi.
5.  Buat rencana singkat yang hanya mencakup ruang lingkup pertemuan
    yang diminta.
6.  Jangan mengerjakan pertemuan selanjutnya tanpa instruksi pengguna.
7.  Setelah implementasi, jalankan pemeriksaan yang relevan dan laporkan
    hasil aktual.
8.  Laporkan file yang berubah, fitur yang dibuat, hasil pengujian, dan
    hal yang belum selesai.
9.  Jangan pernah mengklaim pengujian berhasil jika tidak dijalankan.

**Batas kewenangan:** Pengguna adalah pengambil keputusan. Jangan
melakukan perubahan kode, file, konfigurasi, atau dependency sebelum
pengguna meminta implementasi secara jelas.

------------------------------------------------------------------------

## 10. Referensi sumber

Dokumen ini dirangkum dari lima PDF panduan guru berikut. Simpan PDF
asli di folder `docs/panduan/`:

1.  `Panduan Belajar Mandiri News App Pertemuan 1.pdf`
2.  `Panduan Belajar Mandiri News App Pertemuan 2.pdf`
3.  `Panduan Belajar Mandiri News App Pertemuan 3.pdf`
4.  `Panduan Belajar Mandiri News App Pertemuan 4.pdf`
5.  `Panduan Belajar Mandiri News App Pertemuan 5.pdf`

Referensi yang disebutkan dalam panduan: - NewsAPI documentation:
https://newsapi.org/docs

Jika nama file PDF di folder proyek menggunakan nama yang berbeda,
sesuaikan nama referensinya. PDF asli tetap menjadi rujukan untuk kode
contoh, detail langkah, dan instruksi lengkap.
