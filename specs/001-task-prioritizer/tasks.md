# Tasks: Task Prioritizer Application

**Input**: Design documents from `/specs/001-task-prioritizer/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Tests are OPTIONAL - not included since this is a workshop demo with browser-based manual testing per plan.md.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- Single HTML file at repository root: `index.html`
- Configuration files: `package.json`, `vite.config.js`
- All HTML, CSS, and JavaScript embedded in `index.html`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and Vite configuration

- [x] T001 Initialize npm project with package.json in /Users/maryia.yermakovich/Projects/task-prio-ai-workshop/package.json
- [x] T002 Install Vite as dev dependency (npm install -D vite@latest)
- [x] T003 Create minimal vite.config.js in /Users/maryia.yermakovich/Projects/task-prio-ai-workshop/vite.config.js
- [x] T004 Add npm scripts (dev, build, preview) to package.json

**Checkpoint**: Project structure ready - can start implementing user stories

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core HTML structure and data infrastructure that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Create index.html with basic HTML5 structure in /Users/maryia.yermakovich/Projects/task-prio-ai-workshop/index.html
- [x] T006 Add page metadata (title, viewport, charset) to index.html
- [x] T007 Create empty `<style>` tag in `<head>` for embedded CSS in index.html
- [x] T008 Create empty `<script>` tag before `</body>` for embedded JavaScript in index.html
- [x] T009 Implement mock data object in `<script>` section per contracts/mock-data.json

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 2 - Enter Task Description (Priority: P1) 🎯 MVP Component 1

**Goal**: Allow users to type or paste task descriptions into a textarea input field

**Independent Test**: Open the page, textarea is visible and accepts text input without modification

### Implementation for User Story 2

- [x] T010 [US2] Create `<main>` container with semantic HTML structure in index.html
- [x] T011 [US2] Add `<h1>Task Prioritizer</h1>` heading to main container in index.html
- [x] T012 [US2] Create `<form id="task-form">` in main container in index.html
- [x] T013 [US2] Add `<label for="task-input">` with text "Enter Task Description" in form in index.html
- [x] T014 [US2] Create `<textarea id="task-input" maxlength="10000" rows="8">` in form in index.html
- [x] T015 [US2] Add basic textarea styling (border, padding, font, width) in `<style>` section in index.html
- [x] T016 [US2] Add responsive textarea styling (mobile-friendly sizing) in `<style>` section in index.html
- [x] T017 [US2] Add CSS to preserve user input formatting (white-space: pre-wrap) in `<style>` section in index.html

**Checkpoint**: Textarea component complete and independently testable (FR-002, FR-003)

---

## Phase 4: User Story 3 - Submit for Analysis (Priority: P1) 🎯 MVP Component 2

**Goal**: Allow users to trigger analysis by clicking a submit button

**Independent Test**: Button is visible, clickable, and prevents empty submissions with error message

### Implementation for User Story 3

- [x] T018 [US3] Add `<button type="submit">Analyze Task</button>` to form in index.html
- [x] T019 [US3] Create `<div id="error-message" class="error hidden">` below button for validation feedback in index.html
- [x] T020 [US3] Add button styling (padding, background, hover state, cursor) in `<style>` section in index.html
- [x] T021 [US3] Add error message styling (color: red, display/hidden states) in `<style>` section in index.html
- [x] T022 [US3] Implement validateTaskInput(text) function in `<script>` section per data-model.md validation rules in index.html
- [x] T023 [US3] Implement form submit event handler with preventDefault() in `<script>` section in index.html
- [x] T024 [US3] Add validation logic to show error for empty textarea (FR-009) in handleSubmit function in index.html
- [x] T025 [US3] Add validation logic to clear error on valid input in handleSubmit function in index.html
- [x] T026 [US3] Add focus/blur event handlers to clear error message in `<script>` section in index.html

**Checkpoint**: Form submission with validation complete and independently testable (FR-004, FR-009)

---

## Phase 5: User Story 1 - View Task Analysis (Priority: P1) 🎯 MVP Component 3

**Goal**: Display original task and AI analysis in side-by-side panels

**Independent Test**: Submit valid task and see both panels appear with correct data in side-by-side layout

### Implementation for User Story 1

- [x] T027 [US1] Create `<div id="results-container" class="hidden">` after form in index.html
- [x] T028 [P] [US1] Create left panel `<div class="panel">` with `<h2>Original Task</h2>` and `<div id="original-task">` in results-container in index.html
- [x] T029 [P] [US1] Create right panel `<div class="panel">` with `<h2>AI Analysis</h2>` and `<div id="analysis-result">` in results-container in index.html
- [x] T030 [US1] Add CSS Grid layout to #results-container (grid-template-columns: 1fr 1fr, gap: 2rem) in `<style>` section in index.html
- [x] T031 [US1] Add panel styling (border, padding, background, border-radius) in `<style>` section in index.html
- [x] T032 [US1] Add responsive media query (@media max-width: 768px) to stack panels in `<style>` section in index.html
- [x] T033 [US1] Add .hidden class utility (display: none) in `<style>` section in index.html
- [x] T034 [US1] Implement analyzeTask(taskDescription) function using mock data lookup in `<script>` section in index.html
- [x] T035 [US1] Implement displayResults(submission) function to populate #original-task in `<script>` section in index.html
- [x] T036 [US1] Add displayAnalysis helper to format and display priority, categories, complexity, suggestedOrder in #analysis-result in `<script>` section in index.html
- [x] T037 [US1] Add logic to show #results-container (remove .hidden) after successful submission in handleSubmit in index.html
- [x] T038 [US1] Add styling for analysis output (priority badges, category tags, complexity indicators) in `<style>` section in index.html
- [x] T039 [US1] Ensure original task text displays with preserved whitespace and line breaks in `<style>` section in index.html

**Checkpoint**: Core MVP complete - can enter task, submit, and view side-by-side analysis (FR-005, FR-006, FR-007, FR-008)

---

## Phase 6: User Story 4 - Review Multiple Tasks (Priority: P2)

**Goal**: Allow users to submit multiple tasks sequentially with results updating

**Independent Test**: Submit one task, change textarea, submit again, verify new results replace old ones

### Implementation for User Story 4

- [x] T040 [US4] Add logic to clear previous results before displaying new ones in displayResults function in index.html
- [x] T041 [US4] Update handleSubmit to support repeated submissions (FR-010) in `<script>` section in index.html
- [x] T042 [US4] Add fade transition for results update in `<style>` section in index.html
- [x] T043 [US4] Test rapid multiple submissions (edge case handling) by adding debounce logic if needed in `<script>` section in index.html
- [x] T044 [US4] Ensure textarea is not cleared after submission (allow easy editing) in handleSubmit function in index.html

**Checkpoint**: Multiple submission workflow complete and independently testable (FR-010)

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and edge cases

- [x] T045 [P] Add global CSS reset and base styles (box-sizing, font-family, colors) in `<style>` section in index.html
- [x] T046 [P] Add CSS variables for colors, spacing, and breakpoints in `:root` in `<style>` section in index.html
- [x] T047 [P] Enhance visual design with modern UI styling (shadows, gradients, typography) in `<style>` section in index.html
- [x] T048 Add accessibility attributes (aria-live for error messages, aria-describedby for textarea) in index.html
- [x] T049 Add additional mock examples from contracts/mock-data.json to mockAnalyses object in index.html
- [x] T050 Test edge case: extremely long text (10,000+ characters) and add UI feedback if needed in index.html
- [x] T051 Test edge case: special characters and multi-line input, verify display correctness in index.html
- [x] T052 Test edge case: rapid button clicking, ensure no duplicate submissions in index.html
- [x] T053 Test responsive layout on mobile (< 768px) and tablet (>= 768px) breakpoints
- [x] T054 Add code comments for workshop clarity in `<script>` section in index.html
- [x] T055 Validate against all acceptance scenarios from spec.md
- [x] T056 Run through quickstart.md validation checklist
- [x] T057 Final code cleanup and formatting for workshop presentation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
  - US2 (Enter Task): Can start after Foundational
  - US3 (Submit Button): Can start after US2 (needs form structure)
  - US1 (View Analysis): Can start after US3 (needs submit handler)
  - US4 (Multiple Tasks): Can start after US1 (enhances existing flow)
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 2 (P1) - Enter Task**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 3 (P1) - Submit Button**: Depends on US2 (needs form and textarea to exist)
- **User Story 1 (P1) - View Analysis**: Depends on US3 (needs submit event to trigger display)
- **User Story 4 (P2) - Multiple Tasks**: Depends on US1 (enhances the results display workflow)

**Note**: Logical implementation order differs from story priority due to UI flow: Input → Submit → Display → Repeat

### Within Each User Story

- HTML structure before CSS styling
- CSS styling before JavaScript behavior
- Core functionality before edge cases
- Story complete before moving to next

### Parallel Opportunities

- **Phase 1**: All setup tasks can run sequentially (small project)
- **Phase 2**: Tasks T005-T009 must be sequential (same file)
- **Within User Stories**: 
  - T028 and T029 [P] - different parts of HTML structure
  - T045, T046, T047 [P] - different CSS concerns
- **Cross-Story**: Limited parallelization since all code is in one file

---

## Parallel Example: User Story 1

```bash
# Due to single-file structure, most tasks are sequential
# However, these HTML structure tasks can be conceptually parallel:
Task T028: "Create left panel structure"
Task T029: "Create right panel structure"

