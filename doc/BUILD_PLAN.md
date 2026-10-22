# Stargazer — Hand-Built Roadmap (Revision 2)

You write all code by hand. This is a roadmap only: no implementation code, only file names, class names, method signatures and endpoint paths in prose.

How to use this plan: work top to bottom. Each step is 15-60 minutes and ends with either a passing test or a running screen. Do not start the next step if the current `Verify` fails.

> Advanced terms, defined once:
> **Vertical slice** = one full feature built thinly from network/storage through logic to UI, so the app still runs after each slice.
> **Either** = a container from `fpdart` that holds either a `Failure` (left, error) or a success value (right). It forces you to handle errors.
> **Use case** = one user action in the domain layer, e.g. SearchRepositories. It has one method `call`.
> **Repository pattern** = a domain contract that hides where data comes from. Data sources implement it.
> **Adapter (Hive)** = generated code that tells Hive how to save a class to local storage.
> **Shared kernel** = a small set of domain types that every feature may depend on, owned by no single feature.
> **CancelToken (Dio)** = a handle that lets you cancel an in-flight HTTP request. Cancelling stops the response from being delivered and frees the request slot.

### What changed in Revision 2

1. **Watchers corrected:** the `Watching` stat card uses `subscribers_count`, never `watchers_count`. In REST API v3, `watchers_count` is a legacy field identical to `stargazers_count`.
2. **README simplified:** `GET /repos/{owner}/{repo}/readme` is called with `Accept: application/vnd.github.raw+json`, which returns raw UTF-8 Markdown. No manual base64 decoding and no newline stripping.
3. **Shared entities moved:** `GithubRepo` and `GithubUser` now live in `lib/core/domain/entities/`. Features must not import another feature's domain entities.
4. **Hive injected through Riverpod:** the saved box is opened asynchronously in `main()` before `runApp()`, then injected with `ProviderScope(overrides: [savedBoxProvider.overrideWithValue(savedBox)])`. Providers get the box synchronously.
5. **Search cancellation:** search data sources accept a Dio `CancelToken`; providers cancel the previous search request together with the 400ms debounce to protect the 10 requests/minute search limit and prevent stale responses.
6. **Rate-limit reset parsed correctly:** `X-RateLimit-Reset` is a UTC Unix timestamp in **seconds**. Convert with `DateTime.fromMillisecondsSinceEpoch(resetSeconds * 1000, isUtc: true)` and show a countdown.

Existing skeleton: `lib/core` has empty folders including `netwrok/` (typo for `network/`), `lib/features/explore|profile|repository_details|saved` each have empty `data|domain|presentation`. `lib/main.dart` is still the Flutter counter template. `test/` has only `widget_test.dart`. Delete or replace template code as you go.

---

## 0. Design-to-data map (from the 3 attached images)

Studied all 3 screens. Where the image is unclear the table says `unclear` instead of guessing.

Entities:
- Shared core entities: `GithubRepo`, `GithubUser`.
- Feature entities: `RepoDetails` (extends `GithubRepo`), `RepoLanguages`, `ReadmeDoc`, `PullRequestInfo`, `SavedRepo`.

Formatting note: counts like `104k`, `15.2k`, `83.2%` are **not** from the API. The API gives raw integers (for example `stargazers_count: 104523`). Format them locally in `lib/core/utils/date_formatter.dart` or a dedicated count formatter.

### 0A. Screen 1 — Explore / Search

| Visible UI element | Data field it shows | Source | Entity field that will hold it |
|---|---|---|---|
| Header title `Explore` + cat icon | static text | static | none |
| Top-right filter/sliders button | unclear action (filter? sort options?). Image too small. | unclear — treat as static placeholder that opens a bottom sheet later | none — local UI state if you implement it |
| Search field `Search repositories, people...` + `/` hint | user typed query | local input state, then calls search APIs | query string passed to use cases, not stored |
| Filter chips `All / Repositories / People` | selected tab | local UI state | none |
| Empty state icon + `Good things start with curiosity.` + `Find your next idea...` | static illustration + text | static | none — show only when query is empty and no trending data is loaded |
| Section header `Trending repositories` + dropdown `This week` | section title + time-range selector | static title + local state for range. Data has **no official endpoint — FLAG**. Workaround: `GET /search/repositories` with a query like `created:>YYYY-MM-DD`, sorted by stars. | list of `GithubRepo` from the workaround |
| Repo card owner `shadcn /` | repo owner login, field `owner.login` | `GET /search/repositories` item `owner.login` | `GithubRepo.ownerLogin` |
| Repo card name `ui`, `next.js` (bold) | repo short name, field `name` (full is `full_name` like `shadcn/ui`) | same search item `name` / `full_name` | `GithubRepo.name`, `GithubRepo.fullName` |
| External-arrow icon top-right of card | open-in-browser action | static action using `html_url` | `GithubRepo.htmlUrl` |
| Repo description `Beautifully designed...` | field `description` | same search item `description` — **nullable, can be null** | `GithubRepo.description` (nullable String) |
| Language dot + `TypeScript` pill | field `language` | same search item `language` — **nullable** | `GithubRepo.language` (nullable String) |
| Star icon + `104k`, `134k` | field `stargazers_count` formatted | same search item `stargazers_count` | `GithubRepo.stargazersCount` (int) |
| Section header `People to know` + `See all` | section title + navigation link | static + **FLAG: no official endpoint**. Workaround: `GET /search/users` with e.g. `followers:>1000`, or reuse trending repo owners. | list of `GithubUser` from the workaround |
| Person avatar (black circle) | field `avatar_url` | `GET /search/users` item `avatar_url`, shown with `cached_network_image` | `GithubUser.avatarUrl` |
| Person name `shadcn` | field `login` (search returns less than a full profile) | `GET /search/users` item `login` | `GithubUser.login` |
| Person bio `Building things for the web.` | field `bio` | search user item may include `bio`, but full `GET /users/{username}` is reliable — **nullable** | `GithubUser.bio` (nullable) |
| Blue `->` arrow on person card | go to profile | navigation using `login` | `GithubUser.login` as route param |
| Footer `A small window into a world of open source.` | static | static | none |
| Bottom nav `Search / Saved / Profile` | navigation | static + `go_router` state | none |

**Explore FLAGS:**
- Trending + `This week` + People-to-know disagree with the API. There is verified **no** REST trending or explore endpoint and **no** REST pinned/people endpoint. Fake them with search. Document this in the UI (e.g. subtitle `Trending via stars this week`) or reviewers will think it is broken.
- Search user items have fewer fields than a profile. Do not show follower counts on Explore person cards — the API search item does not reliably include them.

### 0B. Screen 2 — User Profile

| UI element | Data field | Source | Entity field |
|---|---|---|---|
| App bar `< Profile` + `...` menu | back + overflow | navigation/static. The `...` action is unclear in the image — say `unclear`, treat it as a placeholder (share/block). | none |
| Large avatar | field `avatar_url` | `GET /users/{username}` field `avatar_url` | `GithubUser.avatarUrl` |
| Name `shadcn` (large bold) | field `name`, fallback to `login` if null | `GET /users/{username}` field `name` — **nullable** | `GithubUser.name` (nullable), fallback logic in presentation |
| Handle `@shadcn` | field `login` | same, field `login` | `GithubUser.login` |
| `</>` badge next to name | unclear in image (hireable? type? verified dev?). Say `unclear` — do not map. | unverified | none — leave as static decoration or remove |
| Bio `Building things...` | field `bio` | same, field `bio` — **nullable** | `GithubUser.bio` (nullable) |
| Pin icon + `New York` | field `location` | same, field `location` — **nullable** | `GithubUser.location` (nullable) |
| Link icon + `shadcn.com` (blue) | field `blog` | same, field `blog` — **nullable, often without https** | `GithubUser.blog` (nullable) |
| `15.2k followers` | field `followers` (int) formatted | same, field `followers` | `GithubUser.followersCount` (int) |
| `12 following` | field `following` (int) | same, field `following` | `GithubUser.followingCount` (int) |
| `Follow` button (light blue) | follow action | **FLAG: cannot work unauthenticated**. A real follow needs auth `PUT /user/following/{username}`. Without a token, make it a disabled placeholder or a local-only fake. | none, or a local bool if you fake it |
| Share icon button next to Follow | share profile | static action using `html_url` | `GithubUser.htmlUrl` |
| Tabs `Overview | Repositories 42 | Stars 128` | counts: `public_repos` for 42. Stars 128 is **FLAG**: the API user object has **no** total-stars field. Compute it by summing `stargazers_count` of repos, show the starred-list length, or hide the count. | `GithubUser.publicReposCount` from `public_repos`. Stars count = derived, not direct; keep it in UI state, not the entity |
| Section `Pinned repositories` + pin icon | pinned list | **FLAG: no REST endpoint (GraphQL only `pinnedItems`)**. Decision: show top-starred repos instead, labeled `Top repositories`. | list of `GithubRepo` sorted by stars from `GET /users/{username}/repos` |
| Pinned repo cards (same fields as Explore: owner/name/description/language/stars/arrow) | `full_name`, `description` (nullable), `language` (nullable), `stargazers_count` | `GET /users/{username}/repos` | same `GithubRepo` fields as above |
| Footer `Part of the community since March 2013` | field `created_at` formatted to `Month Year` | `GET /users/{username}` field `created_at` | `GithubUser.createdAt` (DateTime) |
| Bottom nav (Profile active) | navigation | static | none |

