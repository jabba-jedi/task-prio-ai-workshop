# Data Model: Supabase Database Logging

**Feature**: Supabase Database Logging  
**Branch**: `003-supabase-logging`  
**Date**: October 17, 2025  
**Status**: Phase 1 Complete

## Overview

This document defines the data entities, relationships, and validation rules for the Supabase database logging feature. The data model consists of a single table (`task_submissions`) that persists task analysis results, with strong typing, constraints, and indexes to ensure data integrity and query performance.

## Entity Definitions

### 1. Task Submission Record

**Description**: A single database record representing one task submission with its AI-generated analysis.

**Purpose**: Persist task history for analytics, pattern analysis, and verification of system behavior.

**Storage**: PostgreSQL table `task_submissions` in Supabase

**Fields**:

| Field Name | Data Type | Constraints | Description |
| ---------- | --------- | ----------- | ----------- |
| `id` | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | Auto-generated unique identifier |
| `task_text` | TEXT | NOT NULL | Original task description exactly as entered by user |
| `priority` | TEXT | NOT NULL, CHECK IN ('HIGH', 'MEDIUM', 'LOW') | AI-determined priority level |
| `categories` | TEXT[] | NOT NULL | Array of classification tags from AI analysis |
| `complexity` | TEXT | NOT NULL, CHECK IN ('HIGH', 'MEDIUM', 'LOW') | AI-assessed effort/complexity level |
| `suggested_order` | TEXT | NOT NULL | AI-generated explanation of prioritization reasoning |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | Server timestamp when record was inserted |

**Validation Rules**:

1. **ID Validation**:
   - Format: Valid UUID v4
   - Generation: Automatic via database default
   - Uniqueness: Enforced by PRIMARY KEY constraint

2. **Task Text Validation**:
   - Required: NOT NULL constraint
   - Format: Any text content
   - Length: Unlimited (PostgreSQL TEXT type)
   - Special chars: All allowed (preserved exactly)
   - Whitespace: Preserved including newlines and tabs

3. **Priority Validation**:
   - Required: NOT NULL constraint
   - Allowed values: Exactly one of ['HIGH', 'MEDIUM', 'LOW']
   - Case sensitive: Must be uppercase
   - Enforcement: Database CHECK constraint
   - Client validation: Pre-insert check before database call

4. **Categories Validation**:
   - Required: NOT NULL constraint (array can be empty but not null)
   - Type: PostgreSQL TEXT[] (array of text strings)
   - Order: Preserved in database
   - Duplicates: Allowed (AI may return duplicates)
   - Special chars: Allowed in individual tags
   - Empty array: Valid (some tasks may have no categories)

5. **Complexity Validation**:
   - Required: NOT NULL constraint
   - Allowed values: Exactly one of ['HIGH', 'MEDIUM', 'LOW']
   - Case sensitive: Must be uppercase
   - Enforcement: Database CHECK constraint
   - Client validation: Pre-insert check before database call

6. **Suggested Order Validation**:
   - Required: NOT NULL constraint
   - Format: Free-form text (typically one sentence)
   - Length: Unlimited (PostgreSQL TEXT type)
   - Special chars: All allowed
   - Empty string: Not allowed (must have content)

7. **Created At Validation**:
   - Required: NOT NULL constraint
   - Generation: Automatic via database DEFAULT NOW()
   - Type: PostgreSQL TIMESTAMPTZ (timestamp with timezone)
   - Format: ISO 8601 with timezone (e.g., "2025-10-17T14:23:45.678Z")
   - Client override: Not allowed (server time is authoritative)

**Indexes**:

| Index Name | Columns | Purpose |
| ---------- | ------- | ------- |
| `idx_task_submissions_created_at` | created_at | Time-based queries and chronological sorting |
| `idx_task_submissions_priority` | priority | Filtering by priority level for analytics |

**Relationships**: None (single standalone table)

---

### 2. Database Configuration

**Description**: Environment variables that configure the Supabase connection.

**Purpose**: Secure credential storage for database authentication and project identification.

**Storage**: Environment variables (`.env` file locally, platform variables in deployment)

**Fields**:

| Variable Name | Data Type | Required | Description |
| ------------- | --------- | -------- | ----------- |
| `VITE_SUPABASE_URL` | String (URL) | Yes | Supabase project URL (e.g., https://xxx.supabase.co) |
| `VITE_SUPABASE_ANON_KEY` | String (JWT) | Yes | Anonymous public API key for client-side access |

**Validation Rules**:

1. **Supabase URL Validation**:
   - Format: Valid HTTPS URL
   - Pattern: `https://*.supabase.co` (or custom domain)
   - Required: Application checks at runtime
   - Failure mode: Silent disable (console warning, no UI error)

2. **Anon Key Validation**:
   - Format: Base64-encoded JWT token
   - Pattern: Starts with `eyJ`
   - Length: ~250-400 characters (typical JWT length)
   - Required: Application checks at runtime
   - Failure mode: Silent disable (console warning, no UI error)

**Security Considerations**:
- Both values are intentionally exposed to browser (client-side)
- Row Level Security (RLS) policies protect data access
- Anon key is public but RLS limits what it can do
- Never commit `.env` file to version control
- Rotate keys if exposed publicly

---

### 3. Logging Warning State

**Description**: UI state that indicates database logging failure without disrupting workflow.

**Purpose**: Inform users of logging issues while keeping the application functional.

**Storage**: Transient DOM element (not persisted)

**Fields**:

| Field Name | Data Type | Description |
| ---------- | --------- | ----------- |
| `message` | String | User-friendly warning text |
| `visible` | Boolean | Whether warning is currently displayed |
| `autoHideDelay` | Number | Milliseconds before auto-dismissal (5000ms) |

**States**:

| State | Condition | Display |
| ----- | --------- | ------- |
| Hidden | Default state, no errors | Not rendered in DOM |
| Visible | Database operation failed | Yellow warning banner below results |
| Auto-hiding | After 5 seconds | Fade out animation, remove from DOM |

**Validation Rules**: None (display-only component)

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ User Input                                                  │
│ ─────────────────────────────────────────────────────────  │
│ task_text: "Fix database connection timeout"               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Gemini AI Analysis (Feature 002)                           │
│ ─────────────────────────────────────────────────────────  │
│ priority: "HIGH"                                            │
│ categories: ["BUG-FIX", "INFRASTRUCTURE", "CRITICAL-PATH"] │
│ complexity: "MEDIUM"                                        │
│ suggestion: "Fix immediately - blocking production"        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Display to User (Immediate - No Wait)                      │
│ ─────────────────────────────────────────────────────────  │
│ [LEFT] Original task text                                  │
│ [RIGHT] AI analysis with all fields                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Client-Side Validation (Pre-Insert)                        │
│ ─────────────────────────────────────────────────────────  │
│ ✓ task_text is non-empty string                            │
│ ✓ priority is HIGH/MEDIUM/LOW                              │
│ ✓ categories is array                                      │
│ ✓ complexity is HIGH/MEDIUM/LOW                            │
│ ✓ suggestion is non-empty string                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Supabase Insert (Fire-and-Forget)                          │
│ ─────────────────────────────────────────────────────────  │
│ INSERT INTO task_submissions                                │
│   (task_text, priority, categories, complexity,            │
│    suggested_order)                                         │
│ VALUES                                                      │
│   ('Fix database...', 'HIGH', '{BUG-FIX,...}',            │
│    'MEDIUM', 'Fix immediately...')                         │
│                                                             │
│ [id and created_at auto-generated]                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                    Success / Failure
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Error Handling (Non-Blocking)                              │
│ ─────────────────────────────────────────────────────────  │
│ [SUCCESS] Console log, no UI change                        │
│ [FAILURE] Console warn + show warning banner               │
│           "Task history could not be saved at this time"   │
└─────────────────────────────────────────────────────────────┘
```

---

## Database Schema SQL

**Table Creation**:
```sql
-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create task_submissions table
CREATE TABLE task_submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_text TEXT NOT NULL,
  priority TEXT NOT NULL CHECK (priority IN ('HIGH', 'MEDIUM', 'LOW')),
  categories TEXT[] NOT NULL,
  complexity TEXT NOT NULL CHECK (complexity IN ('HIGH', 'MEDIUM', 'LOW')),
  suggested_order TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for query performance
CREATE INDEX idx_task_submissions_created_at 
  ON task_submissions(created_at);

CREATE INDEX idx_task_submissions_priority 
  ON task_submissions(priority);

-- Add comments for documentation
COMMENT ON TABLE task_submissions IS 
  'Stores task analysis submissions with AI-generated prioritization insights';

COMMENT ON COLUMN task_submissions.task_text IS 
  'Original task description exactly as entered by user';

COMMENT ON COLUMN task_submissions.priority IS 
  'AI-determined priority: HIGH, MEDIUM, or LOW';

COMMENT ON COLUMN task_submissions.categories IS 
  'Array of classification tags (e.g., CRITICAL-PATH, USER-FACING, SECURITY)';

COMMENT ON COLUMN task_submissions.complexity IS 
  'AI-assessed effort level: HIGH, MEDIUM, or LOW';

COMMENT ON COLUMN task_submissions.suggested_order IS 
  'AI-generated explanation of when/why to prioritize this task';

COMMENT ON COLUMN task_submissions.created_at IS 
  'Server timestamp when submission was logged';
```

**Row Level Security**:
```sql
-- Enable RLS on table
ALTER TABLE task_submissions ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous inserts (workshop demo)
CREATE POLICY "Allow anonymous inserts"
  ON task_submissions
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy: Block anonymous reads (optional privacy protection)
CREATE POLICY "Block anonymous reads"
  ON task_submissions
  FOR SELECT
  TO anon
  USING (false);

-- Note: Authenticated users would need separate policies
```

---

## Data Mapping

### Gemini Response → Database Record

| Gemini Field | Type | Maps To | Transformation |
| ------------ | ---- | ------- | -------------- |
| `priority` | string | `priority` | Direct copy (already uppercase) |
| `categories` | string[] | `categories` | Direct copy (PostgreSQL array) |
| `complexity` | string | `complexity` | Direct copy (already uppercase) |
| `suggestion` | string | `suggested_order` | Direct copy (field name change) |
| N/A | N/A | `task_text` | From user input (not Gemini response) |
| N/A | UUID | `id` | Auto-generated by database |
| N/A | timestamptz | `created_at` | Auto-generated by database |

**JavaScript Mapping Example**:
```javascript
// Gemini response + user input
const taskText = "Fix database connection timeout";
const analysis = {
  priority: "HIGH",
  categories: ["BUG-FIX", "INFRASTRUCTURE", "CRITICAL-PATH"],
  complexity: "MEDIUM",
  suggestion: "Fix immediately - blocking production"
};

// Database insert payload
const insertPayload = {
  task_text: taskText,                  // From user input
  priority: analysis.priority,           // Direct from Gemini
  categories: analysis.categories,       // Direct from Gemini
  complexity: analysis.complexity,       // Direct from Gemini
  suggested_order: analysis.suggestion   // Field name change
  // id and created_at omitted (auto-generated)
};

// Supabase insert
const { data, error } = await supabase
  .from('task_submissions')
  .insert([insertPayload]);
```

---

## State Transitions

### Record Lifecycle

```
┌────────────────┐
│   Not Exists   │  Initial state (before submission)
└───────┬────────┘
        │
        │ [User submits task]
        │
        ▼
┌────────────────┐
│   Validated    │  Client-side validation passed
└───────┬────────┘
        │
        │ [Insert initiated]
        │
        ▼
┌────────────────┐
│   Inserting    │  HTTP request in flight
└────┬───────┬───┘
     │       │
     │       └──────────────┐
     │                      │
     │ [Success]            │ [Failure]
     ▼                      ▼
┌────────────────┐    ┌────────────────┐
│    Persisted   │    │  Insert Failed │
│                │    │  (No record)   │
└────────────────┘    └────────────────┘
     │                      │
     │                      │
     └──────────┬───────────┘
                │
                ▼
          [UI continues]
        [No user impact]
```

**State Descriptions**:

1. **Not Exists**: Record doesn't exist in database (default state)
2. **Validated**: Client-side checks passed, ready for insert
3. **Inserting**: Async HTTP request to Supabase in progress
4. **Persisted**: Record successfully saved in database (terminal state)
5. **Insert Failed**: Database operation failed, no record created (terminal state)

**Key Points**:
- User sees analysis BEFORE state transitions begin
- Insert failure doesn't affect UI state (fire-and-forget)
- No "pending" or "loading" states visible to user
- Both terminal states allow application to continue

---

## Query Patterns

### Common Queries

**1. Recent Submissions**:
```sql
SELECT * 
FROM task_submissions 
ORDER BY created_at DESC 
LIMIT 20;
```

**2. Filter by Priority**:
```sql
SELECT task_text, priority, created_at
FROM task_submissions
WHERE priority = 'HIGH'
ORDER BY created_at DESC;
```

**3. Find by Category**:
```sql
SELECT task_text, categories, priority
FROM task_submissions
WHERE 'SECURITY' = ANY(categories);
```

**4. Count by Priority**:
```sql
SELECT priority, COUNT(*) as count
FROM task_submissions
GROUP BY priority
ORDER BY count DESC;
```

**5. Recent High Priority**:
```sql
SELECT task_text, suggested_order, created_at
FROM task_submissions
WHERE priority = 'HIGH'
  AND created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

**6. Category Frequency**:
```sql
SELECT unnest(categories) as category, COUNT(*) as frequency
FROM task_submissions
GROUP BY category
ORDER BY frequency DESC;
```

---

## Validation Summary

### Client-Side Validation (JavaScript)

```javascript
function validateTaskSubmission(taskText, analysis) {
  const errors = [];
  
  // Task text validation
  if (!taskText || typeof taskText !== 'string') {
    errors.push('Task text must be a non-empty string');
  }
  if (taskText.trim().length === 0) {
    errors.push('Task text cannot be blank');
  }
  
  // Priority validation
  if (!['HIGH', 'MEDIUM', 'LOW'].includes(analysis.priority)) {
    errors.push(`Invalid priority: ${analysis.priority}`);
  }
  
  // Categories validation
  if (!Array.isArray(analysis.categories)) {
    errors.push('Categories must be an array');
  }
  
  // Complexity validation
  if (!['HIGH', 'MEDIUM', 'LOW'].includes(analysis.complexity)) {
    errors.push(`Invalid complexity: ${analysis.complexity}`);
  }
  
  // Suggestion validation
  if (!analysis.suggestion || typeof analysis.suggestion !== 'string') {
    errors.push('Suggestion must be a non-empty string');
  }
  if (analysis.suggestion.trim().length === 0) {
    errors.push('Suggestion cannot be blank');
  }
  
  if (errors.length > 0) {
    throw new Error(`Validation failed: ${errors.join(', ')}`);
  }
  
  return true;
}
```

### Server-Side Validation (PostgreSQL Constraints)

```sql
-- Enforced by database schema:
-- ✓ NOT NULL constraints on all fields
-- ✓ CHECK constraints on priority and complexity enums
-- ✓ TEXT[] type enforcement for categories array
-- ✓ TIMESTAMPTZ type enforcement for created_at
-- ✓ UUID type enforcement for id
-- ✓ PRIMARY KEY uniqueness on id
```

---

## Data Examples

### Example 1: Bug Fix Task

**Input**:
```
task_text: "Fix login page crash when invalid email entered"
```

**Gemini Analysis**:
```json
{
  "priority": "HIGH",
  "categories": ["BUG-FIX", "USER-FACING", "CRITICAL-PATH"],
  "complexity": "MEDIUM",
  "suggestion": "Address immediately - blocks user authentication"
}
```

**Database Record**:
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "task_text": "Fix login page crash when invalid email entered",
  "priority": "HIGH",
  "categories": ["BUG-FIX", "USER-FACING", "CRITICAL-PATH"],
  "complexity": "MEDIUM",
  "suggested_order": "Address immediately - blocks user authentication",
  "created_at": "2025-10-17T14:23:45.678Z"
}
```

### Example 2: Documentation Task

**Input**:
```
task_text: "Update API documentation for new endpoints"
```

**Gemini Analysis**:
```json
{
  "priority": "LOW",
  "categories": ["DOCUMENTATION"],
  "complexity": "LOW",
  "suggestion": "Nice to have - improves developer experience but not blocking"
}
```

**Database Record**:
```json
{
  "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
  "task_text": "Update API documentation for new endpoints",
  "priority": "LOW",
  "categories": ["DOCUMENTATION"],
  "complexity": "LOW",
  "suggested_order": "Nice to have - improves developer experience but not blocking",
  "created_at": "2025-10-17T14:24:12.345Z"
}
```

---

## Summary

**Entities**: 3 (Task Submission Record, Database Configuration, Logging Warning State)  
**Tables**: 1 (task_submissions)  
**Relationships**: None (single standalone table)  
**Indexes**: 2 (created_at, priority)  
**Constraints**: 6 (NOT NULL, CHECK, PRIMARY KEY, DEFAULT)  
**Validation Layers**: 2 (Client-side JavaScript, Server-side PostgreSQL)

**Data Integrity Features**:
- ✅ Strong typing with PostgreSQL native types
- ✅ Enum validation via CHECK constraints
- ✅ Array type for categories preserves order
- ✅ Server-side timestamp generation (authoritative time)
- ✅ UUID primary key prevents collisions
- ✅ Indexes optimize common query patterns
- ✅ Row Level Security controls access
- ✅ Client validation catches issues before insert