# Polish phase CSS tasks can be parallel:
Task T045: "Add global CSS reset"
Task T046: "Add CSS variables"
Task T047: "Enhance visual design"
```

---

## Implementation Strategy

### MVP First (User Stories 2 + 3 + 1)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T009) - CRITICAL
3. Complete Phase 3: User Story 2 - Enter Task (T010-T017)
4. Complete Phase 4: User Story 3 - Submit Button (T018-T026)
5. Complete Phase 5: User Story 1 - View Analysis (T027-T039)
6. **STOP and VALIDATE**: Test complete workflow end-to-end
7. **MVP READY**: Can enter, submit, and view analysis

### Incremental Delivery

1. **Foundation** (Phases 1-2) → Project runs, shows basic page
2. **Input Workflow** (Phases 3-4) → Can enter and submit tasks (validation works)
3. **Full MVP** (Phase 5) → Complete side-by-side analysis display ✅
4. **Enhanced** (Phase 6) → Multiple submissions supported
5. **Workshop-Ready** (Phase 7) → Polished, tested, documented

### Sequential Workshop Demo Strategy

Since all code is in one file, development is naturally sequential:

1. Developer completes Setup + Foundational
2. Developer implements stories in logical UI flow order:
   - First: Input (US2) - users need to enter text
   - Second: Submit (US3) - users need to trigger analysis
   - Third: Display (US1) - users need to see results
   - Fourth: Repeat (US4) - users want to try multiple tasks
3. Each story adds visible value in workshop demo
4. Polish phase makes code workshop-presentation-ready

---

## Acceptance Testing Checklist

### Test Scenario 1: Required Example (US1, US2, US3)
- [ ] Open page at http://localhost:5173/
- [ ] Enter text: "Fix the bug in the login form"
- [ ] Click "Analyze Task" button
- [ ] ✅ Left panel shows exact text: "Fix the bug in the login form"
- [ ] ✅ Right panel shows: Priority: HIGH, Categories: CRITICAL-PATH, USER-FACING, SECURITY, Complexity: MEDIUM
- [ ] ✅ Suggested order text is visible and correct

### Test Scenario 2: Empty Input Validation (US3)
- [ ] Leave textarea empty
- [ ] Click submit button
- [ ] ✅ Error message appears: "Please enter a task description"
- [ ] ✅ No results displayed
- [ ] Type any text in textarea
- [ ] ✅ Error message disappears

### Test Scenario 3: Multiple Submissions (US4)
- [ ] Enter "Fix the bug in the login form"
- [ ] Click submit, verify results appear
- [ ] Change textarea to "Update README documentation"
- [ ] Click submit again
- [ ] ✅ Results update to show new task
- [ ] ✅ Previous results are completely replaced
- [ ] ✅ No duplicate panels or stale data

### Test Scenario 4: Responsive Layout (SC-003)
- [ ] Open browser DevTools (F12)
- [ ] Toggle device toolbar, select mobile view (375px)
- [ ] ✅ Panels stack vertically (one on top of other)
- [ ] Switch to tablet view (768px)
- [ ] ✅ Panels display side-by-side
- [ ] Switch to desktop view (1024px+)
- [ ] ✅ Panels remain side-by-side with good spacing

### Test Scenario 5: Edge Cases
- [ ] Enter 10,000 characters in textarea (copy-paste long text)
- [ ] ✅ Textarea accepts input, submission works
- [ ] Enter multi-line text with special characters (!@#$%^&*)
- [ ] ✅ Text displays exactly as entered with line breaks preserved
- [ ] Rapidly click submit button 5 times quickly
- [ ] ✅ No errors, results display correctly

### Test Scenario 6: Additional Mock Examples
- [ ] Try each additional example from contracts/mock-data.json
- [ ] ✅ Each returns appropriate priority/categories/complexity
- [ ] Try unrecognized task text
- [ ] ✅ Returns default MEDIUM priority analysis

---

## Notes

- [P] tasks = can conceptually run in parallel (though single-file structure limits actual parallelization)
- [Story] label maps task to specific user story for traceability
- Each user story delivers visible, testable functionality
- Single HTML file means most tasks are sequential edits
- Commit after each phase or user story completion
- Stop at any checkpoint to validate story independently
- All file paths point to `/Users/maryia.yermakovich/Projects/task-prio-ai-workshop/index.html` or config files
- Workshop-friendly: code is clean, commented, and easy to demonstrate

---

## Task Summary

**Total Tasks**: 57 tasks across 7 phases

### Tasks by Phase:
- **Phase 1 (Setup)**: 4 tasks
- **Phase 2 (Foundational)**: 5 tasks (BLOCKING)
- **Phase 3 (US2 - Enter Task)**: 8 tasks
- **Phase 4 (US3 - Submit)**: 9 tasks
- **Phase 5 (US1 - View Analysis)**: 13 tasks ⭐ Core MVP
- **Phase 6 (US4 - Multiple Tasks)**: 5 tasks
- **Phase 7 (Polish)**: 13 tasks

### Tasks by User Story:
- **US1 (View Analysis)**: 13 tasks - Core display functionality
- **US2 (Enter Task)**: 8 tasks - Input component
- **US3 (Submit Button)**: 9 tasks - Validation and submission
- **US4 (Multiple Tasks)**: 5 tasks - Enhanced workflow
- **Infrastructure**: 22 tasks (Setup + Foundational + Polish)

### Parallel Opportunities:
- Limited due to single-file structure
- 2 HTML structure tasks can be conceptually parallel (T028, T029)
- 3 Polish CSS tasks can be parallel (T045, T046, T047)
- **Best parallelization**: Different developers review/test different user stories after implementation

### MVP Scope (Minimum Viable Product):
**Phases 1-5 (31 tasks)** = Complete working demo with:
- ✅ Vite dev server running
- ✅ Input textarea for task descriptions
- ✅ Submit button with validation
- ✅ Side-by-side display of input and analysis
- ✅ Required example working correctly
- ✅ Responsive layout (mobile + desktop)

**Suggested First Demo**: Stop after Phase 5 (T039) to validate core functionality before adding enhancements.

---

**Format Validation**: ✅ All 57 tasks follow the required format:
- Checkbox: `- [ ]` ✅
- Task ID: Sequential T001-T057 ✅
- [P] marker: Only on parallelizable tasks ✅
- [Story] label: US1, US2, US3, US4 on user story tasks ✅
- File paths: All tasks include exact file paths ✅

