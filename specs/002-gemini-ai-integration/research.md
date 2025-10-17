# Research & Technical Decisions: Gemini AI Integration

**Feature**: Gemini AI Integration for Task Prioritization  
**Branch**: `002-gemini-ai-integration`  
**Date**: October 17, 2025  
**Status**: Phase 0 Complete

## Overview

This document captures all technical research and decisions made during Phase 0 planning for integrating Google's Gemini AI into the existing Task Prioritizer application. The goal is to replace hardcoded mock data with real-time AI analysis while maintaining the workshop-friendly single-file architecture.

## Technology Stack Decisions

### 1. AI Provider: Google Gemini 1.5 Flash

**Decision**: Use Google's Gemini 1.5 Flash model via the @google/generative-ai npm package

**Rationale**:
- **User requirement**: Explicit specification to use Gemini API
- **Speed optimized**: Flash model provides responses in 1-3 seconds (vs 3-5s for Pro)
- **Cost effective**: Free tier includes 15 requests/minute, 1500 requests/day (sufficient for workshop)
- **JSON mode**: Supports structured output for reliable parsing
- **Official SDK**: @google/generative-ai provides type-safe JavaScript API
- **Modern**: Latest model family with strong reasoning capabilities
- **Workshop-appropriate**: Easy to demonstrate and explain

**Alternatives Considered**:
- **Gemini 1.5 Pro**: More capable but slower (3-5s latency), unnecessary for simple prioritization
- **OpenAI GPT-4**: Requires different API, more expensive, no significant advantage for this use case
- **Claude**: Different provider, similar capabilities but changing from spec requirement
- **Local models (Ollama)**: Workshop complexity (requires installation), slower, inconsistent quality
- **Azure OpenAI**: Enterprise-focused, unnecessary complexity for demo

**Model Comparison**:
| Model | Latency | Free Tier | JSON Mode | Best For |
| ----- | ------- | --------- | --------- | -------- |
| Gemini 1.5 Flash | 1-3s | 15 RPM | ✅ Yes | Speed, demos, simple tasks |
| Gemini 1.5 Pro | 3-5s | 2 RPM | ✅ Yes | Complex reasoning, longer context |
| GPT-4o | 2-4s | No free tier | ✅ Yes | General purpose, multimodal |

---

### 2. SDK: @google/generative-ai (Official Google Package)

**Decision**: Use the official @google/generative-ai npm package (latest version 0.21.0+)

**Rationale**:
- **User requirement**: Explicit specification to use this package
- **Official support**: Maintained by Google, guaranteed compatibility
- **Type safety**: TypeScript definitions included for better DX
- **Simple API**: Clean async/await interface
- **Streaming support**: Can add streaming later if needed
- **Active development**: Regular updates and bug fixes
- **Good documentation**: Extensive examples and API reference
- **Small bundle**: ~50KB minified, acceptable for frontend use

**Alternatives Considered**:
- **Direct REST API**: More HTTP boilerplate, manual error handling, no type safety
- **Langchain**: Overkill abstraction layer, larger bundle size, unnecessary for single provider
- **OpenAI SDK**: Wrong provider (requirement specifies Gemini)
- **Custom wrapper**: Reinventing the wheel, maintenance burden

**Installation**:
```bash
npm install @google/generative-ai
```

**Basic Usage Pattern**:
```javascript
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(apiKey);
const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

const result = await model.generateContent(prompt);
const response = result.response.text();
```

---

### 3. Environment Configuration: Vite Environment Variables

**Decision**: Use Vite's built-in environment variable system with VITE_ prefix

**Rationale**:
- **User requirement**: Explicit specification for VITE_GEMINI_API_KEY
- **Native support**: Vite automatically loads .env files
- **Security**: Variables prefixed with VITE_ are exposed to client code (documented pattern)
- **No build configuration**: Works out-of-box with existing Vite setup
- **Standard practice**: Follows Vite conventions for frontend environment variables
- **Development workflow**: .env for local dev, platform variables for production

**Alternatives Considered**:
- **process.env**: Node.js pattern, requires build configuration in Vite
- **window.env**: Custom global object, non-standard, harder to manage
- **Config file**: Requires importing, could accidentally commit secrets
- **Hardcoded**: Absolutely not - security risk

**Implementation**:
```javascript
// Access in code
const apiKey = import.meta.env.VITE_GEMINI_API_KEY;

// .env file (not committed)
VITE_GEMINI_API_KEY=your_actual_key_here

// .env.example file (committed as documentation)
VITE_GEMINI_API_KEY=your_gemini_api_key_here
```