### 0C. Screen 3 — Repository Details

| UI element | Data field | Source | Entity field |
|---|---|---|---|
| App bar `< Repository` + share icon | back + share | navigation/static using `html_url` | `GithubRepo.htmlUrl` |
| Small avatar + `shadcn / ui` | `owner.login` + `name` | `GET /repos/{owner}/{repo}` fields `owner.login`, `name` | `GithubRepo.ownerLogin`, `GithubRepo.name` |
| `Public` pill | field `private` inverted (`private:false` = Public) | same, field `private` + `visibility` | `GithubRepo.isPrivate` (bool) |
| Description `Beautifully designed...` | field `description` — nullable | same, field `description` | `GithubRepo.description` (nullable) |
| Topic chips `react, tailwindcss, components` | field `topics` (array) | same, field `topics` | `GithubRepo.topics` (list) |
| Stats card `104k Stars` | `stargazers_count` | same | `GithubRepo.stargazersCount` |
| Stats card `7.1k Forks` | `forks_count` | same | `GithubRepo.forksCount` |
| Stats card `620 Watching` | `subscribers_count` (actual watchers) | `GET /repos/{owner}/{repo}` field `subscribers_count`. **Do not use `watchers_count`**: it is a legacy field identical to `stargazers_count`, so it would duplicate the Stars number. | `GithubRepo.subscribersCount` (int) |
| `Star repository` button | star action | **FLAG: a real star needs auth `PUT /user/starred/{owner}/{repo}`**. Unauthenticated = show the count only, or fake local state. | local bool + `GithubRepo.stargazersCount` |
| Bookmark/save icon button | save locally | **local only, Hive**, not GitHub API | `SavedRepo` (Hive object with id, fullName, etc.) |
| Tabs `Overview | Code | Issues 1.2k | Pull requests` | `open_issues_count` for the Issues count (it can include pull requests — FLAG). The Code tab has no REST file tree in scope; the Pull requests tab needs a separate call. Recommend Overview only for v1, others as placeholders linking to `html_url`. | `GithubRepo.openIssuesCount` + `PullRequestInfo` list if you implement the PR tab |
| README card header `README.md` + file icon + arrow | label + link | **FLAG:** the raw README response is plain Markdown and does not include `name`, `path` or `html_url`. Use a static `README.md` label and derive the link from `GithubRepo.htmlUrl` (append `#readme`), or make a second default-JSON call only if you truly need metadata. | `ReadmeDoc.fileName` (static/derived), `ReadmeDoc.htmlUrl` (derived) |
| README title `Build your component library.` + paragraphs | raw UTF-8 Markdown body | `GET /repos/{owner}/{repo}/readme` with header `Accept: application/vnd.github.raw+json`. Render directly with `flutter_markdown_plus`; **no base64 decode**. | `ReadmeDoc.markdownText` (String) |
| Code block `npx shadcn@latest init` + copy icon | part of the raw Markdown | same raw response | same |
| `Read the documentation` link | part of the raw Markdown link | same, handled by markdown `onTapLink` | same |
| `Languages` label + bar | language bytes map | `GET /repos/{owner}/{repo}/languages` returns a map like `TypeScript: bytes`. Compute percentages locally. | `RepoLanguages.entries` (name + bytes + percent) |
| `MIT License` (top-right of languages) | field `license.name` / `license.spdx_id` | `GET /repos/{owner}/{repo}` field `license` object — **nullable (can be null)** | `GithubRepo.licenseName` (nullable) |
| Legend `TypeScript 83.2%, CSS 6.9%` | computed percentages | computed from the languages map | same `RepoLanguages` |
| Bottom nav (Search highlighted even on details — likely a bug in the mock) | navigation | static | none |

**Global bottom nav:** `Search (explore) / Saved (local Hive list) / Profile (needs a default username — FLAG: the API has no logged-in user without auth, so the Profile tab must ask for a username or default to the last viewed user)`.

### 0D. Entity ownership (fixed by Revision 2)

- `lib/core/domain/entities/github_repo.dart` — `GithubRepo`.
- `lib/core/domain/entities/github_user.dart` — `GithubUser`.
- `lib/features/repository_details/domain/entities/repo_details.dart` — `RepoDetails extends GithubRepo`.
- `lib/features/repository_details/domain/entities/repo_languages.dart` — `RepoLanguages`.
- `lib/features/repository_details/domain/entities/readme_doc.dart` — `ReadmeDoc`.
- `lib/features/repository_details/domain/entities/pull_request_info.dart` — `PullRequestInfo`.
- `lib/features/saved/domain/entities/saved_repo.dart` — `SavedRepo`.

Rule: a feature may import `core/domain`, but never another feature's `domain`. Shared widgets in `core/widgets` may depend on core entities only.

`GithubRepo` fields: id, name, fullName, ownerLogin, ownerAvatarUrl, description (nullable), htmlUrl, language (nullable), stargazersCount, forksCount, subscribersCount, openIssuesCount, isPrivate, topics, licenseName (nullable), defaultBranch.

`GithubUser` fields: id, login, avatarUrl, htmlUrl, name (nullable), bio (nullable), company (nullable), blog (nullable), location (nullable), followersCount, followingCount, publicReposCount, createdAt.

---

## 1. Phased roadmap — always runnable

Recommended slice order:

Phase 0 Setup (empty app runs) → Phase 1 Core (theme + error + network + router shell runs) → Phase 2 Saved-local slice (proves Hive + bottom nav without rate-limit risk) → Phase 3 Explore slice (proves GitHub search + trending workaround + request cancellation) → Phase 4 Repository Details slice (proves subscribers count + raw README + save) → Phase 5 Profile slice (proves user + repos + starred, reuses repo cards) → Phase 6 Polish (rate-limit countdown, pagination, RTL, release checks).

Why this order:
- Saved first gives you a working bottom nav and local storage with zero network, so later network slices have somewhere to save to.
- Explore before Details because Details needs a repo to open from Explore.
- Profile last because it reuses repo cards and starred logic from both prior slices and has the most API disagreements (pinned, stars, follow).
- Core entities are created before any feature so shared widgets compile and no feature imports another feature's domain.

---

## 2. Every step (goal / files / responsibility / concept / verify / mistakes)

### PHASE 0 — Project setup (app still runs as template, then blank)

#### Step 0-1 — Fix folders + env + analysis

**Goal:** clean skeleton with correct names.

**Files to create/rename:**
- Rename `lib/core/netwrok/` to `lib/core/network/`.
- Create `lib/app.dart`.
- Create `.env` for the optional token.
- Edit `analysis_options.yaml` if needed.
- Create `test/fixtures/` folder.

**Responsibility:** `app.dart` will later hold the root widget; `.env` holds an optional GitHub token; `fixtures` holds sample GitHub JSON for tests.

**Concept:** `flutter_dotenv` loads a key-value file at startup. Never commit a real token.

**Verify:** `flutter pub get` succeeds, `flutter run` shows the template, `flutter test` passes.

**Common mistakes:** committing `.env` with a token; leaving the typo folder and importing from both.

#### Step 0-2 — Add dependencies + code-gen smoke test

**Goal:** the fixed stack installs and generates.

**Files:** edit `pubspec.yaml` (versions already present — do not change major versions), run code generation.

**Responsibility:** confirm `freezed + json_serializable + build_runner + hive_ce_generator` work together.

**Concept:** `build_runner` reads annotations like `@freezed` and writes `.freezed.dart` / `.g.dart` files.

