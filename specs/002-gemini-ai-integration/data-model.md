# Data Model: Gemini AI Integration

**Feature**: Gemini AI Integration for Task Prioritization  
**Branch**: `002-gemini-ai-integration`  
**Date**: October 17, 2025  
**Status**: Phase 1 Complete

## Overview

This document defines the data structures used in the Gemini AI integration. Since this is a frontend-only implementation with no database, the data model focuses on API request/response structures and runtime application state.

---

## Core Entities

### 1. TaskInput

Represents the user's raw task description submitted for analysis.

**Purpose**: Capture and validate user input before sending to Gemini API

**Fields**:
- `text` (string, required): The task description entered by the user
  - Constraints: 1-10,000 characters after trimming
  - Validation: Non-empty, trimmed of leading/trailing whitespace

**State Transitions**:
```
EMPTY → VALID (user types text) → SUBMITTED (user clicks button)
EMPTY → INVALID (user submits empty) → ERROR_DISPLAYED
SUBMITTED → LOADING (API call initiated)
```

**Usage Context**:
- Created from `textarea.value` on form submission
- Validated before API call
- Included in API request payload
- Displayed in left panel of results

**Example**:
```javascript
const taskInput = {
  text: "Fix the bug in the login form"
};
```

---

### 2. GeminiAPIRequest

Represents the complete request sent to Gemini API.

**Purpose**: Structure the API call with proper prompt formatting and configuration

**Fields**:
- `contents` (array, required): Message array for Gemini API
  - `role` (string): Always "user" for single-turn requests
  - `parts` (array): Array of content parts
    - `text` (string): The constructed prompt including task description
- `generationConfig` (object, optional): Response format configuration
  - `responseMimeType` (string): Set to "application/json" for JSON mode
  - `temperature` (number, 0-1): Creativity level (default: 0.3 for consistency)
  - `maxOutputTokens` (number): Maximum response length (default: 1024)

**Construction Logic**:
```javascript
const request = {
  contents: [{
    role: 'user',
    parts: [{
      text: constructPrompt(taskInput.text)
    }]
  }],
  generationConfig: {
    responseMimeType: 'application/json',
    temperature: 0.3,
    maxOutputTokens: 1024
  }
};
```

**API Endpoint**: Handled internally by @google/generative-ai SDK
- Model: `gemini-1.5-flash`
- Method: `model.generateContent(request)`

---

### 3. TaskAnalysis

Represents the structured AI analysis returned by Gemini API.

**Purpose**: Store validated analysis results for display in the UI

**Fields**:
- `priority` (string, required): Task urgency level
  - Values: "HIGH" | "MEDIUM" | "LOW"
  - Validation: Must be one of the three enum values
  
- `categories` (array of strings, required): Classification tags
  - Examples: "CRITICAL-PATH", "USER-FACING", "SECURITY", "BUG-FIX", "FEATURE"
  - Constraints: Non-empty array, each tag is uppercase with hyphens
  - Validation: Array with at least one string element
  
- `complexity` (string, required): Estimated effort level
  - Values: "HIGH" | "MEDIUM" | "LOW"
  - Validation: Must be one of the three enum values
  
- `suggestion` (string, required): Priority reasoning
  - Constraints: Non-empty string, typically one sentence
  - Validation: Trimmed length > 0

**Validation Rules**:
```javascript
function validateTaskAnalysis(analysis) {
  const validPriorities = ['HIGH', 'MEDIUM', 'LOW'];
  const validComplexities = ['HIGH', 'MEDIUM', 'LOW'];
  
  return (
    analysis !== null &&
    typeof analysis === 'object' &&
    validPriorities.includes(analysis.priority) &&
    Array.isArray(analysis.categories) &&
    analysis.categories.length > 0 &&
    validComplexities.includes(analysis.complexity) &&
    typeof analysis.suggestion === 'string' &&
    analysis.suggestion.trim().length > 0
  );
}
```

**State Transitions**:
```
API_RESPONSE → PARSED (JSON.parse) → VALIDATED (schema check) → DISPLAYED
API_RESPONSE → PARSE_ERROR (invalid JSON)
PARSED → VALIDATION_ERROR (missing/invalid fields)
```

**Example**:
```javascript
const taskAnalysis = {
  priority: "HIGH",
  categories: ["CRITICAL-PATH", "USER-FACING", "SECURITY"],
  complexity: "MEDIUM",
  suggestion: "Do this before feature work - blocks user access"
};
```

---

### 4. APIError

Represents error states when API calls fail.

**Purpose**: Provide user-friendly error messages based on failure type

**Fields**:
- `type` (string, required): Error category for internal handling
  - Values: "API_KEY_MISSING" | "NETWORK_ERROR" | "AUTH_ERROR" | "RATE_LIMIT" | "PARSE_ERROR" | "VALIDATION_ERROR" | "UNKNOWN_ERROR"
  
