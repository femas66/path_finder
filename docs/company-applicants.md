# Company applicants — active API integration

Verified locally: 2026-11-24.

- Generated Riverpod providers select `ApplicantsRepository` with authenticated `dioClientProvider`.
 No production fake repository or fallback to demo data/success.
- Authenticated mitra session required before loading applicants or job selector. Session changes rebuild providers; existing keep-alive generated auth controller unchanged.
- GET `/api/mitra/applications`: optional `job_id`, `page`, `size=10`; pagination, retry and pull-to-refresh. Job selector loads all pages of GET `/api/mitra/jobs`, including vacancies without applicants. Status chips filter loaded records only, with explicit UI notice.
- Expected envelope: `success`, `data` array, optional `paging.total_page`; rows contain `id`, `job_id`, `status`, `created_at`, nested `job.id/title`, nested `mahasiswa.name/email/cv`. No invented education or match scores displayed.
- PATCH `/api/mitra/applications/:id/status` sends `
accepted` or `rejected`. UI and controller reject non-pending transitions; confirmation precedes final decision. In-flight requests disable decisions; errors preserve loaded status for retry. Backend must enforce ownership and concurrent terminal-state rules.
- `url_launcher` opens original HTTP(S) CV URL externally. Missing URL disables preview; invalid URL and launch failures show error. No fake PDF, third-party viewer or bearer token forwarded. URL must be independently accessible (signed URL/browser session); bearer-only files require backend download support.
- Local backend lacks application routes/models. Application nesting follows mobile API docs; confirm deployed envelope before release. No live authenticated API or device/visual validation performed.
- Company profile remains existing unrelated local mock; untouched. Jobs list/create now use active API integration; see `company-jobs.md`.

## Session validation

Riverpod generation, `flutter analyze`, full `flutter test`, and `git diff --check` run locally. Tests inject fakes or intercept Dio; not live backend tests. Production-default regression test checks both repositories use shared Dio. Generator warns Dart SDK language version 3.13.0 exceeds installed analyzer support 3.11.0; no dependency upgrade attempted.

Configured external vault's seven core files do not exist at specified path. Durable session update recorded here and in `company-jobs.md` instead. No commit/push.