**Verify:** `dart run build_runner build --delete-conflicting-outputs` finishes without error. TDD: none, visible result is a clean `pub get`.

**Common mistakes:** adding `get_it` (forbidden — use Riverpod for DI); adding `hive` instead of `hive_ce`; mismatched `freezed_annotation` version.

**Phase 0 Done when:** `flutter run`, `flutter test`, and `build_runner build` all succeed.

### PHASE 1 — Core (app runs with blank shell + theme + shared entities)

#### Step 1-1 — Failures + exceptions + constants

**Goal:** shared error language.

**Files:**
- `lib/core/error/failures.dart` — `ServerFailure`, `NetworkFailure`, `RateLimitFailure`, `CacheFailure`, `NotFoundFailure`, `RequestCancelledFailure` (or treat cancellation as non-error).
- `lib/core/error/exceptions.dart` — `ServerException`, `NetworkException`, `RateLimitException`, `NotFoundApiException`, `RequestCancelledException`.
- `lib/core/constants/api_constants.dart` — base URL `https://api.github.com`, header names including `X-RateLimit-Reset`, rate-limit numbers.
- `lib/core/constants/app_constants.dart` — pagination sizes, debounce milliseconds, Hive box names.

**Responsibility:** domain talks only about `Failure`; data throws `Exception` and maps it to `Failure`.

**Concept:** `Equatable` gives value equality so two failures with the same message compare equal in tests.

**Verify TDD first:** create `test/core/error/failures_test.dart` with cases: `two server failures with the same message are equal`, `rate limit failure carries retry time`, `cancelled failure is distinct from network failure`. Watch it fail, then write the tiny classes.

**Common mistakes:** importing Flutter in failures; using raw strings instead of typed failures; forgetting that cancellation is not a user-facing error.

#### Step 1-2 — Dio client + token + rate-limit interception

**Goal:** one place that talks to GitHub.

**Files:**
- `lib/core/network/dio_client.dart`.
- `lib/core/network/api_headers.dart` if you split header logic.
- `lib/core/network/rate_limit_interceptor.dart`.

**Responsibility:** creates Dio with base URL, timeouts, default `Accept: application/vnd.github+json`, optional `Authorization: Bearer token` from `.env`, maps HTTP 403 with rate-limit headers to `RateLimitException`, 404 to not-found, no connection to network, and `DioExceptionType.cancel` to `RequestCancelledException`. On rate limit, read `X-RateLimit-Reset` as raw **seconds** and store it on the exception. Full countdown formatting comes in Step 6-1.

**Concept:** `Interceptor` is Dio middleware that sees every request, response and error.

**Verify TDD:** `test/core/network/dio_client_test.dart` cases: `adds accept header to every request`, `adds auth header only when token present`, `maps 403 rate limit to rate limit exception carrying reset seconds`, `maps socket error to network exception`, `maps cancel to cancellation exception`. Use a mock HTTP adapter; never hit the real API in tests.

**Common mistakes:** hardcoding the token; forgetting timeouts; treating every 403 as rate limit (it can also be forbidden); reading the reset header as milliseconds; setting the raw README `Accept` header globally (do it per request in Step 4-2).

#### Step 1-3 — Base use case + formatters

**Goal:** one standard signature for all use cases and one place for display formatting.

**Files:**
- `lib/core/usecases/usecase.dart` — abstract base with a `call` method returning `Either<Failure, T>`.
- `lib/core/utils/either_utils.dart` — optional helpers.
- `lib/core/utils/date_formatter.dart` — `March 2013`, `15.2k`, `104k`, percentages.
- `lib/core/utils/rate_limit_parser.dart` — parse reset seconds into a UTC `DateTime` (details in Step 6-1).

**Responsibility:** enforces the dependency rule; keeps formatting out of widgets.

**Concept:** `Either` left = failure, right = success.

**Verify TDD:** `test/core/usecases/usecase_test.dart` case `dummy use case returns right value`. `test/core/utils/date_formatter_test.dart` cases `formats thousands with k`, `formats members since as month year`.

**Common mistakes:** returning raw exceptions from use cases; putting Dio in domain; formatting numbers inside widgets.

#### Step 1-3B — Shared core entities

**Goal:** one canonical repo and user shape used by Explore, Details, Profile and Saved.

**Files:**
- `lib/core/domain/entities/github_repo.dart` — `GithubRepo`.
- `lib/core/domain/entities/github_user.dart` — `GithubUser`.

**Responsibility:** pure Dart immutable classes with Equatable. No JSON annotations, no Flutter, no Dio, no Hive. Include the fields listed in section 0D, including `subscribersCount` on `GithubRepo`.

**Concept:** shared kernel. Core entities are the contract between features; data models map into them.

**Verify TDD:**
- `test/core/domain/entities/github_repo_test.dart` cases: `two repos with same fields are equal`, `repo allows null description and language`, `repo carries subscribers count separately from stars`.
- `test/core/domain/entities/github_user_test.dart` cases: `two users with same fields are equal`, `user allows null name and bio`.

**Common mistakes:** putting `@freezed` / `@JsonSerializable` in core entities; placing `GithubRepo` inside `features/explore` and importing it from Profile; forgetting `subscribersCount` because the design says "Watching".

#### Step 1-4 — Theme + responsive + shared widgets

**Goal:** visual system matching the mocks (light, rounded cards, blue accents) and reusable cards.

**Files:**
- `lib/core/theme/app_theme.dart`.
- `lib/core/theme/app_colors.dart`.
- `lib/core/theme/app_text_styles.dart`.
- `lib/core/widgets/app_error_view.dart`.
- `lib/core/widgets/app_loading_view.dart`.
- `lib/core/widgets/app_empty_view.dart`.
- `lib/core/widgets/repo_card.dart` — shared card used by Explore, Profile and Saved; imports `core/domain/entities/github_repo.dart`.
- `lib/core/widgets/user_tile.dart` — shared person row; imports `core/domain/entities/github_user.dart`.

**Responsibility:** theme defines colors and text; shared widgets handle loading/empty/error consistently; the repo card shows owner/name/description/language/stars.

**Concept:** `ScreenUtil` scales `.w/.h/.sp/.r` values from a design size to any phone. `Gap` is a SizedBox with a named gap.

**Verify visible:** a temporary storybook screen showing theme + loading + error + empty + one fake repo card and one fake user tile with no network. Add `test/core/widgets/repo_card_test.dart` cases: `shows fallback when description null`, `formats star count`, `hides language pill when language null`.

**Common mistakes:** calling `.w` before `ScreenUtilInit`; hardcoding `fontSize: 16` without `.sp`; duplicating repo card UI in each feature.

#### Step 1-5 — Router shell with bottom nav

**Goal:** `Search / Saved / Profile` navigation works with blank pages.

**Files:**
- `lib/core/router/app_router.dart`.
- `lib/core/router/route_names.dart`.
- Edit `lib/app.dart`.
- Edit `lib/main.dart` for dotenv + ProviderScope + router + ScreenUtil. Hive is added in Step 2-4.

**Responsibility:** `StatefulShellRoute.indexedStack` with branches Search, Saved, Profile; deep links `/repo/:owner/:name` and `/user/:login` as pushed sub-routes; each tab keeps its own state.

**Concept:** `StatefulShellRoute.indexedStack` is a bottom-nav shell where each branch keeps its navigation stack and scroll position.

**Verify visible:** run the app, tap the 3 tabs, each shows placeholder text, back works from a pushed fake detail. Router test `test/core/router/router_test.dart` cases: `starts on search tab`, `tapping saved keeps search state`, `repo deep link resolves owner and name`.

**Common mistakes:** using plain `ShellRoute` (loses tab state); using `state.params` (removed — use `state.pathParameters` and `state.uri.queryParameters`); passing a full object through `extra` and expecting it to survive a web reload.

**Phase 1 Done when:** the app launches to a 3-tab shell, theme applied, no network yet, `ScreenUtilInit` with `designSize` set once, core entities tested, Dio client tested.

### PHASE 2 — Saved slice (local only, first working screen)

#### Step 2-1 — SavedRepo Hive model + adapter + local datasource

**Goal:** persist a repo offline.

**Files:**
- `lib/features/saved/data/models/saved_repo_model.dart` — Hive type with `typeId` and fields, plus a mapper from core `GithubRepo`.
- `lib/features/saved/data/models/saved_repo_model.g.dart` — generated, do not hand-write.
- `lib/features/saved/data/datasources/saved_local_datasource.dart` — abstract with `getAll`, `save`, `remove`, `isSaved`, `watch`.