**Security Note**: Frontend environment variables are visible in browser. For production, use backend proxy. Acceptable for workshop demo with personal API keys on free tier.

---

### 4. JSON Mode: Structured Output with Clear Instructions

**Decision**: Use Gemini's JSON mode via response MIME type and explicit prompt instructions

**Rationale**:
- **Reliability**: JSON mode enforces valid JSON output (no parsing errors)
- **User requirement**: Spec requires "structured JSON for reliable parsing"
- **Type safety**: Predictable schema makes validation straightforward
- **Error reduction**: Eliminates "thinking text" or narrative responses mixed with JSON
- **Workshop-friendly**: Clean, predictable output format

**Alternatives Considered**:
- **Text response with JSON extraction**: Regex parsing, error-prone, unreliable
- **Streaming with accumulation**: More complex, unnecessary for short responses
- **XML format**: Less common in JavaScript, harder to parse
- **Plain text parsing**: Requires natural language parsing, too complex

**Prompt Structure**:
```javascript
const prompt = `Analyze this work task and return ONLY a JSON object with these exact fields:

{
  "priority": "HIGH" | "MEDIUM" | "LOW",
  "categories": ["ARRAY", "OF", "TAGS"],
  "complexity": "HIGH" | "MEDIUM" | "LOW",
  "suggestion": "one sentence explaining priority"
}

Task: ${taskDescription}

Return ONLY the JSON object, no other text.`;
```

**Response Configuration**:
```javascript
const result = await model.generateContent({
  contents: [{ role: 'user', parts: [{ text: prompt }] }],
  generationConfig: {
    responseMimeType: 'application/json'
  }
});
```

---

### 5. Error Handling: User-Friendly Messages by Error Type

**Decision**: Implement comprehensive error handling with specific messages for each failure scenario

**Rationale**:
- **User requirement**: FR-012 through FR-017 require specific error handling
- **User experience**: Clear messages help users understand what went wrong
- **Workshop value**: Demonstrates proper error handling patterns
- **Debugging**: Different messages help identify issues during development
- **Graceful degradation**: App remains usable after errors

**Error Categories & Messages**:

| Error Type | Detection Method | User Message |
| ---------- | ---------------- | ------------ |
| Missing API Key | `!import.meta.env.VITE_GEMINI_API_KEY` | "Gemini API key not configured. Please add VITE_GEMINI_API_KEY to your .env file." |
| Network Error | `catch` on fetch / API call | "Unable to connect to Gemini AI. Please check your internet connection and try again." |
| Authentication Error | API response status 401/403 | "API authentication failed. Please check your Gemini API key." |
| Rate Limit | API response status 429 | "AI service rate limit reached. Please wait a moment before trying again." |
| Parse Error | `JSON.parse()` throws | "Received invalid response from AI. Please try again." |
| Missing Fields | Validation after parse | "AI response incomplete. Please try again." |
| Generic Error | Catch-all fallback | "AI service temporarily unavailable. Please try again shortly." |

**Implementation Pattern**:
```javascript
async function analyzeTaskWithGemini(taskDescription) {
  try {
    const apiKey = import.meta.env.VITE_GEMINI_API_KEY;
    
    if (!apiKey) {
      throw new Error('API_KEY_MISSING');
    }
    
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    
    const result = await model.generateContent(prompt);
    const response = JSON.parse(result.response.text());
    
    // Validate response has all required fields
    if (!response.priority || !response.categories || !response.complexity || !response.suggestion) {
      throw new Error('INCOMPLETE_RESPONSE');
    }
    
    return response;
    
  } catch (error) {
    // Map errors to user-friendly messages
    if (error.message === 'API_KEY_MISSING') {
      return { error: 'Gemini API key not configured. Please add VITE_GEMINI_API_KEY to your .env file.' };
    }
    // ... other error types
  }
}
```

---

### 6. Loading States: Immediate Visual Feedback

**Decision**: Implement loading state with disabled button and "Analyzing..." message

**Rationale**:
- **User requirement**: FR-018 requires immediate feedback
- **User experience**: 1-3 second API calls need visible feedback
- **Prevent duplicate submissions**: Disabled button during API call
- **Workshop demonstration**: Shows async UI patterns
- **Accessibility**: Screen reader announcements via aria-live

