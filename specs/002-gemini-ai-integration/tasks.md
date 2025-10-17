# Tasks: Gemini AI Integration for Task Prioritization

**Feature Branch**: `002-gemini-ai-integration`  
**Input**: Design documents from `/specs/002-gemini-ai-integration/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Manual browser testing per quickstart.md (no automated tests requested in this phase)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4, US5)
- Include exact file paths in descriptions

## Path Conventions
- **Single HTML file architecture**: All modifications in `index.html`
- **Environment config**: `.env.example` in repository root
- **Dependencies**: `package.json` in repository root
- Paths are relative to repository root: `/Users/maryia.yermakovich/Projects/task-prio-ai-workshop/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and dependency installation

- [x] T001 Install @google/generative-ai npm package (run `npm install @google/generative-ai` in project root)
- [x] T002 [P] Create .env.example file with VITE_GEMINI_API_KEY placeholder in project root
- [x] T003 [P] Verify .env is listed in .gitignore to prevent API key commits

**Checkpoint**: Dependencies installed, environment template ready

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Add ES module import for GoogleGenerativeAI at top of `<script type="module">` section in index.html
- [x] T005 Create constructPrompt() utility function in index.html that builds the structured prompt with task description and JSON format instructions
- [x] T006 Create validateGeminiResponse() function in index.html that checks for all required fields (priority, categories, complexity, suggestion) and validates enum values
- [x] T007 Create classifyError() function in index.html that maps API errors to user-friendly error messages (7 error types: API_KEY_MISSING, NETWORK_ERROR, AUTH_ERROR, RATE_LIMIT, PARSE_ERROR, VALIDATION_ERROR, UNKNOWN_ERROR)
- [x] T008 Update existing error message container styles in index.html to support different error types (if needed)

**Checkpoint**: Foundation ready - all utility functions in place, user story implementation can now begin

---

## Phase 3: User Story 2 - Configure API Access via Environment Variables (Priority: P1) 🎯 Setup MVP

**Goal**: Enable developers to configure Gemini API key via environment variables for secure authentication

**Independent Test**: Set VITE_GEMINI_API_KEY in .env file, start dev server, verify API key is loaded (can check in browser console temporarily during dev)

### Implementation for User Story 2

- [x] T009 [US2] Add API key check at application initialization in index.html: `const apiKey = import.meta.env.VITE_GEMINI_API_KEY`
- [x] T010 [US2] Add conditional logic to detect missing API key and show configuration error message using classifyError() function
- [x] T011 [US2] Initialize GoogleGenerativeAI client with API key in index.html: `const genAI = new GoogleGenerativeAI(apiKey)`
- [x] T012 [US2] Get gemini-1.5-flash model instance in index.html: `const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' })`
- [x] T013 [US2] Test with valid API key: verify application loads without errors and API client is initialized
- [x] T014 [US2] Test with missing API key: verify "Gemini API key not configured" error displays on form submission

**Checkpoint**: Environment configuration working - API key properly loaded and validated

---

## Phase 4: User Story 1 - Receive AI-Powered Task Analysis (Priority: P1) 🎯 Core MVP

**Goal**: Replace hardcoded mock data with real-time Gemini AI analysis that provides contextual insights for any task

**Independent Test**: Enter novel task "Implement OAuth2 authentication for mobile app", click submit, verify AI returns contextually relevant analysis with all 4 fields

### Implementation for User Story 1

- [x] T015 [US1] Create async analyzeTaskWithGemini() function in index.html that accepts taskDescription parameter
- [x] T016 [US1] Implement API request construction in analyzeTaskWithGemini(): call constructPrompt() and create request object with contents array and generationConfig (responseMimeType: 'application/json', temperature: 0.3, maxOutputTokens: 1024)
- [x] T017 [US1] Implement API call in analyzeTaskWithGemini(): call model.generateContent() and await response
- [x] T018 [US1] Implement response parsing in analyzeTaskWithGemini(): call result.response.text() and JSON.parse()
- [x] T019 [US1] Implement response validation in analyzeTaskWithGemini(): call validateGeminiResponse() and throw error if validation fails
- [x] T020 [US1] Return validated analysis object with priority, categories, complexity, and suggestion fields
- [x] T021 [US1] Update form submit handler to call analyzeTaskWithGemini() instead of mock data function (make handler async)
- [x] T022 [US1] Verify existing displayResults() function works with AI-generated analysis (should work without changes)
- [x] T023 [US1] Test with task "Fix the bug in the login form": verify AI returns HIGH priority with security-related categories
- [x] T024 [US1] Test with task "Update README documentation": verify AI returns LOW priority with documentation categories
- [x] T025 [US1] Test with task "Add dark mode toggle": verify AI returns MEDIUM priority with feature categories