**Responsibility:** the model knows Hive fields; the datasource only talks to `Box`. Save `subscribersCount` too, so a saved repo can render the Watching stat later.

**Concept:** `TypeAdapter` + `typeId` — Hive uses the numeric ID to know which class a saved blob represents.

**Verify TDD:**
- `test/features/saved/data/models/saved_repo_model_test.dart` cases: `converts core repo to saved model and back without loss`, `handles null description and language`, `preserves subscribers count`.
- `test/features/saved/data/datasources/saved_local_datasource_test.dart` cases: `saves then reads back`, `removing deletes`, `isSaved false when missing`, `watch emits after save`. Use a temporary Hive box in tests.

**Common mistakes:** forgetting `Hive.registerAdapter` before `openBox` (crash); reusing typeId 200/201 (reserved by hive_ce_flutter auto-registration); storing `Either` or `Failure` in Hive; dropping null fields during mapping.

#### Step 2-2 — Saved repository contract + implementation

**Goal:** domain hides Hive.

**Files:**
- `lib/features/saved/domain/entities/saved_repo.dart` — pure Dart, no Hive import.
- `lib/features/saved/domain/repositories/saved_repository.dart` — abstract contract.
- `lib/features/saved/data/repositories/saved_repository_impl.dart` — maps exceptions to `Failure`.

**Responsibility:** entity is framework-free; implementation catches datasource errors and returns `CacheFailure`.

**Verify TDD:** `test/features/saved/domain/repositories/saved_repository_test.dart` cases: `returns list on success`, `returns cache failure when datasource throws`, `returns saved state for a known repo`. Mock the datasource with `mocktail`.

**Common mistakes:** importing Hive in domain; returning exceptions instead of `Either`; letting Hive errors escape to presentation.

#### Step 2-3 — Saved use cases

**Goal:** actions the UI will call.

**Files:**
- `lib/features/saved/domain/usecases/get_saved_repos.dart`.
- `lib/features/saved/domain/usecases/save_repo.dart`.
- `lib/features/saved/domain/usecases/remove_saved_repo.dart`.
- `lib/features/saved/domain/usecases/is_repo_saved.dart`.

**Responsibility:** each `call` delegates to the repository; no UI logic.

**Verify TDD:** `test/features/saved/domain/usecases/get_saved_repos_test.dart` cases `gets list via repository`, `forwards failure`. Repeat the pattern for save, remove and isSaved (4 small files, same shape).

**Common mistakes:** one giant use case with a boolean flag; business logic in the widget; not testing the failure path.

#### Step 2-4 — Saved providers + Saved screen UI + Hive injection

**Goal:** first working tab, with the Hive box available synchronously to every provider.

**Files:**
- `lib/features/saved/presentation/providers/saved_providers.dart` — declare `savedBoxProvider` (must be overridden with an opened `Box<SavedRepoModel>`), datasource, repository, use case and saved-list notifier providers.
- `lib/features/saved/presentation/pages/saved_page.dart`.
- `lib/features/saved/presentation/widgets/saved_repo_tile.dart` (reuse core `RepoCard` if possible).
- Edit `lib/main.dart` and `lib/app.dart`.

**Responsibility:** providers wire DI (no get_it); `savedBoxProvider` is a plain synchronous provider whose default throws `UnimplementedError`-style "must override" error. `main()` does, in order: `WidgetsFlutterBinding.ensureInitialized`, load dotenv, `await Hive.initFlutter()`, register adapters, `await Hive.openBox<SavedRepoModel>(...)`, then `runApp` with `ProviderScope(overrides: [savedBoxProvider.overrideWithValue(savedBox)])`. The saved page shows loading/empty/error/list, swipe-to-delete, and tap to repo details (placeholder route for now).

**Concept:** Riverpod provider override is the DI seam for synchronous dependencies. Opening the box before `runApp` means no provider ever needs an async box lookup or a loading state just for storage.

**Verify TDD:**
- `test/features/saved/presentation/providers/saved_providers_test.dart` cases: `saved box provider is overridden with an open box`, `saved repository reads from the overridden box`, `saved list notifier emits saved items`.
- `test/features/saved/presentation/pages/saved_page_test.dart` cases: `shows empty view when no saved`, `shows list when data`, `shows error view on failure`, `delete removes item`. Wrap tests in `ProviderScope` with the box override.

**Visible result:** save a repo through a temporary test button, restart the app, it is still saved.

**Common mistakes:** calling `Hive.box()` inside a provider before the box is open; making the box provider async and forcing every consumer into `AsyncValue`; forgetting the override in tests (throws at startup); registering adapters after `openBox`; opening the box twice.

**Phase 2 Done when:** Saved tab lists, deletes and persists across restart; all saved use cases tested; `savedBoxProvider` is overridden in `main()` and in tests; no network needed.

### PHASE 3 — Explore slice (search + trending workaround + cancellation)

#### Step 3-1 — Fixtures

**Goal:** deterministic tests without hitting rate limits.

**Files:**
- `test/fixtures/search_repositories.json` — a real `GET /search/repositories` response with 2 items, including one with null description.
- `test/fixtures/search_users.json`.
- `test/fixtures/rate_limit_403.json` — includes `X-RateLimit-Reset` header examples.

**Responsibility:** exact GitHub JSON shapes for model tests.

**Verify:** files exist and are valid JSON with `total_count` and `items`.

**Common mistakes:** hand-crafting JSON that omits nullable fields; forgetting `owners` and `license`; using fixtures that do not match the real envelope.

#### Step 3-2 — Explore remote datasource with CancelToken

**Goal:** talks to the search endpoints and can cancel stale requests.

**Files:**
- `lib/features/explore/data/datasources/explore_remote_datasource.dart` — abstract + implementation with methods `searchRepositories(query, page, cancelToken)`, `searchUsers(query, page, cancelToken)`, `getTrendingThisWeek(cancelToken)`.
- `lib/features/explore/data/models/repo_model.dart` (+ generated `.g.dart`).
- `lib/features/explore/data/models/github_user_search_model.dart` (+ `.g.dart`).

**Responsibility:** the datasource builds query strings (`q`, `sort=stars`, `order=desc`, `per_page`, `page`, `created:>date` for trending), passes the Dio `CancelToken` to every search call, parses JSON, and throws typed exceptions. Cancellation is not converted into a user-facing failure.

**Concept:** `Pagination` fetches page 1, 2, 3 with `per_page`; `Debounce` waits ~400ms after typing stops; `CancelToken` cancels the previous in-flight request.

**Verify TDD:** `test/features/explore/data/datasources/explore_remote_datasource_test.dart` cases: `builds correct trending query with date and sort`, `parses repo list including null description`, `maps 403 to rate limit exception`, `maps empty items to empty list`, `passes cancel token to Dio`, `cancelled request maps to cancellation exception`.

**Common mistakes:** not forwarding the token to Dio; reusing a token after it was cancelled; assuming `language` or `topics` is always present; ignoring `incomplete_results`.

#### Step 3-3 — Explore repository contract + implementation (uses core entities)

**Goal:** domain models for search, with no duplicate entities.

**Files:**
- `lib/features/explore/domain/repositories/explore_repository.dart` — imports `core/domain/entities/github_repo.dart` and `github_user.dart`.
- `lib/features/explore/data/repositories/explore_repository_impl.dart`.

No `GithubRepo` or `GithubUser` file is created here. They already exist in `lib/core/domain/entities/`.

**Responsibility:** repository maps data models to core entities and exceptions to failures. Methods return `Either<Failure, List<GithubRepo>>` or `Either<Failure, List<GithubUser>>`.

**Concept:** feature domain depends on shared kernel, never on another feature's domain.

**Verify TDD:** `test/features/explore/data/repositories/explore_repository_impl_test.dart` cases: `returns repo list on success`, `returns rate limit failure on 403`, `returns network failure on disconnect`, `maps models to core entities without losing subscribers count`.

**Common mistakes:** creating a second `GithubRepo` inside Explore; importing Profile's entity; putting `@JsonSerializable` in core entities.

#### Step 3-4 — Explore use cases

**Goal:** `SearchRepositories`, `SearchUsers`, `GetTrendingRepositories`.

**Files:**
- `lib/features/explore/domain/usecases/search_repositories.dart`.
- `lib/features/explore/domain/usecases/search_users.dart`.
- `lib/features/explore/domain/usecases/get_trending_repositories.dart`.