**Implementation**:
```javascript
// Show loading state
submitButton.disabled = true;
submitButton.textContent = 'Analyzing...';
errorMessage.classList.add('hidden');

try {
  const analysis = await analyzeTaskWithGemini(taskText);
  displayResults(taskText, analysis);
} catch (error) {
  showError(error.message);
} finally {
  // Reset button state
  submitButton.disabled = false;
  submitButton.textContent = 'Analyze Task';
}
```

**Visual Indicators**:
- Button text changes to "Analyzing..."
- Button becomes disabled (prevents clicks)
- Optional: Add spinner icon or loading animation
- Clear error message area before API call

---

### 7. Response Validation: Schema Checking

**Decision**: Validate API response structure before displaying results

**Rationale**:
- **Robustness**: AI models can occasionally return unexpected formats
- **User experience**: Prevent displaying broken or incomplete data
- **Workshop value**: Demonstrates defensive programming
- **Spec requirement**: FR-011 requires validation of required fields

**Validation Checklist**:
```javascript
function validateGeminiResponse(response) {
  // Check response is an object
  if (!response || typeof response !== 'object') {
    return { valid: false, error: 'Invalid response format' };
  }
  
  // Check priority field
  if (!['HIGH', 'MEDIUM', 'LOW'].includes(response.priority)) {
    return { valid: false, error: 'Invalid priority value' };
  }
  
  // Check categories is array
  if (!Array.isArray(response.categories) || response.categories.length === 0) {
    return { valid: false, error: 'Invalid categories format' };
  }
  
  // Check complexity field
  if (!['HIGH', 'MEDIUM', 'LOW'].includes(response.complexity)) {
    return { valid: false, error: 'Invalid complexity value' };
  }
  
  // Check suggestion field
  if (typeof response.suggestion !== 'string' || response.suggestion.trim().length === 0) {
    return { valid: false, error: 'Missing suggestion text' };
  }
  
  return { valid: true };
}
```

---

### 8. API Key Security: Best Practices for Demo Context

**Decision**: Document API key security limitations and best practices for workshop

**Rationale**:
- **Transparency**: Clear documentation about security trade-offs
- **Education**: Workshop teaches both the pattern and its limitations
- **Risk mitigation**: Personal API keys on free tier have limited exposure
- **Production guidance**: Document upgrade path to backend proxy

**Security Measures**:
✅ **DO**:
- Store API key in .env file (never commit)
- Add .env to .gitignore
- Provide .env.example for documentation
- Use personal API keys (not shared/corporate)
- Rotate keys after workshop if shared publicly
- Document that keys are visible in browser

❌ **DON'T**:
- Commit .env file to Git
- Hardcode API keys in source code
- Share API keys in screenshots/recordings
- Use production/paid API keys for demos
- Expose keys in console.log statements

**Production Upgrade Path**:
```
Workshop Pattern:      Production Pattern:
Frontend → Gemini      Frontend → Backend API → Gemini
                      (API key secured server-side)
```

---

### 9. Backward Compatibility: Progressive Enhancement

**Decision**: Keep mock data function as fallback during development

**Rationale**:
- **Development workflow**: Work on UI without API calls
- **Testing**: Verify UI changes without API quota usage
- **Resilience**: Graceful degradation if API unavailable
- **Workshop flexibility**: Can demo with or without API key

**Implementation Strategy**:
```javascript
// Keep original mock data function
function analyzeMockTask(taskDescription) {
  // ... original hardcoded logic
}

// New Gemini API function
async function analyzeTaskWithGemini(taskDescription) {
  // ... API integration
}

// Smart dispatcher (optional for workshop)
async function analyzeTask(taskDescription) {
  const apiKey = import.meta.env.VITE_GEMINI_API_KEY;
  
  if (apiKey) {
    return await analyzeTaskWithGemini(taskDescription);
  } else {
    console.warn('No API key found, using mock data');
    return analyzeMockTask(taskDescription);
  }
}
```

---

### 10. Module Import Strategy: Vite ES Modules

**Decision**: Use standard ES module imports with Vite's built-in bundling

**Rationale**:
- **Vite support**: Native ES modules in development, bundled for production
- **Modern JavaScript**: Standard import syntax
- **Code organization**: Separate concerns even in single file
- **Workshop-friendly**: Clear dependency declaration

**Implementation**:
```html
<script type="module">
  import { GoogleGenerativeAI } from '@google/generative-ai';
  
  // Rest of application code...
</script>
```

