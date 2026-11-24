# Company jobs — active API integration

Verified locally: 2026-11-24.

- Generated `companyJobsRepositoryProvider` selects `DioCompanyJobsRepository` with authenticated `dioClientProvider`. No production fake store, generated local IDs, fallback records or simulated success.
- Authenticated mitra session required for list/create. List watches auth through guard; create state watches auth and checks session before submission. Existing generated auth controller remains keep-alive.
- GET `/api/mitra/jobs?page=1&size=10&status=aktif`; backend scopes ownership. Pagination reads `paging.page`, `total_page`, `total_item`. Home supports loading, empty/error states, retry, pagination and pull-to-refresh.
- POST `/api/mitra/jobs`: `title`, `category`, `description`, `location`, `work_type`, `required_skills`, `optional_skills`, `source_url`, `status: aktif`. IDs/company labels come from server response, not profile mock.
- Creation validates trimmed title (3–150 Unicode code points), description (20–10000), location (1–255), work type (1–50), eight official categories, required skills (1–50), optional skills (0–50), each skill (1–100), optional HTTP(S) URL with host (up to 1000). Contract reference: local backend job model/entity/usecase/repository/controller.
- Duplicate submission blocked while pending. Only successful server response clears form, returns home, and invalidates jobs/applicants job selector. Failure preserves draft and allows retry; adapter maps errors with `ErrorMapper`.
- Company profile remains existing unrelated local mock; untouched. Editing profile does not rewrite job company labels. No edit/delete/close workflow added. Unsupported quota/period/facilities fields excluded from form contract.

## Session validation

Riverpod generation, `flutter analyze`, full `flutter test`, and `git diff --check` run locally. Repository tests intercept Dio; widget/controller tests inject test-only fakes. Coverage includes active-list query/paging, creation payload/validation, server failure, duplicate submission, refresh invalidation, stale-page protection, missing-session rejection and narrow layout. Default-provider regression test verifies shared Dio repositories. No live authenticated backend or device/visual validation performed.

Generator warns Dart SDK language version 3.13.0 exceeds installed analyzer support 3.11.0; no dependency upgrade attempted. Configured external vault's seven core files unavailable at specified path; durable session update recorded in feature docs instead. Existing jobs work preserved. No commit/push.