**Responsibility:** each use case has a `call` with query/page/sort in prose; trims the query; returns an empty success for a blank query without calling the repository.

**Verify TDD:** `test/features/explore/domain/usecases/search_repositories_test.dart` cases: `returns list for query`, `forwards failure`, `blank query returns empty without calling repository`. Repeat for users and trending.

**Common mistakes:** calling the datasource directly from a provider; not trimming; letting blank queries burn the 10/min search budget.

#### Step 3-5 — Explore providers + Search/Explore page UI

**Goal:** working Explore screen matching Image 1, with debounce + cancellation.

**Files:**
- `lib/features/explore/presentation/providers/explore_providers.dart` — query notifier with 400ms debounce, tab filter notifier, trending provider, search results notifier with pagination.
- `lib/features/explore/presentation/pages/explore_page.dart`.
- `lib/features/explore/presentation/widgets/search_bar.dart`.
- `.../filter_chips.dart`.
- `.../trending_section.dart`.
- `.../people_section.dart`.
- `.../explore_empty_view.dart`.

**Responsibility:** on every query update, start the debounce, cancel the previous `CancelToken`, and create a new token for the new request. On dispose, cancel the active token. Ignore cancellation outcomes so they do not flash an error. Keep one token per request; never reuse a cancelled token. Pagination uses a separate token so loading page 2 does not cancel the current list.

**Concept:** debounce protects the rate limit; cancellation protects correctness. Debounce alone does not stop a slow response from page 1 arriving after a newer query.

**Verify TDD:**
- `test/features/explore/presentation/providers/explore_providers_test.dart` cases: `typing quickly sends only the last query`, `cancels previous token when query changes`, `stale response cannot overwrite newer results`, `disposing the provider cancels the active token`, `blank query does not call search`.
- Widget test `test/features/explore/presentation/pages/explore_page_test.dart` cases: `shows curiosity empty view when query empty`, `shows loading then trending cards`, `switching chip to People filters list`, `shows rate limit error view with retry`.

**Visible result:** type `flutter`, see real cards; `This week` changes the date query; offline shows an error and retry; typing fast sends one request.

**Common mistakes:** firing on every keystroke; cancelling the token after the request already completed (harmless but confusing); using the same token for pagination; treating cancellation as a real error; losing scroll on tab switch.

**Phase 3 Done when:** Explore shows trending on launch, search repos/people works with debounce + cancellation + pagination, empty/loading/error states are visible, and no null field crashes.

### PHASE 4 — Repository Details slice

#### Step 4-1 — Details fixtures (raw README, subscribers count)

**Goal:** cover the corrected API shapes.

**Files:**
- `test/fixtures/repo_details.json` — a single `GET /repos/{owner}/{repo}` response that includes both `watchers_count` and `subscribers_count`, with **different values**, plus a null-license variant.
- `test/fixtures/languages.json` — a language map.
- `test/fixtures/readme_raw.md` — raw Markdown containing a heading, a code fence and a link.
- `test/fixtures/readme_404.json` — optional error fixture.

**Responsibility:** exact response shapes for model and repository tests.

**Verify:** `repo_details.json` has `subscribers_count: 620` and a different `watchers_count`; `readme_raw.md` is plain Markdown, not base64.

**Common mistakes:** keeping the old base64 `readme.json` and testing the wrong path; making `watchers_count` equal `subscribers_count` in the fixture, which hides the bug.

#### Step 4-2 — Details datasource + models (raw README header, subscribers_count)

**Goal:** fetch repo, languages, raw README and optional pull requests.

**Files:**
- `lib/features/repository_details/data/datasources/repo_details_remote_datasource.dart` — methods `getRepoDetails`, `getLanguages`, `getReadme`, `getPullRequests`.
- `lib/features/repository_details/data/models/repo_details_model.dart`.
- `.../readme_model.dart` (or no model if the datasource returns a raw string).
- `.../pull_request_model.dart`.

**Responsibility:**
- `getRepoDetails` parses `subscribers_count` into the watching field. Do not map `watchers_count` to Watching.
- `getLanguages` returns the raw language-to-bytes map.
- `getReadme` calls `GET /repos/{owner}/{repo}/readme` with a **per-request** header `Accept: application/vnd.github.raw+json`, a plain-text response type, and returns the raw UTF-8 Markdown string. Do not base64 decode. Do not set this header globally.
- `getPullRequests` is optional for the tab count.

**Concept:** GitHub content negotiation: the same README endpoint returns a JSON envelope by default, but the raw media type returns the file body directly. Raw has no file metadata.

**Verify TDD:** `test/features/repository_details/data/datasources/repo_details_remote_datasource_test.dart` cases: `parses repo with null license`, `parses subscribers count for watching`, `does not use watchers count for watching`, `parses languages map to bytes`, `sends raw accept header for readme`, `returns raw markdown without base64 decoding`, `404 maps to not-found exception`.

**Common mistakes:** using `watchers_count` (it duplicates stars); leaving the default JSON Accept header and then trying to render an envelope; setting the raw header on the shared Dio instance; base64-decoding a raw string; assuming `topics` exists.

#### Step 4-3 — Details repository + entities (shared entity extends core)

**Goal:** domain for details with raw Markdown.

**Files:**
- `lib/features/repository_details/domain/entities/repo_details.dart` — `RepoDetails extends GithubRepo`; imports `core/domain/entities/github_repo.dart`.
- `.../repo_languages.dart` — list of name/bytes/percent + total.
- `.../readme_doc.dart` — `markdownText`, `fileName`, `htmlUrl`.
- `.../pull_request_info.dart` — number/title/state/body (nullable).
- `lib/features/repository_details/domain/repositories/repo_details_repository.dart`.
- `lib/features/repository_details/data/repositories/repo_details_repository_impl.dart` — computes language percentages and maps raw README into `ReadmeDoc`.

**Responsibility:** no base64 handling anywhere. `ReadmeDoc.fileName` is static `README.md` unless you make a second metadata call; `htmlUrl` is derived from the repo URL plus `#readme`. Language percentages are computed from bytes and guarded against an empty map.

**Concept:** extending a shared entity keeps one repo identity while adding detail-only fields (topics, license, default branch, subscribers count).

**Verify TDD:**
- `test/features/repository_details/data/models/repo_details_model_test.dart` cases: `parses subscribers count`, `parses null license`, `maps to repo details extending core repo`.
- `test/features/repository_details/data/models/readme_model_test.dart` cases: `keeps raw markdown verbatim`, `does not attempt base64 decode`.
- `test/features/repository_details/data/repositories/repo_details_repository_impl_test.dart` cases: `computes language percentages summing to 100`, `empty languages returns empty result without division by zero`, `returns not-found failure on 404`.

**Common mistakes:** `base64Decode` on the raw string; expecting `name/path/html_url` in the raw response; dividing by zero on an empty language map; duplicating `GithubRepo` fields instead of extending the core entity.

#### Step 4-4 — Details use cases

**Goal:** `GetRepoDetails`, `GetRepoLanguages`, `GetRepoReadme`, `GetRepoPullRequests` (optional), `ToggleSaveRepo` (delegates to the Saved repository).

**Files:** 4-5 files under `lib/features/repository_details/domain/usecases/`.

**Responsibility:** each use case does one thing. `ToggleSaveRepo` checks saved state, then saves or removes.

**Verify TDD:** `test/features/repository_details/domain/usecases/get_repo_details_test.dart` cases `returns details`, `forwards failure`. Same for languages/readme/pulls. `toggle_save_repo_test.dart` cases: `saves when not saved`, `removes when saved`, `forwards cache failure`.

**Common mistakes:** fetching languages and README sequentially in one use case (keep them single-purpose; parallelize in the provider); duplicating save logic instead of delegating to Saved.

#### Step 4-5 — Details providers + Repository page UI

**Goal:** working Details matching Image 3, with correct Watching and raw README.

**Files:**
- `lib/features/repository_details/presentation/providers/repo_details_providers.dart` — family notifier keyed by owner/repo. In Riverpod 3, use a `Notifier` with a constructor argument, not `FamilyNotifier`.
- `lib/features/repository_details/presentation/pages/repository_page.dart`.
- `.../widgets/repo_stats_card.dart` — Stars, Forks, Watching from `subscribersCount`.
- `.../widgets/topics_row.dart`.
- `.../widgets/readme_view.dart` — `flutter_markdown_plus`, `selectable`, `onTapLink`.
- `.../widgets/languages_bar.dart`.
- `.../widgets/star_save_buttons.dart`.

