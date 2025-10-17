# Implementation Plan: Gemini AI Integration for Task Prioritization

**Branch**: `002-gemini-ai-integration` | **Date**: October 17, 2025 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/002-gemini-ai-integration/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Replace the hardcoded mock data lookup in the Task Prioritizer with real-time Gemini AI API integration. When users submit tasks, the application will call Google's Gemini 1.5 Flash model to generate contextual analysis with Priority, Categories, Complexity, and Suggested Order. The API key will be configured via environment variables (VITE_GEMINI_API_KEY), and comprehensive error handling will provide user-friendly feedback for network, authentication, rate limit, and parsing failures. Implementation uses the @google/generative-ai npm package with structured JSON prompts for reliable parsing.

## Technical Context

**Language/Version**: JavaScript (ES6+) with HTML5 and CSS3 (existing vanilla JS codebase)  
**Primary Dependencies**: Vite (existing), @google/generative-ai (new, latest version ~0.21.0+)  
**Storage**: N/A (no persistence, frontend-only API calls)  
**Testing**: Manual browser testing during workshop (Playwright tests in future phase)  
**Target Platform**: Modern web browsers (Chrome, Firefox, Safari, Edge) with fetch API support  
**Project Type**: Single-page web application (existing structure maintained)  
**Performance Goals**: API responses within 5 seconds under normal network conditions; sub-100ms UI feedback for loading states  
**Constraints**: Frontend-only API calls (workshop demo context); single HTML file architecture preserved; no backend proxy; API key in environment variables only  
**Scale/Scope**: Single-user application; ~10-20 API calls per demo session; Gemini free tier rate limits (15 RPM / 1500 RPD typical)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Status**: ✅ **PASS - No Constitution Defined**

Since this project is a workshop demo without an established constitution, we continue with industry best practices:
- ✅ **Simplicity**: Minimal change to existing code - replace mock data function with async API call
- ✅ **Workshop Context**: Frontend API calls acceptable for demo purposes (documented as non-production pattern)
- ✅ **Error Handling**: Comprehensive user-facing error messages without technical jargon
- ✅ **Security**: API key stored in environment variables, not committed to source code
- ✅ **Maintainability**: Clear separation between API integration logic and existing UI code
- ✅ **Scope Control**: No feature creep - only replacing data source, keeping existing UI/UX

**Note**: The frontend API call pattern is justified for this workshop demo context. Production applications should use a backend proxy to secure API keys and implement rate limiting, caching, and request validation.

### Post-Design Re-evaluation (After Phase 1)

**Status**: ✅ **PASS - Design Maintains Best Practices**

After completing Phase 1 design (data model, contracts, quickstart):

- ✅ **Simplicity Maintained**: Design adds ~100-150 lines of code to existing index.html; single async function replaces mock data lookup
- ✅ **Clear Contracts**: API request/response structures documented in JSON schemas with validation rules
- ✅ **Comprehensive Error Handling**: Seven error types mapped to user-friendly messages with clear detection logic
- ✅ **Security Documented**: Quickstart guide emphasizes API key security, .env usage, and production upgrade path
- ✅ **Testability**: Manual testing checklist provided; comprehensive edge cases documented
- ✅ **Workshop-Ready**: Quickstart guide enables setup in ~10 minutes; clear troubleshooting section

**Design Validation**:
- Data model defines 5 clear entities with validation rules
- Contracts include 2 complete examples per document
- Error classification logic handles 7 distinct failure scenarios
- Loading state management prevents duplicate submissions
- Response validation ensures data integrity before display

**No constitution violations introduced during design phase.**

## Project Structure

### Documentation (this feature)

```
specs/002-gemini-ai-integration/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── gemini-request.json      # API request structure
│   ├── gemini-response.json     # Expected API response format
│   └── README.md                # Contract documentation
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
task-prio-ai-workshop/
├── index.html           # Modified: Replace mock data with Gemini API integration
├── .env.example         # New: Document required VITE_GEMINI_API_KEY variable
├── package.json         # Modified: Add @google/generative-ai dependency
├── vite.config.js       # Unchanged: Existing Vite configuration works as-is
└── specs/               # Feature specifications (already exists)
    ├── 001-task-prioritizer/
    └── 002-gemini-ai-integration/
```

**Structure Decision**: Maintaining the single HTML file architecture from Feature 001 with minimal changes. The only additions are:
1. New npm dependency (@google/generative-ai)
2. New .env.example file for API key documentation
3. Modified JavaScript within index.html to replace `analyzeTask()` function

**Rationale**:
- **Minimal disruption**: Preserves workshop-friendly single-file structure
- **Clear upgrade path**: Shows progression from mock data to real AI
- **Environment-based config**: Follows Vite convention for environment variables
- **Demo continuity**: Maintains all existing UI behavior and visual design

**Changes Required**:
- Add import statement for @google/generative-ai (via Vite's module system)
- Replace synchronous mock data lookup with async API call
- Add loading state management (disable button, show indicator)
- Add error state management (display user-friendly messages)
- Update form submit handler to handle Promise/async flow

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

**N/A** - No constitution violations. Project maintains simplicity-first approach. Frontend API integration is acknowledged as workshop-specific pattern and clearly documented as non-production practice.
