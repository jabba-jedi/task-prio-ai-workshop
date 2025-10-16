# Data Model: Task Prioritizer Application

**Feature**: Task Prioritizer Application  
**Branch**: `001-task-prioritizer`  
**Date**: October 16, 2025  
**Status**: Phase 1 Design

## Overview

This document defines the data structures used in the Task Prioritizer application. Since this is a client-side only application with no backend or persistence, the data model focuses on in-memory JavaScript objects used for the UI state and mock data responses.

## Entity Definitions

### 1. TaskDescription

**Purpose**: Represents the user's input task text

**Structure**:
```javascript
{
  text: String  // The raw task description entered by user
}
```

**Fields**:

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `text` | String | Yes | Non-empty after trim() | The task description exactly as entered by the user, including whitespace and line breaks |

**Constraints**:
- **FR-003**: Must preserve exact user input including whitespace, line breaks, special characters
- **FR-009**: Must not be empty (validation enforced before creating TaskDescription)
- **Maximum length**: 10,000 characters (FR-002)

**Example**:
```javascript
{
  text: "Fix the bug in the login form"
}
```

**State Transitions**: None (immutable once created)

---

### 2. TaskAnalysis

**Purpose**: Represents the AI-generated prioritization analysis for a task

**Structure**:
```javascript
{
  priority: "HIGH" | "MEDIUM" | "LOW",
  categories: String[],
  complexity: "HIGH" | "MEDIUM" | "LOW",
  suggestedOrder: String
}
```

**Fields**:

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `priority` | Enum String | Yes | Must be "HIGH", "MEDIUM", or "LOW" | The urgency/importance level of the task |
| `categories` | Array of Strings | Yes | Non-empty array | Classification tags for the task (e.g., "CRITICAL-PATH", "USER-FACING") |
| `complexity` | Enum String | Yes | Must be "HIGH", "MEDIUM", or "LOW" | The estimated effort required to complete the task |
| `suggestedOrder` | String | Yes | Non-empty string | Human-readable explanation of when/why to do this task |

**Constraints**:
- **FR-011**: Priority must be one of three values: HIGH, MEDIUM, LOW
- **FR-012**: Categories must be an array of descriptive tags
- **FR-013**: Complexity must be one of three values: HIGH, MEDIUM, LOW
- **FR-014**: SuggestedOrder must be clear and actionable text

**Example**:
```javascript
{
  priority: "HIGH",
  categories: ["CRITICAL-PATH", "USER-FACING", "SECURITY"],
  complexity: "MEDIUM",
  suggestedOrder: "Do this before feature work - blocks user access"
}
```

**State Transitions**: None (immutable once created from mock data)

---

### 3. TaskSubmission

**Purpose**: Combines user input with analysis results for display

**Structure**:
```javascript
{
  task: TaskDescription,
  analysis: TaskAnalysis
}
```

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `task` | TaskDescription | Yes | The original user input |
| `analysis` | TaskAnalysis | Yes | The generated prioritization analysis |

**Purpose**: This structure represents the complete data needed for the side-by-side display (left panel = task, right panel = analysis)

**Example**:
```javascript
{
  task: {
    text: "Fix the bug in the login form"
  },
  analysis: {
    priority: "HIGH",
    categories: ["CRITICAL-PATH", "USER-FACING", "SECURITY"],
    complexity: "MEDIUM",
    suggestedOrder: "Do this before feature work - blocks user access"
  }
}
```

**State Transitions**:
- Created when user submits form
- Replaces previous TaskSubmission when user submits again (FR-010)
- Triggers UI update to display results

---

## Relationships

```
TaskSubmission
├── task: TaskDescription (1:1)
└── analysis: TaskAnalysis (1:1)
```

**Notes**:
- Simple composition - each TaskSubmission contains exactly one TaskDescription and one TaskAnalysis
- No relationships between multiple submissions (no history stored)
- New submission replaces the previous one in the UI

---

## Data Flow

```
User Input → TaskDescription → Mock Analysis Lookup → TaskAnalysis → TaskSubmission → UI Display
```

**Step-by-step**:

1. **User enters text** in textarea
2. **User clicks submit** button
3. **Validation**: Check if text is non-empty (trim)
4. **Create TaskDescription**: `{ text: userInput }`
5. **Lookup mock data**: Match text against mock data object
6. **Create TaskAnalysis**: Return matching analysis or default
7. **Create TaskSubmission**: Combine task + analysis
8. **Update UI**: Display left panel (task) and right panel (analysis)

---

## Mock Data Storage

**Implementation**: JavaScript object with exact task text as key

```javascript
const mockAnalyses = {
  "Fix the bug in the login form": {
    priority: "HIGH",
    categories: ["CRITICAL-PATH", "USER-FACING", "SECURITY"],
    complexity: "MEDIUM",
    suggestedOrder: "Do this before feature work - blocks user access"
  }
  // Additional examples can be added here
};
```