**Responsibility:** fetch details + languages + README in parallel; show Overview (README + languages); placeholders for Code/Issues/Pulls with counts and an external link; star shows the count and is disabled without auth; save writes to Hive and updates Saved.

**Verify TDD:** `test/features/repository_details/presentation/pages/repository_page_test.dart` cases: `shows loading then stats`, `shows watching from subscribers count`, `shows readme markdown from raw text`, `does not show base64 text`, `shows language bar with percentages`, `save button toggles saved state`, `shows not-found error with retry`.

**Visible result:** open from Explore, README renders headings/code/link, Watching shows 620 (not 104k), language bar matches percentages, save appears in Saved.

**Common mistakes:** using `watchers_count`; trying to decode raw Markdown; using `FamilyNotifier` (removed); putting Markdown parsing in the widget; hardcoding bar widths; forgetting `onTapLink` (dead links).

**Phase 4 Done when:** tapping any repo card opens Details with stats/topics/README/languages/license, Watching uses `subscribers_count`, save works and appears in Saved, 404 shows NotFound.

### PHASE 5 — Profile slice

#### Step 5-1 — Profile fixtures

**Goal:** cover nullable user fields.

**Files:**
- `test/fixtures/user_profile.json` — full `GET /users/{username}` with null company/email.
- `test/fixtures/user_repos.json`.
- `test/fixtures/user_starred.json`.

**Verify:** fixtures include `created_at`, `public_repos` and `followers`.

**Common mistakes:** assuming `name` equals `login`; omitting null fields.

#### Step 5-2 — Profile datasource + models

**Goal:** fetch user + repos + starred.

**Files:**
- `lib/features/profile/data/datasources/profile_remote_datasource.dart` — methods `getUser`, `getUserRepos(sort, page)`, `getUserStarred(page)`.
- `lib/features/profile/data/models/github_user_model.dart`.

**Responsibility:** builds `GET /users/{username}`, `/repos` and `/starred` with `sort`, `per_page` and `page`; parses nulls safely.

**Verify TDD:** `test/features/profile/data/datasources/profile_remote_datasource_test.dart` cases: `parses user with null bio and location`, `parses repo list`, `empty starred returns empty`, `404 maps to not-found`.

**Common mistakes:** expecting a total-stars field (it does not exist); expecting a pinned field (it does not exist — sort repos by stars locally).

#### Step 5-3 — Profile repository + implementation (reuse core entities)

**Goal:** avoid duplicate entities.

**Files:**
- `lib/features/profile/domain/repositories/profile_repository.dart` — imports core `GithubUser` and `GithubRepo`.
- `lib/features/profile/data/repositories/profile_repository_impl.dart`.

No profile-specific user entity. `ProfileUser` is not created. Use core `GithubUser`.

**Responsibility:** repository returns core entities and computes the top-starred repo list for the "Top repositories" section.

**Verify TDD:** `test/features/profile/data/repositories/profile_repository_impl_test.dart` cases: `returns core user`, `returns top repos sorted by stars`, `returns network failure on disconnect`.

**Common mistakes:** creating a second `GithubUser` in Profile; importing Explore's repository; computing the sorted list in the widget.

#### Step 5-4 — Profile use cases

**Goal:** `GetUserProfile`, `GetUserRepos`, `GetUserStarred`.

**Files:**
- `lib/features/profile/domain/usecases/get_user_profile.dart`.
- `.../get_user_repos.dart`.
- `.../get_user_starred.dart`.

**Verify TDD:** per file: `returns user`, `forwards failure`, `returns sorted top repos` (for repos).

**Common mistakes:** computing total stars in the use case (keep it in a formatter or provider state); not trimming the username.

#### Step 5-5 — Profile providers + Profile page UI

**Goal:** working Profile matching Image 2.

**Files:**
- `lib/features/profile/presentation/providers/profile_providers.dart` — family by username.
- `lib/features/profile/presentation/pages/profile_page.dart` — one page that accepts a username; the tab uses the last viewed user or a prompt.
- `.../widgets/profile_header.dart`.
- `.../widgets/profile_stats.dart`.
- `.../widgets/profile_tabs.dart`.
- `.../widgets/top_repos_section.dart`.

**Responsibility:** header shows avatar/name/handle/bio/location/blog/followers/following/since date; tabs Overview/Repos/Stars switch lists; Follow is disabled with tooltip `Needs login`; share uses `html_url`; section is labeled `Top repositories`, not `Pinned`.

**Verify TDD:** `test/features/profile/presentation/pages/profile_page_test.dart` cases: `shows loading then header`, `falls back to login when name null`, `shows top repositories instead of pinned`, `shows error on unknown user`, `shows repositories count`.

**Visible result:** open from an Explore person card; counts are correct; Repositories paginates; Stars lists starred repos.

**Common mistakes:** hardcoding the Profile tab to `shadcn`; showing `Pinned repositories` when the data is top-starred; forgetting RTL handling for the back arrow.

**Phase 5 Done when:** any username opens Profile with correct nullable handling, Top repos are shown and labeled correctly, Stars tab lists starred repos, the bottom Profile tab has a sensible default and a search entry.

### PHASE 6 — Polish + release checks

#### Step 6-1 — Rate-limit countdown + offline UX

**Goal:** never crash on 60/hour or 10/minute limits, and show a real countdown.

**Files:**
- `lib/core/network/rate_limit_interceptor.dart` (finalize).
- `lib/core/utils/rate_limit_parser.dart` (finalize).
- `lib/core/widgets/app_error_view.dart` (rate-limit variant with countdown).
- `lib/core/error/failures.dart` — `RateLimitFailure` carries `retryAt` as a UTC `DateTime` and optionally the resource (`core` vs `search`).
- `lib/core/utils/connectivity_check.dart` (optional).

**Responsibility:**
- `X-RateLimit-Reset` is a **UTC Unix timestamp in seconds**. Parse the header as an integer, multiply by 1000, and call `DateTime.fromMillisecondsSinceEpoch(resetSeconds * 1000, isUtc: true)`.
- Store that instant as `retryAt` on `RateLimitFailure`.
- The error view computes `retryAt.difference(DateTime.now().toUtc())`, formats minutes:seconds, and shows `Try again in 04:32`; when the difference is negative, show `Try again now`.
- If `X-RateLimit-Reset` is absent (some secondary-limit responses), fall back to `Retry-After` if present, otherwise show a generic rate-limit message. Do not invent a reset time.
- Do not auto-retry in a loop; offer a manual retry button.

**Concept:** Unix epoch seconds vs milliseconds is a 1000x bug. The reset header is UTC, so compare against UTC now.

**Verify TDD:**
- `test/core/utils/rate_limit_parser_test.dart` cases: `parses reset seconds into a UTC instant`, `treats reset as seconds not milliseconds`, `returns null for a missing or malformed header`, `past reset time means retry now`.
- `test/core/widgets/app_error_view_test.dart` cases: `shows countdown for rate limit failure`, `shows retry now when reset has passed`, `shows generic message when reset missing`.
- Manual: spam search 12 times fast, see a friendly countdown, not a stack trace.

**Common mistakes:** treating the header as milliseconds (off by 1000); parsing it as local time; comparing against local `DateTime.now()` without normalizing; crashing on a missing header; retrying immediately in a loop.

#### Step 6-2 — Pagination + debounce/cancellation tuning

**Goal:** smooth lists without duplicate calls.

**Files:** edit Explore and Profile providers only.

**Responsibility:** append page results, guard against double-fetch, cancel only the active search token on a new query, use a separate token for pagination, show a `No more results` footer, and keep the debounce at 300-500ms.

**Verify:** scroll to bottom loads page 2 once (no duplicate calls); fast typing triggers one call; changing query cancels the previous request. Tests: `does not fetch page 2 twice`, `debounce cancels the prior request`, `cancelling pagination does not clear the list`.

**Common mistakes:** resetting the list on page 2 (must append); forgetting `per_page` max 100; cancelling the list token when loading the next page.

#### Step 6-3 — Hive + ScreenUtil + router hardening + RTL

**Goal:** release-ready startup and layout.

**Files:**
- Edit `lib/main.dart` — exact order below.
- Edit `lib/app.dart`.
- Edit `pubspec.yaml` assets for `.env`.
- Add `flutter_localizations` only if you decide to support Arabic UI.

