# Company Portal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Membangun portal dan dashboard khusus role Perusahaan pada aplikasi PathFinder untuk mempublikasikan lowongan magang (dengan formulir lengkap) dan mengelola daftar kandidat/pelamar dengan status seleksi.

**Architecture:** Menerapkan Clean Architecture modular dalam folder `lib/features/company/` yang terbagi atas domain models (`JobPosting`, `CandidateApplication`), mock data provider, formulir input bergaya modular seperti `login_form.dart`, widget tab & card bergaya `dashboard_page.dart`, serta halaman utama `company_dashboard_page.dart` dengan navigasi `IndexedStack` 4 tab. Integrasi routing hanya mendaftarkan konstanta `/company-dashboard` di `lib/app/router.dart` tanpa memodifikasi rute atau halaman existing lainnya.

**Tech Stack:** Flutter 3+, Dart, `google_fonts: ^6.2.1` (GoogleFonts.sen), `go_router: ^14.8.1`, `flutter_test`.

**Spec:** [`docs/superpowers/specs/2026-10-26-company-portal-design.md`](file:///Users/femasakbarfathurohim/Coolyeah/PBL/path_finder/docs/superpowers/specs/2026-10-26-company-portal-design.md)

## Global Constraints

- Style kode: Modular dan terpisah seperti [`login_page.dart`](file:///Users/femasakbarfathurohim/Coolyeah/PBL/path_finder/lib/features/auth/presentation/pages/login_page.dart) & [`login_form.dart`](file:///Users/femasakbarfathurohim/Coolyeah/PBL/path_finder/lib/features/auth/presentation/widgets/login_form.dart) (input background `#F0F5FA`, label `GoogleFonts.sen` 13px `#32343E`, rounded corners 10-12px).
- UI/UX: Selaras dengan [`dashboard_page.dart`](file:///Users/femasakbarfathurohim/Coolyeah/PBL/path_finder/lib/features/dashboard/presentation/pages/dashboard_page.dart) (latar `#F8FAFC`, aksen `#2373F4`, border `#E2E8F0`, card shadow halus).
- Integritas: Jangan mengubah halaman existing atau `initialLocation` di `lib/app/router.dart` agar tester bisa mengubahnya secara manual saat pengujian.
- Git Branch: Bekerja dan commit secara bertahap pada branch `feature/company-portal`.

## Review Focus

1. Kuota magang bernilai 0 atau negatif: Form validator harus menolak angka 0 atau non-angka dan meminta angka positif.
2. Filter status kandidat menghasilkan daftar kosong: Tab kandidat harus menampilkan empty state message yang bersahabat dan tidak crash.
3. Form posting disubmit dengan field spasi kosong: Validator `trim().isEmpty` pada setiap field wajib mencegah data kosong terkirim.
4. Input teks panjang pada deskripsi atau keahlian: Card dan list view harus scrollable dan membungkus teks (*wrap/ellipsis*) tanpa RenderFlex overflow.
5. Perubahan status kandidat dari bottom sheet: State harus terupdate seketika (*instant UI feedback*) dan label badge status berubah warna sesuai status baru.

---

### Task 1: Domain Models & Initial Mock Dataset

**Files:**
- Create: `lib/features/company/domain/models/job_posting.dart`
- Create: `lib/features/company/domain/models/candidate_application.dart`
- Create: `lib/features/company/data/company_mock_data.dart`
- Test: `test/features/company/domain_models_test.dart`

**Interfaces:**
- Produces:
  - `class JobPosting`: `id`, `title`, `field`, `quota`, `executionPeriod`, `description`, `facilities`, `requiredSkills`, `companyName`, `location`, `applicantsCount`, `isActive`, `createdAt`, `copyWith()`
  - `class CandidateApplication`: `id`, `jobId`, `jobTitle`, `candidateName`, `university`, `major`, `appliedDate`, `matchScore`, `status`, `notes`, `copyWith()`
  - `class CompanyMockData`: `static List<JobPosting> getInitialJobs()`, `static List<CandidateApplication> getInitialCandidates()`

- [ ] **Step 1: Write the failing unit tests for models & mock data**
  Create `test/features/company/domain_models_test.dart` testing instantiation of `JobPosting` and `CandidateApplication`, `copyWith` mutation, and verifying `CompanyMockData` provides non-empty default records.

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/features/company/domain_models_test.dart`
  Expected: FAIL (files/classes not found).

- [ ] **Step 3: Implement domain models and mock data**
  Implement `job_posting.dart`, `candidate_application.dart`, and `company_mock_data.dart` with all specified properties.

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/company/domain_models_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add lib/features/company/domain/ lib/features/company/data/ test/features/company/domain_models_test.dart
  git commit -m "feat(company): add domain models and initial mock dataset"
  ```

---

### Task 2: Company Header & Navigation Bar Widgets

**Files:**
- Create: `lib/features/company/presentation/widgets/company_app_bar.dart`
- Create: `lib/features/company/presentation/widgets/company_bottom_navbar.dart`
- Test: `test/features/company/company_navbar_test.dart`

**Interfaces:**
- Consumes: None (UI widgets).
- Produces:
  - `CompanyAppBar({required String companyName, VoidCallback? onNotificationTap}) extends StatelessWidget implements PreferredSizeWidget`
  - `CompanyBottomNavbar({required int currentIndex, required ValueChanged<int> onTap}) extends StatelessWidget`

- [ ] **Step 1: Write the widget test for CompanyAppBar and CompanyBottomNavbar**
  Create `test/features/company/company_navbar_test.dart` testing rendering of 4 navigation items (Ringkasan, Buat Lowongan, Pelamar, Profil) and triggering `onTap`.

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/features/company/company_navbar_test.dart`
  Expected: FAIL.

- [ ] **Step 3: Implement CompanyAppBar and CompanyBottomNavbar**
  Implement widgets adhering to `GoogleFonts.sen`, background `#FFFFFF`, active color `#2373F4`, inactive `#A0A5BA`, matching `DashboardBottomNavbar` aesthetics.

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/company/company_navbar_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add lib/features/company/presentation/widgets/ test/features/company/company_navbar_test.dart
  git commit -m "feat(company): add app bar and bottom navigation bar widgets"
  ```

---

### Task 3: Job Posting Form & Tab (`PostJobForm` & `PostJobTab`)

**Files:**
- Create: `lib/features/company/presentation/widgets/forms/post_job_form.dart`
- Create: `lib/features/company/presentation/widgets/tabs/post_job_tab.dart`
- Test: `test/features/company/post_job_form_test.dart`

**Interfaces:**
- Consumes: `JobPosting` from `lib/features/company/domain/models/job_posting.dart`
- Produces:
  - `PostJobForm({required ValueChanged<JobPosting> onSubmitSuccess}) extends StatefulWidget`
  - `PostJobTab({required ValueChanged<JobPosting> onJobCreated}) extends StatelessWidget`

- [ ] **Step 1: Write widget test for PostJobForm**
  Create `test/features/company/post_job_form_test.dart` to verify validation errors when submitting blank inputs, and verify successful submission calls `onSubmitSuccess` with a valid `JobPosting`.

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/features/company/post_job_form_test.dart`
  Expected: FAIL.

- [ ] **Step 3: Implement PostJobForm and PostJobTab**
  Implement form with exactly 7 specified fields:
  1. Judul Posisi (`judulPosisiController`)
  2. Bidang (`bidangController`)
  3. Kuota Anak Magang (`kuotaController`, numeric validator `> 0`)
  4. Tanggal Pelaksanaan (`tanggalPelaksanaanController`, e.g. "1 Januari 2027 s.d. 31 Juli 2027")
  5. Deskripsi (`deskripsiController`, multiline)
  6. Fasilitas Apa Saja (`fasilitasController`, multiline)
  7. Keahlian yang Dibutuhkan (`keahlianController`, multiline)
  Style matching `LoginForm` (inputs fill `#F0F5FA`, label Sen 13px `#32343E`, submit button `#2373F4`).

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/company/post_job_form_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add lib/features/company/presentation/widgets/forms/ lib/features/company/presentation/widgets/tabs/post_job_tab.dart test/features/company/post_job_form_test.dart
  git commit -m "feat(company): add post job form and tab with validation"
  ```

---

### Task 4: Job Card & Company Home Tab (`CompanyJobCard` & `CompanyHomeTab`)

**Files:**
- Create: `lib/features/company/presentation/widgets/cards/company_job_card.dart`
- Create: `lib/features/company/presentation/widgets/tabs/company_home_tab.dart`
- Test: `test/features/company/company_home_tab_test.dart`

**Interfaces:**
- Consumes: `JobPosting`, `CandidateApplication`
- Produces:
  - `CompanyJobCard({required JobPosting job, VoidCallback? onTap}) extends StatelessWidget`
  - `CompanyHomeTab({required List<JobPosting> jobs, required List<CandidateApplication> candidates, required VoidCallback onNavigateToPostJob, required VoidCallback onNavigateToCandidates}) extends StatelessWidget`

- [ ] **Step 1: Write test for CompanyJobCard and CompanyHomeTab**
  Create `test/features/company/company_home_tab_test.dart` testing metric counters (Total Lowongan, Total Pelamar) and job card listings.

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/features/company/company_home_tab_test.dart`
  Expected: FAIL.

- [ ] **Step 3: Implement CompanyJobCard and CompanyHomeTab**
  Design with statistics cards (Total Lowongan, Pelamar Masuk, Tahap Wawancara), Quick Action button to Post Job, and list of jobs using `CompanyJobCard`.

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/company/company_home_tab_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add lib/features/company/presentation/widgets/cards/company_job_card.dart lib/features/company/presentation/widgets/tabs/company_home_tab.dart test/features/company/company_home_tab_test.dart
  git commit -m "feat(company): add company job card and home tab"
  ```

---

### Task 5: Candidate Card & Candidate Review Tab (`CandidateCard` & `CandidatesTab`)

**Files:**
- Create: `lib/features/company/presentation/widgets/cards/candidate_card.dart`
- Create: `lib/features/company/presentation/widgets/tabs/candidates_tab.dart`
- Test: `test/features/company/candidates_tab_test.dart`

**Interfaces:**
- Consumes: `CandidateApplication`
- Produces:
  - `CandidateCard({required CandidateApplication candidate, required ValueChanged<String> onStatusChanged}) extends StatelessWidget`
  - `CandidatesTab({required List<CandidateApplication> candidates, required void Function(String candidateId, String newStatus) onUpdateStatus}) extends StatefulWidget`

- [ ] **Step 1: Write test for CandidatesTab**
  Create `test/features/company/candidates_tab_test.dart` testing horizontal filter chips ("Semua", "Seleksi Berkas", "Wawancara", "Diterima", "Ditolak"), list filtering, and status change callback.

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/features/company/candidates_tab_test.dart`
  Expected: FAIL.

- [ ] **Step 3: Implement CandidateCard and CandidatesTab**
  Implement status badge colors (Biru: Seleksi Berkas, Oranye: Wawancara, Hijau: Diterima, Merah: Ditolak), AI match badge, bottom sheet for status update, and empty state when filter has no matches.

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/company/candidates_tab_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add lib/features/company/presentation/widgets/cards/candidate_card.dart lib/features/company/presentation/widgets/tabs/candidates_tab.dart test/features/company/candidates_tab_test.dart
  git commit -m "feat(company): add candidate card and review tab with status filters"
  ```

---

### Task 6: Company Profile Tab, Main Dashboard Page, & Route Registration

**Files:**
- Create: `lib/features/company/presentation/widgets/tabs/company_profile_tab.dart`
- Create: `lib/features/company/presentation/pages/company_dashboard_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/company/company_dashboard_page_test.dart`

**Interfaces:**
- Consumes: All tabs (`CompanyHomeTab`, `PostJobTab`, `CandidatesTab`, `CompanyProfileTab`), `CompanyAppBar`, `CompanyBottomNavbar`, `CompanyMockData`
- Produces:
  - `CompanyDashboardPage({super.key, int initialIndex = 0}) extends StatefulWidget`
  - Constant `AppRoutePaths.companyDashboard = '/company-dashboard'` in `lib/app/router.dart`

- [ ] **Step 1: Write integration widget test for CompanyDashboardPage and routing**
  Create `test/features/company/company_dashboard_page_test.dart` testing 4-tab switching, creating a job from `PostJobTab` and observing it on `CompanyHomeTab`, and updating candidate status.

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/features/company/company_dashboard_page_test.dart`
  Expected: FAIL.

- [ ] **Step 3: Implement CompanyProfileTab, CompanyDashboardPage, and register route in router.dart**
  Implement `CompanyProfileTab` (company info, legalities, logout action).
  Implement `CompanyDashboardPage` managing in-memory state of jobs and candidates, switching tabs via `IndexedStack`.
  Register `AppRoutePaths.companyDashboard = '/company-dashboard'` in `lib/app/router.dart` without touching existing routes or initialLocation.

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/company/company_dashboard_page_test.dart`
  Expected: PASS.

- [ ] **Step 5: Run full test suite and flutter analyze**
  Run: `flutter test` and `flutter analyze` to ensure 0 errors and 100% clean passes.

- [ ] **Step 6: Commit**
  ```bash
  git add lib/features/company/ lib/app/router.dart test/features/company/
  git commit -m "feat(company): integrate company dashboard page and register route"
  ```