**Lookup Logic**:
```javascript
function analyzeTask(taskDescription) {
  const normalizedText = taskDescription.text.trim();
  
  // Exact match lookup
  if (mockAnalyses[normalizedText]) {
    return mockAnalyses[normalizedText];
  }
  
  // Default fallback for unmatched tasks
  return {
    priority: "MEDIUM",
    categories: ["GENERAL"],
    complexity: "MEDIUM",
    suggestedOrder: "Review and prioritize based on current sprint goals"
  };
}
```

**Rationale**:
- Simple key-value lookup (O(1) performance)
- Easy to add more examples by extending the object
- Fallback ensures all submissions get a response

---

## UI State Management

**Current State**: Single variable storing the active TaskSubmission

```javascript
let currentSubmission = null;  // TaskSubmission or null
```

**State Updates**:
- `null` → TaskSubmission: First submission, show results area
- TaskSubmission → TaskSubmission: Replace with new submission (FR-010)
- No history or state persistence required

**UI Visibility**:
- Results area hidden when `currentSubmission === null`
- Results area visible when `currentSubmission !== null`

---

## Validation Rules

### TaskDescription Validation

```javascript
function validateTaskInput(text) {
  const trimmed = text.trim();
  
  if (trimmed.length === 0) {
    return {
      valid: false,
      error: "Please enter a task description"
    };
  }
  
  if (trimmed.length > 10000) {
    return {
      valid: false,
      error: "Task description too long (max 10,000 characters)"
    };
  }
  
  return { valid: true };
}
```

### TaskAnalysis Validation

```javascript
function validateTaskAnalysis(analysis) {
  const validPriorities = ["HIGH", "MEDIUM", "LOW"];
  const validComplexities = ["HIGH", "MEDIUM", "LOW"];
  
  if (!validPriorities.includes(analysis.priority)) {
    throw new Error(`Invalid priority: ${analysis.priority}`);
  }
  
  if (!Array.isArray(analysis.categories) || analysis.categories.length === 0) {
    throw new Error("Categories must be a non-empty array");
  }
  
  if (!validComplexities.includes(analysis.complexity)) {
    throw new Error(`Invalid complexity: ${analysis.complexity}`);
  }
  
  if (!analysis.suggestedOrder || analysis.suggestedOrder.trim().length === 0) {
    throw new Error("Suggested order must be a non-empty string");
  }
  
  return true;
}
```

**Note**: Analysis validation is defensive programming for mock data - ensures data contract is met.

---

## Category Tag Reference

**Common Categories** (examples for future mock data):

| Category | Meaning | Usage |
|----------|---------|-------|
| `CRITICAL-PATH` | Blocks other work | High-priority tasks that must be done first |
| `USER-FACING` | Directly visible to users | Features, UI fixes, UX improvements |
| `SECURITY` | Security implications | Authentication, authorization, data protection |
| `TECHNICAL-DEBT` | Code quality issues | Refactoring, optimization, cleanup |
| `FEATURE` | New functionality | New capabilities or enhancements |
| `BUG-FIX` | Fixes broken functionality | Bug resolution, error handling |
| `DOCUMENTATION` | Documentation tasks | README, API docs, comments |
| `TESTING` | Test-related work | Writing tests, test infrastructure |
| `INFRASTRUCTURE` | DevOps/deployment | CI/CD, deployment, monitoring |
| `GENERAL` | Uncategorized | Default fallback category |

**Notes**:
- Multiple categories can be assigned to a single task
- Categories help users understand the nature of the task
- Future versions could support category filtering

---

## Future Extensibility

While the current implementation uses hardcoded mock data, the data model is designed to support future enhancements:

### Potential Additions

1. **Task History**:
   ```javascript
   let submissionHistory = [];  // Array of TaskSubmission
   ```

2. **Timestamp**:
   ```javascript
   {
     task: TaskDescription,
     analysis: TaskAnalysis,
     submittedAt: Date
   }
   ```

3. **Unique ID**:
   ```javascript
   {
     id: String,  // UUID or timestamp
     task: TaskDescription,
     analysis: TaskAnalysis
   }
   ```

4. **Confidence Score**:
   ```javascript
   analysis: {
     // ... existing fields
     confidence: Number  // 0.0 to 1.0
   }
   ```

5. **Real AI Integration**:
   - Replace mock lookup with API call
   - Add loading state to data model
   - Handle API errors

**Note**: These extensions are NOT part of the current MVP scope. The simple data model above is sufficient for the workshop demo.

---

## Summary

The Task Prioritizer data model consists of three simple structures:

1. **TaskDescription**: User input text
2. **TaskAnalysis**: AI-generated analysis (priority, categories, complexity, suggested order)
3. **TaskSubmission**: Combines both for UI display

All data is in-memory with no persistence. Mock data is stored in a JavaScript object for hardcoded examples. The model is intentionally minimal for workshop clarity while remaining extensible for future enhancements.

