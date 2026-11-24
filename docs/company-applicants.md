# Company applicants integration

Verified locally: 2026-11-24. Vault's seven core files unavailable; durable session note stored here instead.

- Company applicants tab uses generated Riverpod providers, authenticated Dio, domain repository contract, and remote repository implementation. Other company tabs intentionally remain mock.
- GET `/api/mitra/applications`: optional `job_id`, `page`, `size=10`; load-more pagination, retry and pull-to-refresh. Job selector loads all pages of GET `/api/mitra/jobs`, including vacancies without applicants. Status chips filter loaded records only (explicit UI notice).
- Expected list envelope: `success`, `data` array, optional `paging.total_page`; rows contain `id`, `job_id`, `status`, `created_at`, nested `job.id/title`, nested `mahasiswa.name/email/cv`. Missing CV disables preview. No invented education or match scores displayed.
- PATCH `/api/mitra/applications/:id/status` sends only `accepted` or `rejected`. Both controller and UI reject non-pending transitions. Confirmation precedes final decision; requests disable decisions while pending; errors preserve existing data/status for retry. Server remains authority for concurrent decisions.
- Fake structured CV model/sheet/mock CV data removed. `url_launcher` opens original HTTP(S) CV URL in external browser/document app. No third-party viewer, no app bearer token forwarded. URLs must be independently accessible (e.g. signed URL or browser session); bearer-only files need backend download support. Missing/invalid URL and launch failure handled.
- Auth session required; existing `AuthUser.isMitra` role normalization reused. Session changes rebuild providers.
- Contract limitation: inspected local `pathfinder-be` contains no application routes/models. Application nesting follows mobile API docs; paging and student CV naming follow backend Go models. Confirm application envelope with deployed backend before release. No live backend tests performed.
- Local checks: Riverpod generation, Flutter analyzer, company widget/repository/controller tests. Generator warns installed analyzer language support trails Dart SDK; no dependency-wide upgrade attempted.
