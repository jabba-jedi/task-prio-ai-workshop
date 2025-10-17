# API Contracts: Gemini AI Integration

**Feature**: Gemini AI Integration for Task Prioritization  
**Branch**: `002-gemini-ai-integration`  
**Date**: October 17, 2025

## Overview

This directory contains the API contracts for integrating Google's Gemini 1.5 Flash model into the Task Prioritizer application. These contracts define the structure of requests sent to Gemini and responses expected back, ensuring reliable communication and validation.

---

## Contract Files

### 1. gemini-request.json

**Purpose**: Defines the structure of API requests sent to Gemini 1.5 Flash

**Key Elements**:
- `contents[]`: Message array with user prompts
- `generationConfig`: Optional response formatting configuration
  - `responseMimeType: "application/json"` - Ensures JSON output
  - `temperature: 0.3` - Consistent but not robotic responses
  - `maxOutputTokens: 1024` - Sufficient for task analysis

**Usage**: Guides the construction of API requests in the application code

### 2. gemini-response.json

**Purpose**: Defines the expected structure of AI analysis responses

**Required Fields**:
- `priority`: "HIGH" | "MEDIUM" | "LOW"
- `categories`: Array of uppercase classification tags
- `complexity`: "HIGH" | "MEDIUM" | "LOW"
- `suggestion`: One sentence explanation

**Usage**: Used for response validation before displaying results to users

---

## API Integration Flow

```
┌─────────────────────────────────────────────────────────────┐
│  1. User submits task description                           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Application constructs Gemini API request               │
│     - Builds prompt with task + instructions                │
│     - Sets responseMimeType: "application/json"             │
│     - Configures temperature and max tokens                 │
│     (See: gemini-request.json)                              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  3. SDK sends request to Gemini 1.5 Flash                   │
│     - Authentication via API key                            │
│     - HTTPS to Gemini API endpoint                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  4. Gemini processes and returns JSON response              │
│     (Typically 1-3 seconds)                                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  5. Application validates response                          │
│     - Parse JSON                                            │
│     - Check all required fields present                     │
│     - Validate priority/complexity enums                    │
│     - Verify categories is non-empty array                  │
│     (See: gemini-response.json validation rules)            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  6. Display results in side-by-side UI                      │
│     - Left panel: Original task                             │
│     - Right panel: AI analysis                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Request Construction Example

```javascript
import { GoogleGenerativeAI } from '@google/generative-ai';