**Checkpoint**: Core AI integration complete - real-time task analysis working with contextual insights

---

## Phase 5: User Story 3 - Understand API Failures Through Clear Error Messages (Priority: P1) 🎯 Reliability MVP

**Goal**: Provide clear, actionable error messages for all API failure scenarios so users understand what went wrong

**Independent Test**: Simulate each error type (invalid key, network offline, etc.) and verify specific user-friendly message displays

### Implementation for User Story 3

- [x] T026 [US3] Wrap API call in try-catch block in analyzeTaskWithGemini() function
- [x] T027 [US3] Implement network error detection: catch fetch failures and errors with 'network' in message
- [x] T028 [US3] Implement authentication error detection: check for status codes 401 and 403
- [x] T029 [US3] Implement rate limit error detection: check for status code 429
- [x] T030 [US3] Implement parse error detection: catch SyntaxError from JSON.parse()
- [x] T031 [US3] Implement validation error detection: catch errors from validateGeminiResponse()
- [x] T032 [US3] Implement fallback error handling: catch all other errors with generic message
- [x] T033 [US3] Call classifyError() for each error type and return error object with user-friendly message
- [x] T034 [US3] Update form submit handler to detect error responses and call showError() to display error message
- [x] T035 [US3] Ensure error messages are displayed in existing error container with proper styling
- [x] T036 [US3] Test network error: disconnect internet, submit task, verify "Unable to connect to AI service" message
- [x] T037 [US3] Test authentication error: use invalid API key, submit task, verify "API authentication failed" message
- [x] T038 [US3] Test with various tasks to ensure errors are caught gracefully and UI remains responsive

**Checkpoint**: Error handling complete - all failure scenarios show clear, actionable messages

---

## Phase 6: User Story 4 - Experience Responsive Feedback During API Calls (Priority: P2)

**Goal**: Show loading indicator during API calls so users know their request is being processed

**Independent Test**: Submit task, verify loading indicator appears immediately, remains visible during API call, and disappears when results display

### Implementation for User Story 4

- [x] T039 [US4] Add loading state management before API call in form submit handler: set submitButton.disabled = true and submitButton.textContent = 'Analyzing...'
- [x] T040 [US4] Clear any existing error messages before API call: errorMessage.classList.add('hidden')
- [x] T041 [US4] Add finally block to form submit handler to reset loading state: submitButton.disabled = false and submitButton.textContent = 'Analyze Task'
- [x] T042 [US4] Verify loading state works for successful API calls: button shows "Analyzing..." then resets to "Analyze Task"
- [x] T043 [US4] Verify loading state works for failed API calls: button shows "Analyzing..." then resets to "Analyze Task" with error displayed
- [x] T044 [US4] Test rapid clicking: verify disabled button prevents duplicate submissions while API call is in progress

**Checkpoint**: Loading feedback complete - users see clear indication of API processing

---

## Phase 7: User Story 5 - Maintain Application Usability Across Different Task Inputs (Priority: P2)

**Goal**: Ensure AI integration handles diverse task inputs (short, long, vague, technical) reliably

**Independent Test**: Submit variety of task types and verify each produces valid analysis with all required fields

### Implementation for User Story 5

- [x] T045 [US5] Review existing validation logic to ensure it handles edge cases (empty responses, missing fields)
- [x] T046 [US5] Test with very short task "Fix bug": verify AI generates complete analysis with all 4 fields
- [x] T047 [US5] Test with lengthy task (3-4 sentences): verify AI analyzes full context and returns structured results
- [x] T048 [US5] Test with vague task "Make it better": verify AI provides analysis acknowledging ambiguity in suggestion field
- [x] T049 [US5] Test with technical jargon "Refactor Redis connection pooling for horizontal scalability": verify AI demonstrates understanding in categories
- [x] T050 [US5] Test with non-technical task "Update marketing website colors": verify AI provides appropriate categorization
- [x] T051 [US5] Verify response validation catches any malformed responses and shows appropriate error message

**Checkpoint**: Robustness complete - AI integration handles diverse inputs gracefully

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements and validation