- `message` (string, required): User-facing error description
  - Constraints: Clear, actionable, non-technical language
  
- `originalError` (Error object, optional): Original exception for debugging
  - Only used in development console, never shown to user

**Error Type Mappings**:
```javascript
const ERROR_MESSAGES = {
  API_KEY_MISSING: "Gemini API key not configured. Please add VITE_GEMINI_API_KEY to your .env file.",
  NETWORK_ERROR: "Unable to connect to Gemini AI. Please check your internet connection and try again.",
  AUTH_ERROR: "API authentication failed. Please check your Gemini API key.",
  RATE_LIMIT: "AI service rate limit reached. Please wait a moment before trying again.",
  PARSE_ERROR: "Received invalid response from AI. Please try again.",
  VALIDATION_ERROR: "AI response incomplete. Please try again.",
  UNKNOWN_ERROR: "AI service temporarily unavailable. Please try again shortly."
};
```

**Detection Logic**:
```javascript
function classifyError(error) {
  if (!import.meta.env.VITE_GEMINI_API_KEY) {
    return { type: 'API_KEY_MISSING', message: ERROR_MESSAGES.API_KEY_MISSING };
  }
  
  if (error.status === 401 || error.status === 403) {
    return { type: 'AUTH_ERROR', message: ERROR_MESSAGES.AUTH_ERROR };
  }
  
  if (error.status === 429) {
    return { type: 'RATE_LIMIT', message: ERROR_MESSAGES.RATE_LIMIT };
  }
  
  if (error.message?.includes('fetch') || error.message?.includes('network')) {
    return { type: 'NETWORK_ERROR', message: ERROR_MESSAGES.NETWORK_ERROR };
  }
  
  if (error instanceof SyntaxError) {
    return { type: 'PARSE_ERROR', message: ERROR_MESSAGES.PARSE_ERROR };
  }
  
  return { type: 'UNKNOWN_ERROR', message: ERROR_MESSAGES.UNKNOWN_ERROR, originalError: error };
}
```

**Example**:
```javascript
const apiError = {
  type: "RATE_LIMIT",
  message: "AI service rate limit reached. Please wait a moment before trying again.",
  originalError: new Error("429 Too Many Requests")
};
```

---

### 5. UIState

Represents the current state of the application interface.

**Purpose**: Manage loading, error, and result display states

**Fields**:
- `isLoading` (boolean, required): Whether API call is in progress
  - Controls submit button disabled state
  - Controls loading message visibility
  
- `hasError` (boolean, required): Whether an error is displayed
  - Controls error message visibility
  
- `currentError` (string | null): Current error message to display
  - Null when hasError is false
  
- `hasResults` (boolean, required): Whether analysis results are displayed
  - Controls results container visibility
  
- `currentTask` (string | null): Original task text being displayed
  - Used to populate left panel
  
- `currentAnalysis` (TaskAnalysis | null): Analysis results being displayed
  - Used to populate right panel

**State Machine**:
```
IDLE → LOADING (submit clicked)
LOADING → RESULTS (API success)
LOADING → ERROR (API failure)
RESULTS → LOADING (new submit)
ERROR → LOADING (retry submit)
```

**Initial State**:
```javascript
const initialUIState = {
  isLoading: false,
  hasError: false,
  currentError: null,
  hasResults: false,
  currentTask: null,
  currentAnalysis: null
};
```

**State Updates**:
```javascript
// Start loading
uiState = {
  isLoading: true,
  hasError: false,
  currentError: null,
  hasResults: false,
  currentTask: null,
  currentAnalysis: null
};

// Show results
uiState = {
  isLoading: false,
  hasError: false,
  currentError: null,
  hasResults: true,
  currentTask: taskInput.text,
  currentAnalysis: validatedAnalysis
};

// Show error
uiState = {
  isLoading: false,
  hasError: true,
  currentError: apiError.message,
  hasResults: false,
  currentTask: null,
  currentAnalysis: null
};
```

---

## Data Flow Diagram