// Initialize SDK with API key
const genAI = new GoogleGenerativeAI(import.meta.env.VITE_GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

// Construct prompt with task
const prompt = constructPrompt(taskDescription);

// Create request with generation config
const request = {
  contents: [{
    role: 'user',
    parts: [{ text: prompt }]
  }],
  generationConfig: {
    responseMimeType: 'application/json',
    temperature: 0.3,
    maxOutputTokens: 1024
  }
};

// Send request
const result = await model.generateContent(request);
const responseText = result.response.text();
const analysis = JSON.parse(responseText);
```

See `gemini-request.json` for complete schema.

---

## Response Validation Example

```javascript
function validateGeminiResponse(response) {
  // Check response is an object
  if (!response || typeof response !== 'object') {
    return { valid: false, error: 'Invalid response format' };
  }
  
  // Validate priority field
  const validPriorities = ['HIGH', 'MEDIUM', 'LOW'];
  if (!validPriorities.includes(response.priority)) {
    return { valid: false, error: 'Invalid priority value' };
  }
  
  // Validate categories field
  if (!Array.isArray(response.categories) || response.categories.length === 0) {
    return { valid: false, error: 'Invalid categories format' };
  }
  
  // Validate complexity field
  const validComplexities = ['HIGH', 'MEDIUM', 'LOW'];
  if (!validComplexities.includes(response.complexity)) {
    return { valid: false, error: 'Invalid complexity value' };
  }
  
  // Validate suggestion field
  if (typeof response.suggestion !== 'string' || response.suggestion.trim().length === 0) {
    return { valid: false, error: 'Missing suggestion text' };
  }
  
  return { valid: true };
}

// Usage
try {
  const responseText = result.response.text();
  const analysis = JSON.parse(responseText);
  
  const validation = validateGeminiResponse(analysis);
  if (!validation.valid) {
    throw new Error('VALIDATION_ERROR');
  }
  
  // Display results
  displayResults(taskText, analysis);
  
} catch (error) {
  if (error instanceof SyntaxError) {
    showError('Received invalid response from AI. Please try again.');
  } else if (error.message === 'VALIDATION_ERROR') {
    showError('AI response incomplete. Please try again.');
  } else {
    showError('AI service temporarily unavailable. Please try again shortly.');
  }
}
```

See `gemini-response.json` for complete validation rules.

---

## Error Handling

### Network Errors
**Detection**: Fetch failures, timeout errors  
**User Message**: "Unable to connect to Gemini AI. Please check your internet connection and try again."

### Authentication Errors
**Detection**: 401/403 HTTP status codes  
**User Message**: "API authentication failed. Please check your Gemini API key."

### Rate Limit Errors
**Detection**: 429 HTTP status code  
**User Message**: "AI service rate limit reached. Please wait a moment before trying again."

### Parse Errors
**Detection**: JSON.parse() throws SyntaxError  
**User Message**: "Received invalid response from AI. Please try again."

### Validation Errors
**Detection**: Missing fields or invalid enum values  
**User Message**: "AI response incomplete. Please try again."

---

## Common Categories

The Gemini model is prompted with these common category examples:

- **CRITICAL-PATH**: Blocks other work or releases
- **USER-FACING**: Directly impacts end-user experience
- **SECURITY**: Security vulnerabilities or concerns
- **BUG-FIX**: Resolves existing defects
- **FEATURE**: New functionality or capability
- **TECHNICAL-DEBT**: Code quality or architecture improvements
- **DOCUMENTATION**: User guides, API docs, comments
- **TESTING**: Test coverage, test infrastructure
- **INFRASTRUCTURE**: Deployment, CI/CD, tooling
- **PERFORMANCE**: Speed, scalability, optimization
- **ACCESSIBILITY**: A11y compliance and improvements
- **REFACTORING**: Code restructuring without feature changes
- **DEPLOYMENT**: Release and rollout tasks
- **MONITORING**: Observability and alerting

**Note**: Gemini may suggest contextually appropriate categories beyond this list.

---

## Priority Decision Matrix

### HIGH Priority
- **Characteristics**: Blocks other work, security issues, critical bugs, user-facing failures
- **Examples**: 
  - "Fix login authentication bypass vulnerability"
  - "Database corruption preventing all transactions"
  - "Production outage affecting all users"

### MEDIUM Priority
- **Characteristics**: Important but not blocking, feature work, refactoring with clear value
- **Examples**:
  - "Add dark mode toggle to settings"
  - "Refactor API endpoints for better maintainability"
  - "Implement new search filters"

### LOW Priority
- **Characteristics**: Nice-to-have, documentation, minor improvements
- **Examples**:
  - "Update README with new screenshots"
  - "Add tooltips to advanced settings"
  - "Improve error message wording"

---

## Complexity Estimation Matrix

### HIGH Complexity
- **Characteristics**: Multi-day effort, extensive testing required, touches many systems
- **Examples**:
  - "Migrate database from PostgreSQL to MongoDB"
  - "Implement end-to-end encryption for all data"
  - "Rewrite authentication system with SSO"

### MEDIUM Complexity
- **Characteristics**: 1-2 day effort, moderate scope, some dependencies
- **Examples**:
  - "Add pagination to task list"
  - "Integrate third-party analytics service"
  - "Refactor file upload component"

### LOW Complexity
- **Characteristics**: Hours of work, isolated change, minimal risk
- **Examples**:
  - "Fix typo in error message"
  - "Update button color to match brand"
  - "Add logging to specific function"

---

## Testing the Integration

### Manual Testing Checklist

1. **Normal Flow**:
   - ✅ Submit task → Receive valid analysis → Display results
   - ✅ Priority is one of HIGH/MEDIUM/LOW
   - ✅ Categories is non-empty array
   - ✅ Complexity is one of HIGH/MEDIUM/LOW
   - ✅ Suggestion is readable sentence

2. **Error Scenarios**:
   - ✅ No API key → Show configuration error
   - ✅ Invalid API key → Show authentication error
   - ✅ Network offline → Show connection error
   - ✅ Rate limit hit → Show rate limit error

3. **Edge Cases**:
   - ✅ Very short task ("Fix bug") → Still returns complete analysis
   - ✅ Very long task (multiple paragraphs) → Successfully processes
   - ✅ Technical jargon → Categorizes appropriately
   - ✅ Vague task ("Make it better") → Acknowledges ambiguity in suggestion

### Example Test Tasks

```javascript
// High priority examples
"Fix critical security vulnerability in user authentication"
"Production database failing to accept connections"
"Payment processing completely broken for all users"

// Medium priority examples
"Add dark mode support to the application"
"Refactor legacy API endpoints for better maintainability"
"Implement new analytics dashboard"

// Low priority examples
"Update README documentation with new screenshots"
"Add code comments to utility functions"
"Improve wording of success messages"

// Edge cases
"Bug" // Very short
"Investigate intermittent timeout issues in the search API that occur sporadically under high load conditions, possibly related to database connection pooling configuration or network latency between services" // Very long
"Implement OAuth2" // Technical jargon
"Make the app better" // Vague
```

---

## SDK Reference

### Package Information
- **Name**: `@google/generative-ai`
- **Version**: Latest (0.21.0+)
- **Documentation**: https://ai.google.dev/api/generate-content

### Installation
```bash
npm install @google/generative-ai
```

### Basic Usage
```javascript
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(API_KEY);
const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

const result = await model.generateContent(prompt);
const text = result.response.text();
```

---

## Rate Limits (Free Tier)

- **Requests per minute**: 15 RPM
- **Requests per day**: 1,500 RPD
- **Tokens per minute**: 1,000,000 TPM

**Workshop Context**: These limits are more than sufficient for demo purposes (~10-20 requests per session).

---

## Security Considerations

⚠️ **Important**: This implementation uses frontend API calls for workshop demo purposes only.

**Workshop Pattern** (Current):
- API key stored in frontend environment variable
- Visible in browser network inspector
- Acceptable for personal API keys on free tier
- Not suitable for production use

**Production Pattern** (Recommended):
```
Frontend → Backend API → Gemini
           (API key secured server-side)
```

**Best Practices**:
- Never commit `.env` file to Git
- Use `.env.example` for documentation only
- Rotate API keys after public demos
- Monitor API usage on Google AI Studio
- Consider backend proxy for production

---

## Related Documentation

- [Spec](../spec.md) - Feature requirements and user stories
- [Research](../research.md) - Technology decisions and alternatives
- [Data Model](../data-model.md) - Entity definitions and validation rules
- [Quickstart](../quickstart.md) - Setup and development instructions

---

## Questions & Troubleshooting

### Q: Why does Gemini sometimes return unexpected categories?
A: The AI model generates contextually appropriate categories based on the task description. While we provide common examples, it may create new categories that better describe the task.

### Q: What if the response is missing a field?
A: The validation layer catches this and shows "AI response incomplete" error to the user. This is a rare edge case but handled gracefully.

### Q: How do I test without using API quota?
A: Keep the original mock data function as a fallback. If no API key is set, the app can use mock data for development.

### Q: What if I hit rate limits during the workshop?
A: Free tier provides 15 requests/minute, which should be sufficient. If needed, wait 1 minute or use a backup API key.

### Q: Is the API key visible in the browser?
A: Yes - frontend environment variables are exposed to client code. This is acceptable for demos but not for production applications.

