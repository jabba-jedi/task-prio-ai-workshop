# Implementation Plan: Supabase Database Logging

**Branch**: `003-supabase-logging` | **Date**: October 17, 2025 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/003-supabase-logging/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Add transparent database logging to the Task Prioritizer that persists task submissions after successful Gemini AI analysis. When users receive their AI-generated priority, categories, complexity, and suggested order, the application will asynchronously write this data (along with the original task text and timestamp) to a Supabase PostgreSQL database. The logging is fire-and-forget to avoid blocking the UI, and failures display a subtle warning without disrupting the user experience. Database credentials are configured via environment variables (VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY), and the feature gracefully degrades when credentials are missing or the database is unavailable.

## Technical Context

**Language/Version**: JavaScript (ES6+) with HTML5 and CSS3 (existing vanilla JS codebase)  
**Primary Dependencies**: Vite (existing), @google/generative-ai (existing from Feature 002), @supabase/supabase-js (new, latest version ~2.x)  
**Storage**: Supabase PostgreSQL database with table `task_submissions` (schema defined in contracts)  
**Testing**: Manual browser testing with Supabase dashboard verification; Playwright tests in future phase  
**Target Platform**: Modern web browsers (Chrome, Firefox, Safari, Edge) with fetch API support  
**Project Type**: Single-page web application (existing structure maintained)  
**Performance Goals**: Database writes must not block UI; fire-and-forget pattern with <100ms initiation time; user sees analysis immediately  
**Constraints**: Frontend-only database calls (workshop demo context); single HTML file architecture preserved; no backend proxy; database credentials in environment variables only; no loading states for database operations  
**Scale/Scope**: Single-user application; ~10-20 database inserts per demo session; Supabase free tier limits (50,000 rows, 500MB storage, 2GB bandwidth typical)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Status**: ✅ **PASS - No Constitution Defined**

Since this project is a workshop demo without an established constitution, we continue with industry best practices:
- ✅ **Simplicity**: Minimal change to existing code - add async database insert after successful Gemini response
- ✅ **Workshop Context**: Frontend database calls acceptable for demo purposes (documented as non-production pattern)
- ✅ **Fault Tolerance**: Database failures never break core functionality (AI analysis still works)
- ✅ **Security**: Database credentials stored in environment variables, not committed to source code
- ✅ **Fire-and-Forget Pattern**: Non-blocking async writes ensure zero UI impact
- ✅ **Scope Control**: No feature creep - only adding logging, not displaying history or analytics

**Note**: The frontend database access pattern is justified for this workshop demo context. Production applications should use a backend API to handle database operations with proper authentication, authorization, rate limiting, and connection pooling. Supabase Row Level Security (RLS) policies should be configured for production use.

### Post-Design Re-evaluation (After Phase 1)

**Status**: ✅ **PASS - Design Maintains Best Practices**

After completing Phase 1 design (data model, contracts, quickstart):

- ✅ **Simplicity Maintained**: Design adds ~80-120 lines of code to existing index.html; single async function handles database logging with fire-and-forget pattern
- ✅ **Clear Contracts**: 
  - Database schema with 7 columns, 2 indexes, CHECK constraints documented in database-schema.json
  - Insert operation contract with request/response examples in supabase-insert.json
  - 4 comprehensive examples covering success and error scenarios
- ✅ **Comprehensive Error Handling**: 
  - 6 error types mapped to user-friendly warnings (network, auth, validation, RLS, generic)
  - Graceful degradation - logging failure never blocks AI analysis
  - Console logging for debugging, subtle UI warning for users
- ✅ **Security Documented**: 
  - Quickstart emphasizes anon key limitations and workshop context
  - RLS policies clearly marked as demo-permissive
  - Production upgrade path documented (backend API proxy)
  - Environment variable security practices explained
- ✅ **Testability**: 
  - 11-item verification checklist in quickstart
  - 6 SQL query examples for database verification
  - Manual testing scenarios for happy path + 5 error cases
  - Edge case testing with special characters, long text, empty arrays
- ✅ **Workshop-Ready**: 
  - 7-step setup guide with time estimates (total 15-20 minutes)
  - Troubleshooting section covers 6 common issues
  - Screenshots guidance for Supabase dashboard
  - Security best practices clearly distinguished (workshop vs production)

**Design Validation**:
- Data model defines 3 clear entities with 7 validation rules per entity
- Contracts include 5 error scenario examples with detection methods
- Fire-and-forget pattern ensures zero UI blocking (async without await)
- Single table design keeps complexity minimal
- All functional requirements (FR-001 through FR-020) have implementation guidance

**No constitution violations introduced during design phase.**

## Project Structure

### Documentation (this feature)

```
specs/003-supabase-logging/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── database-schema.json         # Table structure (already created in spec phase)
│   ├── task-submission-example.json # Example record (already created in spec phase)
│   ├── supabase-insert.json         # Insert operation contract
│   └── README.md                    # Contract documentation (already created in spec phase)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
# Single-page web application structure (unchanged)
/
├── index.html               # Main application file (will add Supabase integration)
├── vite.config.js          # Build configuration (unchanged)
├── package.json            # Dependencies (will add @supabase/supabase-js)
├── .env                    # Local environment variables (add VITE_SUPABASE_* vars)
├── .env.example            # Documentation (will add Supabase credential examples)
└── dist/                   # Build output (unchanged)

# No new source files - integration within existing index.html
```

**Structure Decision**: Maintain the existing single-file application architecture. The Supabase integration will be added as a new async function within the existing `<script type="module">` section of index.html, called after successful Gemini API responses. This preserves the workshop-friendly simplicity while adding the logging capability.

**Integration Point**: The logging function will be invoked in the existing Gemini success handler:
```javascript
// Existing: After Gemini returns analysis
const analysis = await analyzeTaskWithGemini(taskText);
displayResults(taskText, analysis);

// New: Fire-and-forget logging (no await)
logTaskSubmission(taskText, analysis).catch(error => {
  showWarning('Task history could not be saved at this time');
});
```

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

**Status**: ✅ **No Violations - Table Empty**

No constitutional violations to track. The design follows workshop demo best practices with appropriate security warnings and production upgrade documentation.