- [x] T052 Remove or comment out any console.log statements used for debugging (except intentional error logging)
- [x] T053 [P] Review prompt construction in constructPrompt() function to ensure clear instructions and examples for Gemini
- [x] T054 [P] Verify .env file is not committed to Git (check git status)
- [x] T055 Add comments to key sections of code explaining Gemini integration logic
- [x] T056 Run complete manual testing checklist from quickstart.md (normal flow, error scenarios, edge cases)
- [x] T057 Verify API key security: check that key is not exposed in console logs or network inspector (beyond standard request headers)
- [x] T058 Test complete workflow: setup .env → install deps → start dev server → submit various tasks → verify all features working

**Checkpoint**: Feature complete and ready for workshop demonstration

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion (T001-T003) - BLOCKS all user stories
- **User Story 2 (Phase 3)**: Depends on Foundational (T004-T008) - Environment configuration must be in place first
- **User Story 1 (Phase 4)**: Depends on US2 completion (T009-T014) - Cannot make API calls without configured API key
- **User Story 3 (Phase 5)**: Depends on US1 completion (T015-T025) - Cannot test error handling without working API integration
- **User Story 4 (Phase 6)**: Depends on US1 completion (T015-T025) - Loading states wrap existing API call flow
- **User Story 5 (Phase 7)**: Depends on US1 and US3 completion (T015-T038) - Testing robustness requires working integration and error handling
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

**Strict Sequential Order** (due to single-file architecture):

1. **User Story 2 (P1)**: API key configuration - MUST complete first (enables API access)
2. **User Story 1 (P1)**: Core AI integration - MUST complete second (provides functionality to enhance)
3. **User Story 3 (P1)**: Error handling - MUST complete third (wraps US1 implementation)
4. **User Story 4 (P2)**: Loading states - Can complete after US1 (enhances US1)
5. **User Story 5 (P2)**: Input robustness - Can complete after US1 and US3 (validates US1 and US3)

**Rationale**: Single HTML file means most changes modify the same code sections, requiring sequential implementation to avoid conflicts.

### Within Each User Story

- Foundational utility functions (Phase 2) before any user story implementation
- API client initialization (US2) before making API calls (US1)
- Core API integration (US1) before error handling (US3) or loading states (US4)
- All logic changes before testing tasks

### Parallel Opportunities

**Limited** due to single-file architecture:
- T002 and T003 can run in parallel (different files: .env.example and .gitignore)
- Within a phase, tasks marked [P] in polish phase can run in parallel if working on different sections

**Note**: Most tasks modify the same `index.html` file, so true parallel execution is limited. However, with careful planning, different developers could work on different functions within the file.

---

## Execution Order Summary

### Critical Path (Must be sequential)
```
T001-T003 (Setup)
  ↓
T004-T008 (Foundational utilities)
  ↓
T009-T014 (US2: API key config)
  ↓
T015-T025 (US1: Core AI integration)
  ↓
T026-T038 (US3: Error handling)
  ↓
T039-T044 (US4: Loading states) AND T045-T051 (US5: Robustness) can overlap if coordinated
  ↓
T052-T058 (Polish)
```

---

## Parallel Example: Foundational Phase