**Note**: Vite automatically handles:
- Development: ES modules loaded via browser
- Production: Bundled and optimized by Vite build
- Tree shaking: Unused code removed
- Code splitting: Automatic chunks for performance

---

## Prompt Engineering

### Prompt Design for Reliable JSON Output

**Decision**: Use explicit, constraint-focused prompt with examples

**Final Prompt Template**:
```javascript
const prompt = `You are a technical task prioritization assistant. Analyze the following work task and determine its priority, categories, complexity, and suggested order.

Return ONLY a valid JSON object with these exact fields (no additional text):

{
  "priority": "HIGH" | "MEDIUM" | "LOW",
  "categories": ["CATEGORY1", "CATEGORY2", ...],
  "complexity": "HIGH" | "MEDIUM" | "LOW",
  "suggestion": "One sentence explaining why this priority makes sense"
}

Priority levels:
- HIGH: Blocks other work, security issues, critical bugs, user-facing failures
- MEDIUM: Important but not blocking, feature work, refactoring with clear value
- LOW: Nice-to-have, documentation, minor improvements

Common categories:
CRITICAL-PATH, USER-FACING, SECURITY, BUG-FIX, FEATURE, TECHNICAL-DEBT, DOCUMENTATION, TESTING, INFRASTRUCTURE, PERFORMANCE, ACCESSIBILITY

Complexity levels:
- HIGH: Multi-day effort, requires extensive testing, touches many systems
- MEDIUM: 1-2 day effort, moderate scope, some dependencies
- LOW: Hours of work, isolated change, minimal risk

Task to analyze:
${taskDescription}

Return ONLY the JSON object:`;
```

**Rationale**:
- **Clear constraints**: Explicit enum values prevent invalid responses
- **Context provided**: Definitions help AI make consistent decisions
- **Examples given**: Category list guides categorization
- **Repetition**: "ONLY JSON" repeated twice for emphasis
- **Structured format**: Easy for AI to follow

---

## API Rate Limits and Quotas

### Gemini Free Tier Limits

**Understanding Rate Limits**:
- **Requests per minute (RPM)**: 15 requests/minute for Flash model
- **Requests per day (RPD)**: 1,500 requests/day for Flash model
- **Tokens per minute**: 1 million tokens/minute (not a concern for short tasks)

**Workshop Context**:
- ~10-20 submissions per demo session
- Well within free tier limits
- No rate limit handling needed for basic workshop
- Could add rate limit detection for complete error handling

**Future Enhancement** (Out of Scope):
- Client-side rate limit tracking
- Queue system for multiple requests
- Exponential backoff for retries
- Upgrade prompt to paid tier ($0.35/$1.05 per million tokens)

---

## Research Summary

### Questions Resolved

1. **Which Gemini model to use?**
   - ✅ Gemini 1.5 Flash - optimized for speed and demo use

2. **How to ensure reliable JSON parsing?**
   - ✅ JSON mode via responseMimeType + explicit prompt instructions

3. **How to secure API key?**
   - ✅ Vite environment variables (VITE_GEMINI_API_KEY), .env.example for docs

4. **What error scenarios to handle?**
   - ✅ 7 error types with specific user-friendly messages

5. **How to provide loading feedback?**
   - ✅ Disable button + "Analyzing..." text during API call

6. **How to validate API responses?**
   - ✅ Schema validation checking all required fields and value types

7. **How to maintain single-file architecture?**
   - ✅ ES module imports in `<script type="module">` tag

8. **What npm package version to use?**
   - ✅ Latest @google/generative-ai (0.21.0+) via npm install

### No Clarifications Needed

All technical decisions have been made based on:
- ✅ Explicit user requirements (Gemini API, @google/generative-ai package, JSON mode, environment variables)
- ✅ Feature specification (error handling, loading states, response validation)
- ✅ Workshop context (frontend API calls, single-file architecture, demo-friendly)
- ✅ Industry best practices (error handling, security, user experience)
- ✅ Google Gemini API documentation and best practices

---

## Next Steps

Proceed to **Phase 1: Design & Contracts**:
1. Generate `data-model.md` with API request/response structures
2. Create `contracts/gemini-request.json` with API request format
3. Create `contracts/gemini-response.json` with expected response schema
4. Create `contracts/README.md` documenting API integration
5. Generate `quickstart.md` with setup instructions (including API key setup)
6. Update agent context with @google/generative-ai + Gemini API stack