**Responsibility and startup order:**
1. `WidgetsFlutterBinding.ensureInitialized()`.
2. Load `.env` with `flutter_dotenv` (optional token).
3. `await Hive.initFlutter()`.
4. Register Hive adapters (generated registrar or manual).
5. `await Hive.openBox<SavedRepoModel>(...)` — before `runApp`.
6. `runApp` with `ProviderScope(overrides: [savedBoxProvider.overrideWithValue(savedBox)], child: ScreenUtilInit(designSize: ..., builder: ...))`.

`ScreenUtilInit` wraps `MaterialApp` once at the root, never per page. The router's `StatefulShellRoute` stays inside `MaterialApp.router`.

**Concept:** initialization order. Storage must be ready before the first provider read; ScreenUtil must be ready before any `.w/.h/.sp` call.

**Verify:** cold start with no network still shows Saved data; rotation/resize scales text; an Arabic bio renders RTL correctly inside an LTR page; back from Details returns to the correct tab. Add `test/app_startup_test.dart` case: `app starts with saved box override and shows search tab`.

**Common mistakes:** `ScreenUtilInit` inside each page; `registerAdapter` after `openBox`; forgetting `await` on `openBox` (empty list on first frame); provider reading `Hive.box()` instead of the injected box; localizing only some strings.

**Phase 6 Done when:** the final checklist below is all green.

---

## 3. TDD catalog (write tests BEFORE code — plain-word case names)

### Core

- `test/core/error/failures_test.dart`: `equal failures with same message are equal`, `rate limit failure carries retry instant`, `cancelled failure is distinct`.
- `test/core/network/dio_client_test.dart`: `adds accept header`, `adds auth only with token`, `403 with rate header maps to rate exception with reset seconds`, `socket error maps to network exception`, `cancel maps to cancellation`.
- `test/core/domain/entities/github_repo_test.dart`: `equal repos with same fields are equal`, `allows null description and language`, `keeps subscribers count separate from stars`.
- `test/core/domain/entities/github_user_test.dart`: `equal users with same fields are equal`, `allows null name and bio`.
- `test/core/utils/rate_limit_parser_test.dart`: `parses reset seconds to UTC`, `seconds not milliseconds`, `missing header returns null`, `past reset means retry now`.
- `test/core/utils/date_formatter_test.dart`: `formats thousands with k`, `formats month and year`.
- `test/core/widgets/repo_card_test.dart`: `null description fallback`, `null language hides pill`, `star count formatted`.
- `test/core/router/router_test.dart`: `starts on search tab`, `tab switch preserves state`, `repo deep link resolves params`.

### Saved

- `test/features/saved/data/models/saved_repo_model_test.dart`: `round trip core repo`, `null fields survive`, `subscribers count preserved`.
- `test/features/saved/data/datasources/saved_local_datasource_test.dart`: `save then read`, `delete removes`, `isSaved true/false`, `watch emits`.
- `test/features/saved/domain/repositories/saved_repository_test.dart`: `returns list on success`, `cache failure on throw`.
- `test/features/saved/domain/usecases/get_saved_repos_test.dart` (+ save/remove/isSaved): `delegates to repository`, `forwards failure`.
- `test/features/saved/presentation/providers/saved_providers_test.dart`: `box provider overridden`, `repository uses overridden box`, `notifier emits items`.
- `test/features/saved/presentation/pages/saved_page_test.dart`: `shows empty`, `shows list`, `shows error`, `delete removes`.

### Explore

- `test/features/explore/data/datasources/explore_remote_datasource_test.dart`: `trending query contains created date and stars sort`, `parses null description`, `empty items ok`, `passes cancel token`, `cancelled request maps to cancellation`.
- `test/features/explore/data/repositories/explore_repository_impl_test.dart`: `returns repo list`, `rate limit failure on 403`, `network failure on disconnect`, `maps to core entity`.
- `test/features/explore/domain/usecases/search_repositories_test.dart` (+ users, trending): `returns list`, `forwards failure`, `blank query short-circuits`.
- `test/features/explore/presentation/providers/explore_providers_test.dart`: `debounce sends last query`, `cancels previous token`, `stale response ignored`, `dispose cancels token`.
- `test/features/explore/presentation/pages/explore_page_test.dart`: `curiosity empty state`, `loading then trending`, `people filter`, `rate limit error with retry`.

### Repository Details

- `test/features/repository_details/data/datasources/repo_details_remote_datasource_test.dart`: `parses null license`, `parses subscribers count`, `does not use watchers count`, `languages map ok`, `sends raw accept header`, `returns raw markdown`, `404 to not-found`.
- `test/features/repository_details/data/models/repo_details_model_test.dart`: `maps to repo details`, `subscribers count preserved`.
- `test/features/repository_details/data/models/readme_model_test.dart`: `raw markdown verbatim`, `no base64 decode`.
- `test/features/repository_details/data/repositories/repo_details_repository_impl_test.dart`: `language percentages sum to 100`, `empty languages safe`, `not-found failure`.
- `test/features/repository_details/domain/usecases/get_repo_details_test.dart` (+ languages, readme, pulls): `returns value`, `forwards failure`.
- `test/features/repository_details/domain/usecases/toggle_save_repo_test.dart`: `saves when not saved`, `removes when saved`, `cache failure forwarded`.
- `test/features/repository_details/presentation/pages/repository_page_test.dart`: `loading then stats`, `watching from subscribers`, `raw markdown rendered`, `no base64 shown`, `language bar`, `save toggles`, `not-found retry`.

### Profile

- `test/features/profile/data/datasources/profile_remote_datasource_test.dart`: `parses nulls`, `repo list`, `empty starred`, `404 not-found`.
- `test/features/profile/data/repositories/profile_repository_impl_test.dart`: `returns core user`, `top repos sorted by stars`, `network failure`.
- `test/features/profile/domain/usecases/get_user_profile_test.dart` (+ repos, starred): `returns user`, `forwards failure`.
- `test/features/profile/presentation/pages/profile_page_test.dart`: `loading then header`, `name null fallback`, `top repositories not pinned`, `unknown user error`.

Widget tests wrap the page in `ScreenUtilInit` and a `ProviderScope` with `savedBoxProvider` overridden where needed.

---

## 4. Pitfalls specific to this app (+ current-version warnings)

1. **Null fields:** `description, language, homepage, license, bio, company, blog, location, email, name, milestone, body` are all nullable per docs. Never use `!` on them. Test with fixtures that have nulls. Decide fallback text once (e.g. `No description`) and reuse it.

2. **Raw README, not base64:** call `GET /repos/{owner}/{repo}/readme` with per-request header `Accept: application/vnd.github.raw+json` and a plain-text response type. The body is raw UTF-8 Markdown. Do **not** base64-decode and do **not** strip newlines. Do not set this header globally, because every other endpoint expects JSON. The raw response has **no** `name`, `path` or `html_url`; use a static `README.md` label and derive the link from the repo `html_url` (append `#readme`), or make a second default-JSON call if you truly need metadata. If you keep a JSON fallback, keep it behind an explicit branch; never feed a JSON envelope into the Markdown widget.

3. **ScreenUtil init placement:** `flutter_screenutil 5.9.x` requires one `ScreenUtilInit` with a mandatory `designSize` (your Figma size, e.g. 360x690 — confirm from the design) wrapping `MaterialApp` at the root in `app.dart`. Never per page. `.w/.h/.r/.sp` return wrong values or crash before init. In widget tests wrap the page with `ScreenUtilInit`.

4. **Riverpod 3.4 breaking:** one `Ref` only (no `ProviderRef/FutureProviderRef`); no `ref.state` / `ref.future`; `AutoDispose*` interfaces removed (use the flag); `FamilyNotifier` removed (use `Notifier` with a constructor argument); `StateProvider/StateNotifierProvider` moved to `flutter_riverpod/legacy.dart` (prefer `NotifierProvider/AsyncNotifierProvider`); guard `if (!ref.mounted) return` after `await` or you get `UnmountedRefException`; `family.overrideWith` is deprecated in favor of `overrideWith2`. Do not follow pre-2024 tutorials.

5. **Async error states:** every `AsyncValue` must handle `loading/data/error`. Use the shared `AppErrorView` with retry. Distinguish `RateLimitFailure` (countdown + token hint), `NetworkFailure` (offline), `NotFoundFailure` (unknown user/repo), and cancellation (no error UI).