```bash
# These utility functions can be developed in parallel if different developers work on them:
Task T005: "Create constructPrompt() utility function"
Task T006: "Create validateGeminiResponse() function"
Task T007: "Create classifyError() function"

# Then integrate them sequentially into the main flow
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 + 3 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T008) - CRITICAL - blocks all stories
3. Complete Phase 3: User Story 2 (T009-T014) - API key configuration
4. Complete Phase 4: User Story 1 (T015-T025) - Core AI integration
5. Complete Phase 5: User Story 3 (T026-T038) - Error handling
6. **STOP and VALIDATE**: Test with various tasks and error scenarios
7. Deploy/demo if ready

**Estimated Effort**: ~2-3 hours for experienced developer

### Incremental Delivery

1. **Checkpoint 1**: After US2 (T009-T014)
   - Can verify API key loading and initialization
   - Cannot submit tasks yet (no API integration)
   
2. **Checkpoint 2**: After US1 (T015-T025) ⭐ **First Functional MVP**
   - Can submit tasks and get AI analysis
   - Errors may not be handled gracefully
   - No loading indicator yet
   
3. **Checkpoint 3**: After US3 (T026-T038) ⭐ **Reliable MVP**
   - All error scenarios handled with clear messages
   - Production-ready error handling
   - Still no loading indicator
   
4. **Checkpoint 4**: After US4 (T039-T044) ⭐ **Polished MVP**
   - Loading states provide feedback during API calls
   - Professional user experience
   
5. **Checkpoint 5**: After US5 (T045-T051) ⭐ **Robust MVP**
   - Handles diverse task inputs reliably
   - Edge cases validated

### Single Developer Strategy

**Day 1** (2-3 hours):
- Morning: Complete Setup + Foundational + US2 (T001-T014)
- Afternoon: Complete US1 + US3 (T015-T038)
- **Result**: Functional, reliable AI integration

**Day 2** (1 hour):
- Complete US4 + US5 + Polish (T039-T058)
- **Result**: Polished, robust feature ready for workshop

---

## Testing Strategy

### Manual Testing Per Phase

**After Phase 3 (US2)**:
- [ ] Verify API key loads from .env
- [ ] Verify missing key shows error message

**After Phase 4 (US1)**:
- [ ] Submit "Fix security bug" → expect HIGH priority, security categories
- [ ] Submit "Update docs" → expect LOW priority, documentation categories
- [ ] Submit "Add feature" → expect MEDIUM priority, feature categories

**After Phase 5 (US3)**:
- [ ] Disconnect internet → expect network error message
- [ ] Use invalid key → expect auth error message
- [ ] Rapid submissions → expect rate limit handling (if triggered)

**After Phase 6 (US4)**:
- [ ] Submit task → verify button shows "Analyzing..." and is disabled
- [ ] Verify button resets after success
- [ ] Verify button resets after error

**After Phase 7 (US5)**:
- [ ] Test short task: "Fix bug"
- [ ] Test long task: 3-4 sentence description
- [ ] Test vague task: "Make it better"
- [ ] Test technical task: "Optimize Redis cache"

### Complete Test Checklist (from quickstart.md)

Run these after Phase 8 completion:
- [ ] Empty submission shows error
- [ ] Valid task shows AI analysis (not mock data)
- [ ] Results display in side-by-side layout
- [ ] Loading state appears during API call
- [ ] Errors show user-friendly messages
- [ ] Multiple submissions work correctly
- [ ] API key not visible in console logs (beyond request headers)
- [ ] All four fields present in analysis (priority, categories, complexity, suggestion)

---

## Notes

- **Single file architecture**: Most tasks modify `index.html`, so sequential execution recommended
- **API key security**: Always verify .env is not committed (T054)
- **Error handling**: Test all 7 error types before considering feature complete
- **Workshop context**: Frontend API calls are acceptable for demo purposes (documented in spec)
- **Commit strategy**: Commit after each phase completion for easy rollback
- **Testing**: Manual browser testing per quickstart.md (no automated tests in this phase)
- **Dependencies**: Only one new npm package (@google/generative-ai)
- **Code organization**: All logic in single `<script type="module">` section of index.html

---

## Task Completion Criteria

Each task is complete when:
- [ ] Code is written and saved in specified file
- [ ] Code follows existing style and patterns in index.html
- [ ] Manual testing verifies functionality (if testable at that point)
- [ ] No console errors appear in browser DevTools
- [ ] Changes are committed to Git with descriptive message
- [ ] Ready to proceed to next task in sequence

**Total Tasks**: 58 tasks across 8 phases
- Phase 1 (Setup): 3 tasks
- Phase 2 (Foundational): 5 tasks
- Phase 3 (US2): 6 tasks
- Phase 4 (US1): 11 tasks
- Phase 5 (US3): 13 tasks
- Phase 6 (US4): 6 tasks
- Phase 7 (US5): 7 tasks
- Phase 8 (Polish): 7 tasks

**Estimated Total Effort**: 2-4 hours for experienced developer

---

## Quick Reference: File Changes

| File | Change Type | Tasks |
|------|-------------|-------|
| `package.json` | Modified (add dependency) | T001 |
| `.env.example` | New file | T002 |
| `.gitignore` | Verify | T003 |
| `index.html` | Modified (add ~100-150 lines) | T004-T051 |

**Core Changes in index.html**:
1. Add ES module import for GoogleGenerativeAI (T004)
2. Add 3 utility functions (T005-T007)
3. Add API initialization logic (T009-T012)
4. Add async analyzeTaskWithGemini() function (T015-T020)
5. Update form submit handler to async (T021)
6. Add error handling try-catch (T026-T034)
7. Add loading state management (T039-T041)

**No changes needed**:
- `vite.config.js` (existing config works as-is)
- Existing UI components (work without modification)
- Existing CSS styles (compatible with new functionality)