```
┌─────────────────┐
│  User Types     │
│  Task in        │
│  Textarea       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  TaskInput      │
│  {text: "..."}  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────────┐
│  Validation     │─NO──▶│  Show Error      │
│  (non-empty?)   │      │  UIState.hasError│
└────────┬────────┘      └──────────────────┘
         │YES
         ▼
┌─────────────────┐
│  Set Loading    │
│  UIState.       │
│  isLoading=true │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Construct      │
│  Gemini API     │
│  Request        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Call Gemini    │◀────── API Key from
│  API via SDK    │        import.meta.env.VITE_GEMINI_API_KEY
└────┬───────┬────┘
     │       │
  SUCCESS  FAILURE
     │       │
     │       ▼
     │  ┌────────────────┐
     │  │  APIError      │
     │  │  Classify &    │
     │  │  Map to Message│
     │  └───────┬────────┘
     │          │
     │          ▼
     │  ┌────────────────┐
     │  │  Show Error    │
     │  │  UIState.      │
     │  │  currentError  │
     │  └────────────────┘
     │
     ▼
┌─────────────────┐
│  Parse JSON     │
│  Response       │
└────┬───────┬────┘
     │       │
   VALID  INVALID
     │       │
     │       ▼
     │  ┌────────────────┐
     │  │  Parse Error   │
     │  │  Show Error    │
     │  └────────────────┘
     │
     ▼
┌─────────────────┐
│  Validate       │
│  Schema         │
└────┬───────┬────┘
     │       │
   PASS    FAIL
     │       │
     │       ▼
     │  ┌────────────────┐
     │  │  Validation Err│
     │  │  Show Error    │
     │  └────────────────┘
     │
     ▼
┌─────────────────┐
│  TaskAnalysis   │
│  {priority,     │
│   categories,   │
│   complexity,   │
│   suggestion}   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Update UI      │
│  UIState.       │
│  hasResults=true│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Display        │
│  Results in     │
│  Side-by-Side   │
│  Panels         │
└─────────────────┘
```

---

## Relationships Between Entities

### TaskInput → GeminiAPIRequest
- **Relationship**: TaskInput.text is embedded into GeminiAPIRequest prompt
- **Transformation**: Text is inserted into structured prompt template
- **Cardinality**: 1:1 (one task input creates one API request)

### GeminiAPIRequest → TaskAnalysis
- **Relationship**: API request produces TaskAnalysis response
- **Transformation**: JSON parsing and schema validation
- **Cardinality**: 1:1 on success, 1:0 on failure

### GeminiAPIRequest → APIError
- **Relationship**: Failed API request produces APIError
- **Transformation**: Exception classification and message mapping
- **Cardinality**: 1:0 on success, 1:1 on failure

### TaskAnalysis + TaskInput → UIState
- **Relationship**: Both combined to display results
- **Transformation**: Stored in UIState for rendering
- **Cardinality**: Many:1 (multiple submissions update same UIState)

### APIError → UIState
- **Relationship**: Error messages displayed in UI
- **Transformation**: Error.message → UIState.currentError
- **Cardinality**: 1:1 (one error sets UI error state)

---

## Validation Summary

### Input Validation (Pre-API)
✅ TaskInput.text must be non-empty after trimming  
✅ TaskInput.text must be ≤ 10,000 characters  
✅ API key must exist in environment variables

### Response Validation (Post-API)
✅ Response must be valid JSON  
✅ priority field must be "HIGH", "MEDIUM", or "LOW"  
✅ categories field must be non-empty array of strings  
✅ complexity field must be "HIGH", "MEDIUM", or "LOW"  
✅ suggestion field must be non-empty string

### Error Validation
✅ All API errors must map to user-friendly messages  
✅ No technical error details shown to users  
✅ Error messages must be actionable

---

## Type Definitions (TypeScript-style for Documentation)

```typescript
// Core types
type Priority = 'HIGH' | 'MEDIUM' | 'LOW';
type Complexity = 'HIGH' | 'MEDIUM' | 'LOW';
type Category = string; // Uppercase with hyphens

// Input type
interface TaskInput {
  text: string; // 1-10,000 chars after trim
}

// API Request type
interface GeminiAPIRequest {
  contents: Array<{
    role: 'user';
    parts: Array<{ text: string }>;
  }>;
  generationConfig?: {
    responseMimeType?: 'application/json';
    temperature?: number;
    maxOutputTokens?: number;
  };
}

// Analysis response type
interface TaskAnalysis {
  priority: Priority;
  categories: Category[]; // Non-empty array
  complexity: Complexity;
  suggestion: string; // Non-empty string
}

// Error type
interface APIError {
  type: 'API_KEY_MISSING' | 'NETWORK_ERROR' | 'AUTH_ERROR' | 'RATE_LIMIT' | 'PARSE_ERROR' | 'VALIDATION_ERROR' | 'UNKNOWN_ERROR';
  message: string;
  originalError?: Error;
}

// UI State type
interface UIState {
  isLoading: boolean;
  hasError: boolean;
  currentError: string | null;
  hasResults: boolean;
  currentTask: string | null;
  currentAnalysis: TaskAnalysis | null;
}
```

---

## Summary

This data model defines five core entities for the Gemini AI integration:

1. **TaskInput** - User's raw task description
2. **GeminiAPIRequest** - Structured API call payload
3. **TaskAnalysis** - Validated AI analysis results
4. **APIError** - User-friendly error states
5. **UIState** - Application interface state

All entities include validation rules, state transitions, and clear relationships. The data flow progresses linearly from user input through API call to either results or error display, with comprehensive validation at each stage.