6. **Search debounce + cancellation:** without a 300-500ms debounce you will hit the verified `10 req/min` search limit in seconds. Implement the debounce in the query notifier, and **also** cancel the previous `CancelToken` when the query changes. Debounce alone does not prevent a slow stale response from overwriting newer results. Create a new token per request; never reuse a cancelled token. Cancel the active token in `ref.onDispose`. Use a separate token for pagination so loading page 2 does not cancel page 1.

7. **Pagination:** `per_page` max 100, default 30; search caps at 1000 total results. Append pages, do not replace. Guard double-fetch when scrolling fast. Show a `No more results` footer.

8. **Rate limits + reset header:** verified `60/hour` unauthenticated for core (`GET /users`, `/repos`, `/languages`, `/readme`, `/pulls`, starred/repos lists), IP-based; `10/min` unauthenticated for search. `GET /rate_limit` does not count. With a token (optional `flutter_dotenv`): 5000/hour and 30/min search. Parse `X-RateLimit-Remaining` and `X-RateLimit-Reset`; the reset value is **UTC Unix seconds**, so convert with `DateTime.fromMillisecondsSinceEpoch(resetSeconds * 1000, isUtc: true)`. If the reset header is missing on a secondary-limit response, fall back to `Retry-After` seconds if present; otherwise show a generic message. Cache trending/profile to reduce calls. Never auto-retry in a tight loop.

9. **Hive CE init + adapters + Riverpod injection:** order matters: `await Hive.initFlutter()`, register adapters, `await openBox`, then `runApp` with `ProviderScope(overrides: [savedBoxProvider.overrideWithValue(savedBox)])`. Never read `Hive.box()` lazily inside a provider. `hive_ce_flutter 2.x` auto-registers Color/TimeOfDay (typeId 200/201) — do not re-register them or it throws. Custom `typeId` must not collide (old 223 limit extended to 65439). Run `build_runner` after changing `@HiveType/@HiveField`. Keep the box override in every test that touches Saved.

10. **go_router 18 + bottom nav:** use `StatefulShellRoute.indexedStack` with one `StatefulShellBranch` per tab. Current API: `state.uri`, `state.uri.queryParameters`, `state.pathParameters`, `state.matchedLocation`. Old `state.location/params/queryParams/subloc` are removed. `extra` does not survive reload — use path params `/user/:login`, `/repo/:owner/:name`. v15+ URLs are case-sensitive by default; v18 needs Flutter >= 3.44.

11. **Freezed 4 + json_serializable:** the class must be `abstract` (or `sealed`) with `with _$Class`; plain `class Foo with _$Foo` fails since v3. Need `part '*.freezed.dart'` + `part '*.g.dart'`. `map/when` were removed in 3.0 and added back in 3.1 — prefer Dart `switch` pattern matching for new code. No `final` inside factory constructor params (Dart 3.13 rule). Run `dart run build_runner build --delete-conflicting-outputs`. Do not put Freezed/JSON on core entities.

12. **Arabic/RTL:** the design is English LTR, but GitHub bios and README can be Arabic. Do not hardcode `TextDirection.ltr`. Use the `Directionality` from `MaterialApp` and add `localizationsDelegates` if you support an Arabic UI. Back and share icons should auto-mirror. Numbers like `15.2k` should use locale-aware formatting; keep that in `date_formatter.dart` and test it. Test with an Arabic bio fixture and an RTL README.

13. **Design vs API disagreements (must flag in UI):**
    - **Watching:** use `subscribers_count`. `watchers_count` is a legacy alias of `stargazers_count`, so it would show 104k twice. This is corrected in Section 0C, Step 4-2 and this pitfall.
    - **Follow / Star repository:** both need auth (`PUT /user/following/{username}`, `PUT /user/starred/{owner}/{repo}`). Keep them disabled or fake locally with a tooltip.
    - **Pinned repositories:** no REST endpoint (GraphQL only). Label the section `Top repositories` and sort by stars.
    - **Trending / People to know:** no official endpoint. Use search workarounds and label them honestly.
    - **Stars 128 on the profile tab:** no direct total-stars field. Compute it or omit it.
    - **README metadata:** raw Markdown has no file name/path/HTML URL. Use a static label and derived link, or pay for a second JSON call.
    - **Code / Issues / Pulls tabs:** Code needs a file tree; Issues and Pulls need extra endpoints. Ship Overview fully and make the others counts + external links for v1.

---

## 5. Definition of Done

### Per phase

- **Phase 0:** `pub get`, `run`, `test`, `build_runner build` green.
- **Phase 1:** 3-tab shell navigates; theme + ScreenUtil scaling verified on small and large phones; core entities tested; Dio tests green; no hardcoded sizes.
- **Phase 2:** Saved persists across restart; all 4 saved use cases tested; `savedBoxProvider` overridden in `main()` and tests; empty/error states shown.
- **Phase 3:** trending + search repos/people with debounce + cancellation + pagination work; rate-limit error + retry shown; null-field fixtures pass; stale responses cannot overwrite newer results.
- **Phase 4:** Details shows stats/topics/README/languages/license; Watching uses `subscribers_count`; README renders raw Markdown with no base64; save toggles Saved; 404 handled.
- **Phase 5:** Profile shows header/stats/since date/top repos/starred; section says `Top`, not `Pinned`; unknown user 404 handled; core `GithubUser` reused.
- **Phase 6:** rate-limit countdown from UTC reset seconds works; offline/pagination/rotation/RTL manual tests pass; Hive and ScreenUtil startup order verified.

### Final checklist (finished app)

- Every screen has loading/empty/error (+ rate-limit countdown) with retry.
- No hardcoded `width/height/fontSize` — all `.w/.h/.sp/.r` + `Gap`.
- No business logic in widgets (widgets only `watch` providers and format through utils).
- `GithubRepo` and `GithubUser` exist only in `lib/core/domain/entities/`; no feature imports another feature's domain.
- All use cases, repositories and datasources have tests; fixtures cover nulls, raw Markdown, and a `watchers_count`/`subscribers_count` mismatch.
- `presentation -> domain <- data` respected; domain has no Flutter/Dio/JSON/Hive imports.
- Hive box opens before `runApp`; adapters registered once; `savedBoxProvider` overridden; data survives restart.
- Search uses 400ms debounce + `CancelToken` cancellation; no stale results; `per_page` and page append are correct.
- `RateLimitFailure` carries a UTC `retryAt` parsed from seconds; UI shows a countdown and never retries in a loop.
- `Watching` uses `subscribers_count`; `watchers_count` appears nowhere in UI logic.
- README uses `Accept: application/vnd.github.raw+json`; no base64 decoder in the app.
- Deep links `/user/:login`, `/repo/:owner/:name` work; tab state preserved.
- No real `Follow/Star` network call without a token (disabled or documented fake).
- `.env` is git-ignored; the app runs with and without a token.

---

## 6. Decisions you must make (my recommendation)

1. **Trending implementation:** fake static list vs live `search/repositories?created:>date&sort=stars`. Recommendation: live search workaround with `This week/This month` computed locally — matches the design and proves the network layer.

2. **Pinned vs Top repos:** true pinned needs GraphQL (out of stack). Recommendation: show the top 6 repos sorted by `stargazers_count`, title it `Top repositories`, and comment why.

3. **Profile tab default user:** no logged-in user without auth. Recommendation: prompt for a username, cache the last viewed user in Hive, and default to `shadcn` on first run to match the mocks.

4. **Stars/Follow buttons:** real actions need a token plus `PUT` endpoints. Recommendation: v1 shows counts and a disabled button with tooltip `Sign in to star/follow`; saving is the only local write. Add real starring later as a separate slice if you add auth.

5. **Issues/Code/Pulls tabs:** full file tree and issue lists are large scope. Recommendation: v1 Overview only (README + languages + license), tabs show counts and `Open on GitHub` via `html_url`; add pulls only if time remains.

6. **README metadata label:** raw Markdown loses `name/path/html_url`. Recommendation: static `README.md` label + derive `{repo.html_url}#readme`; do not spend an extra request on metadata in v1.

7. **Token support:** ship with an optional `.env` token or unauthenticated only? Recommendation: support an optional token from day 1 in the Dio client (empty = 60/hour), and show remaining quota in the rate-limit view. Never require a token to run.

8. **Language percentages rounding:** Recommendation: compute in the repository implementation, round to 1 decimal, render `<0.1%` for tiny values, ensure the displayed percentages sum to ~100, and show a `No languages` empty state for an empty map.

If any endpoint detail above is marked `unverified` or `unclear`, check `docs.github.com` live before coding that step — do not guess field names.
