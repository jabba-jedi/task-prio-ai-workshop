# Tasks: Supabase Database Logging

**Input**: Design documents from `/specs/003-supabase-logging/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: NOT included - feature specification does not request TDD approach. Manual testing via browser and Supabase dashboard.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- **Single-page web app**: All code in `index.html` (existing structure)
- **Configuration**: `.env` for environment variables
- **Documentation**: `.env.example` for credential templates

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Install dependencies and configure environment for Supabase integration

- [X] T001 Install @supabase/supabase-js package via npm (add to package.json dependencies)
- [X] T002 Update .env.example with Supabase credential template (VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY placeholders)
- [X] T003 Verify .env is in .gitignore to prevent credential exposure

**Checkpoint**: Dependencies installed, environment template ready for Supabase credentials

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Supabase project setup and database schema creation - MUST be complete before ANY user story implementation

**⚠️ CRITICAL**: No user story work can begin until Supabase project exists with the database table

**External Setup (Manual - Not Code Tasks)**:
1. Create Supabase project at https://supabase.com (5 minutes)
2. Run database schema SQL to create `task_submissions` table (from contracts/database-schema.json)
3. Configure RLS policies to allow anonymous inserts (from quickstart.md Step 4)
4. Copy Supabase URL and anon key to local `.env` file

- [X] T004 Follow quickstart.md Steps 1-4 to create Supabase project and database table (manual setup)
- [X] T005 Add VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY to local .env file with actual credentials
- [X] T006 Restart Vite dev server to load new environment variables
- [X] T007 Verify environment variables are accessible: check `import.meta.env.VITE_SUPABASE_URL` in browser console

**Checkpoint**: Supabase project ready with database table and RLS policies configured - user story implementation can now begin

---

## Phase 3: User Story 1 - Transparent Task Analysis Persistence (Priority: P1) 🎯 MVP

**Goal**: Log task submissions to Supabase database after successful Gemini analysis without blocking the UI or affecting user experience

**Independent Test**: Submit a task, verify analysis displays immediately, then check Supabase Table Editor to confirm the record was created with all 7 fields (task_text, priority, categories, complexity, suggested_order, created_at, id)

### Implementation for User Story 1

- [X] T008 [US1] Add Supabase client import at top of `<script type="module">` in index.html: `import { createClient } from '@supabase/supabase-js'`
- [X] T009 [US1] Create getSupabaseClient() singleton function in index.html that loads credentials from import.meta.env and returns client instance (or null if credentials missing)
- [X] T010 [US1] Create validateTaskSubmission() function in index.html to check taskText and analysis object have all required fields with correct types per data-model.md validation rules
- [X] T011 [US1] Create logTaskSubmission() async function in index.html that accepts (taskText, analysis), calls getSupabaseClient(), validates data, and performs supabase.from('task_submissions').insert()
- [X] T012 [US1] Update existing Gemini success handler in index.html to call logTaskSubmission() with .catch() (fire-and-forget pattern - no await) after displayResults()
- [X] T013 [US1] Add console.log() for successful database insert in logTaskSubmission() function for debugging visibility
- [X] T014 [US1] Test happy path: Submit task "Test database logging", verify analysis displays, check browser console for success log, verify record in Supabase Table Editor

**Checkpoint**: User Story 1 complete - task submissions are silently logged to database after successful AI analysis with zero UI impact

---

## Phase 4: User Story 2 - Graceful Handling of Database Failures (Priority: P1)

**Goal**: Ensure application continues working and displays AI analysis even when database operations fail, with non-intrusive user feedback

**Independent Test**: Temporarily change VITE_SUPABASE_URL in .env to invalid value, restart server, submit task, verify AI analysis still displays with a subtle warning banner (not error modal)

### Implementation for User Story 2

- [X] T015 [US2] Add error handling in logTaskSubmission() function in index.html to catch all database errors and re-throw with descriptive message
- [X] T016 [US2] Create showWarning() function in index.html that creates a dismissible warning banner element with yellow background, inserts it after results section
- [X] T017 [US2] Update logTaskSubmission() .catch() handler in Gemini success flow to call showWarning('Note: Task history could not be saved at this time')
- [X] T018 [US2] Add console.warn() in catch block for debugging while keeping UI working
- [X] T019 [US2] Add CSS styles for warning banner in index.html: yellow background (#fff3cd), border-left accent (#ffc107), auto-dismiss after 5 seconds
- [X] T020 [US2] Implement auto-dismiss: setTimeout to remove warning banner after 5000ms
- [X] T021 [US2] Test network error: disconnect internet, submit task, verify AI analysis displays with warning banner
- [X] T022 [US2] Test auth error: use invalid VITE_SUPABASE_ANON_KEY, submit task, verify graceful degradation with warning
- [X] T023 [US2] Test service outage: temporarily disable Supabase project, submit task, verify analysis works with warning

**Checkpoint**: User Story 2 complete - database failures never break AI analysis display, users see subtle warnings for logging issues

---

## Phase 5: User Story 3 - Configure Database Connection Securely (Priority: P1)

**Goal**: Ensure Supabase credentials are loaded from environment variables and application handles missing configuration gracefully

**Independent Test**: Remove VITE_SUPABASE_URL from .env, restart server, submit task, verify AI analysis works but logging is silently disabled with console warning (no user error)

### Implementation for User Story 3

- [X] T024 [US3] Update getSupabaseClient() in index.html to check for both VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY before creating client
- [X] T025 [US3] Add console.warn() in getSupabaseClient() when credentials are missing: "Supabase credentials not configured - logging disabled"
- [X] T026 [US3] Update logTaskSubmission() in index.html to return early (silently) if getSupabaseClient() returns null
- [X] T027 [US3] Test missing URL: remove VITE_SUPABASE_URL from .env, restart server, submit task, verify analysis works, check console for warning, confirm no database insert
- [X] T028 [US3] Test missing key: remove VITE_SUPABASE_ANON_KEY from .env, restart server, submit task, verify same graceful behavior
- [X] T029 [US3] Test both missing: remove both variables, verify application continues working without any user-facing errors
- [X] T030 [US3] Verify .env.example has clear comments explaining where to get Supabase credentials (reference quickstart.md)

**Checkpoint**: User Story 3 complete - environment variable configuration works securely, missing credentials degrade gracefully without breaking app

---

## Phase 6: User Story 4 - Verify Data Persistence Through History (Priority: P2)

**Goal**: Enable developers to query and verify logged data in Supabase dashboard, confirming all fields are persisted correctly

**Independent Test**: Submit 3-5 different tasks through UI with varying priorities, then query Supabase Table Editor and verify all records appear with complete data in chronological order

### Implementation for User Story 4

- [ ] T031 [US4] Add code comment in index.html near logTaskSubmission() documenting the data mapping: which Gemini fields map to which database columns
- [ ] T032 [US4] Verify field mapping matches data-model.md: priority→priority, categories→categories, complexity→complexity, suggestion→suggested_order
- [ ] T033 [US4] Test data accuracy: Submit task "Fix critical security vulnerability", verify Supabase record has exact text and correct AI analysis fields
- [ ] T034 [US4] Test categories array: Submit task that generates 5+ categories, verify array is preserved in database with correct order
- [ ] T035 [US4] Test special characters: Submit task with quotes, newlines, emoji, verify exact preservation in database task_text field
- [ ] T036 [US4] Test timestamp accuracy: Submit task, note time, verify created_at in database is within 1 second of submission time
- [ ] T037 [US4] Use quickstart.md SQL query examples to verify: count by priority, filter by category, recent submissions
- [ ] T038 [US4] Test multiple concurrent submissions: Submit 5 tasks rapidly, verify all 5 appear in database with unique IDs

**Checkpoint**: User Story 4 complete - developers can verify data persistence via Supabase dashboard, all fields are accurately logged

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Code quality improvements and final validation

- [ ] T039 [P] Add inline code comments in index.html explaining fire-and-forget pattern for future developers
- [ ] T040 [P] Add JSDoc comments for getSupabaseClient(), validateTaskSubmission(), logTaskSubmission(), and showWarning() functions
- [ ] T041 Verify all console.log/warn statements are appropriately placed (success logs, error warnings, configuration warnings)
- [ ] T042 Run through quickstart.md verification checklist (11 items) to ensure all setup steps work correctly
- [ ] T043 Test all 8 edge cases from spec.md: slow response, network timeout, schema mismatch, long text, quota limits, large categories, duplicates, invalid timestamps
- [ ] T044 [P] Verify .env is not committed (check git status, ensure it's in .gitignore)
- [ ] T045 [P] Update .env.example with helpful comments about Supabase free tier limits and RLS policy requirements
- [ ] T046 Perform final end-to-end test: Fresh .env setup → Supabase project creation → Task submission → Database verification
- [ ] T047 Document any workshop-specific gotchas or common issues in quickstart.md troubleshooting section

**Checkpoint**: Feature complete, polished, and ready for workshop demonstration

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion (T001-T003) - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion (T004-T007)
  - User Story 1 (Phase 3): Can start after Foundational - No dependencies on other stories
  - User Story 2 (Phase 4): Depends on User Story 1 completion (T008-T014) - needs logTaskSubmission() to exist
  - User Story 3 (Phase 5): Depends on User Story 1 completion (T008-T014) - modifies getSupabaseClient() and logTaskSubmission()
  - User Story 4 (Phase 6): Depends on User Stories 1-3 completion - validates full integration
- **Polish (Phase 7)**: Depends on all user stories being complete (T008-T038)

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - implements core logging functionality
- **User Story 2 (P1)**: Depends on User Story 1 - adds error handling to existing logging function
- **User Story 3 (P1)**: Depends on User Story 1 - adds credential validation to existing functions
- **User Story 4 (P2)**: Depends on User Stories 1-3 - verification and testing of complete integration

### Within Each User Story

**User Story 1** (Sequential):
1. T008: Import statement (first)
2. T009: getSupabaseClient() (needed by T011)
3. T010: validateTaskSubmission() (needed by T011)
4. T011: logTaskSubmission() (needs T009, T010)
5. T012: Integration with Gemini handler (needs T011)
6. T013: Console logging (enhances T011)
7. T014: Testing (validates all above)

**User Story 2** (Sequential after US1):
1. T015: Error handling (modifies T011)
2. T016: showWarning() function (needed by T017)
3. T017: Update catch handler (needs T016)
4. T018: Console warning (enhances error handling)
5. T019: CSS styles (needed for T016 to look correct)
6. T020: Auto-dismiss (enhances T016)
7. T021-T023: Testing (validates all above)

**User Story 3** (Sequential after US1):
1. T024: Update getSupabaseClient() (modifies T009)
2. T025: Console warning (enhances T024)
3. T026: Update logTaskSubmission() (modifies T011)
4. T027-T029: Testing (validates modifications)
5. T030: Documentation (final step)

**User Story 4** (Mostly parallel after US1-3):
1. T031: Code comments (can do anytime)
2. T032: Verify field mapping (validation)
3. T033-T038: All testing tasks (can run in any order once T031-T032 done)

### Parallel Opportunities

- **Phase 1 (Setup)**: T001, T002, T003 can all run in parallel (different files/tasks)
- **Phase 7 (Polish)**: T039, T040, T044, T045 can all run in parallel (different concerns)
- **User Story 4**: T033-T038 testing tasks can run in parallel (independent test scenarios)
- **Note**: Most tasks in this feature are sequential because they modify the same file (index.html) and build on each other

---

## Parallel Example: User Story 4 Testing

```bash
# Launch all verification tests for User Story 4 together:
Task: "Test data accuracy with security vulnerability task"
Task: "Test categories array preservation with 5+ items"
Task: "Test special characters in task text"
Task: "Test timestamp accuracy within 1 second"
Task: "Test multiple concurrent submissions (5 tasks)"
Task: "Run SQL queries from quickstart.md"
```

---

## Implementation Strategy

### MVP First (User Stories 1-3 Only)

1. **Complete Phase 1**: Setup (T001-T003) - 5 minutes
2. **Complete Phase 2**: Foundational (T004-T007) - 20 minutes (includes Supabase project creation)
3. **Complete Phase 3**: User Story 1 (T008-T014) - 30 minutes (core logging implementation)
4. **Complete Phase 4**: User Story 2 (T015-T023) - 25 minutes (error handling)
5. **Complete Phase 5**: User Story 3 (T024-T030) - 15 minutes (credential validation)
6. **STOP and VALIDATE**: Test all three P1 user stories independently
7. **Deploy/demo**: MVP is ready with complete logging, error handling, and graceful degradation

**Total MVP Time**: ~95 minutes (1.5 hours)

### Incremental Delivery

1. **Foundation** (Phase 1+2): Setup + Supabase project → Environment ready (~25 min)
2. **MVP Core** (Phase 3): User Story 1 → Basic logging works → Test independently (~30 min)
3. **MVP Resilience** (Phase 4): User Story 2 → Error handling added → Test independently (~25 min)
4. **MVP Complete** (Phase 5): User Story 3 → Configuration complete → Test independently (~15 min)
5. **Enhancement** (Phase 6): User Story 4 → Verification tools → Test independently (~30 min)
6. **Polish** (Phase 7): Final improvements → Production-ready (~25 min)

**Total Complete Time**: ~150 minutes (2.5 hours)

### Single Developer Strategy

**Day 1 Session (~2 hours)**:
- Morning: Phase 1-2 (Setup + Foundational) - 25 min
- Morning: Phase 3 (User Story 1) - 30 min
- Morning: Phase 4 (User Story 2) - 25 min
- Morning: Phase 5 (User Story 3) - 15 min
- **Break & Test**: Validate MVP (all P1 stories)
- Afternoon: Phase 6 (User Story 4) - 30 min
- Afternoon: Phase 7 (Polish) - 25 min
- **Final Test**: Full integration validation

### Parallel Team Strategy

**Not applicable** - Single file (index.html) means parallel development would cause merge conflicts. This is a sequential feature best implemented by one developer.

However, documentation tasks can be parallel:
- Developer A: Implementation (T008-T038)
- Developer B: Documentation review and quickstart.md validation (T042, T045, T047)

---

## Notes

- **[P] tasks**: Different files/concerns, no dependencies, safe to parallelize
- **[Story] label**: Maps task to specific user story for traceability and independent testing
- **Single file constraint**: Most tasks modify index.html, so sequential execution required
- **Fire-and-forget pattern**: Critical design decision - logTaskSubmission() is never awaited
- **Manual setup**: Supabase project creation (T004) is external, not code
- **Environment variables**: Must restart Vite dev server after changing .env
- **Testing approach**: Manual browser testing + Supabase dashboard verification (no automated tests)
- **Commit strategy**: Commit after each user story phase completion (T014, T023, T030, T038)
- **Stop at any checkpoint**: Each user story should be independently testable and demoable

---

## Task Count Summary

- **Phase 1 (Setup)**: 3 tasks
- **Phase 2 (Foundational)**: 4 tasks
- **Phase 3 (User Story 1 - P1)**: 7 tasks ← MVP Core
- **Phase 4 (User Story 2 - P1)**: 9 tasks ← MVP Resilience
- **Phase 5 (User Story 3 - P1)**: 7 tasks ← MVP Complete
- **Phase 6 (User Story 4 - P2)**: 8 tasks ← Enhancement
- **Phase 7 (Polish)**: 9 tasks ← Final Polish

**Total**: 47 tasks

**MVP Scope** (Phases 1-5): 30 tasks, ~95 minutes
**Complete Scope** (All phases): 47 tasks, ~150 minutes

---

## Validation Checklist

Before marking feature complete, verify:

- [ ] All 47 tasks have checkboxes (- [ ])
- [ ] All tasks have sequential IDs (T001-T047)
- [ ] User story tasks (US1-US4) have [Story] labels
- [ ] Parallel tasks have [P] markers where appropriate
- [ ] All implementation tasks reference specific file paths (index.html, .env, .env.example)
- [ ] Each user story has an "Independent Test" that can verify it works standalone
- [ ] Each phase has a checkpoint describing what should be working
- [ ] Dependencies are documented showing story completion order
- [ ] MVP scope is clearly identified (User Stories 1-3)
- [ ] Estimated times are provided for planning purposes
- [ ] Fire-and-forget pattern is emphasized in User Story 1 tasks
- [ ] Graceful degradation is tested in User Stories 2 and 3
- [ ] All 8 edge cases from spec.md are covered in Polish phase


