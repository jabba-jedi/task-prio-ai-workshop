# Task Prioritizer Contracts

This directory contains the data contracts and mock data specifications for the Task Prioritizer application.

## Files

### `data-contract.json`

JSON Schema definitions for all data structures used in the application:

- **TaskDescription**: User input structure
- **TaskAnalysis**: AI analysis output structure  
- **TaskSubmission**: Combined structure for UI display
- **Priority/Complexity/Category**: Enumeration types
- **ValidationResult**: Input validation structure

**Usage**: Reference these schemas when implementing the JavaScript data handling logic to ensure type safety and contract compliance.

### `mock-data.json`

Hardcoded example data for the initial workshop demo:

- **mockAnalyses**: Object mapping task text to analysis results
- **defaultAnalysis**: Fallback for unmatched inputs
- **additionalExamples**: Extra examples for workshop demonstration

**Usage**: Convert to a JavaScript object in `index.html` for the mock analysis lookup function.

## Contract Compliance

All data flowing through the application must conform to these contracts:

1. **Input Validation**: User input must pass TaskDescription schema (non-empty, ≤10,000 chars)
2. **Analysis Structure**: All analyses must include all four required fields with valid enum values
3. **Display Data**: UI receives TaskSubmission objects with both task and analysis

## Testing

Use the examples in these contracts to test:

- ✅ Required example: "Fix the bug in the login form" → HIGH priority
- ✅ Additional examples: Various priority/category combinations
- ✅ Fallback case: Any unlisted input → default analysis

## Future Extensions

When integrating real AI:

1. Implement API endpoint that accepts TaskDescription
2. Return response conforming to TaskAnalysis schema
3. Replace mock object lookup with API call
4. Add loading/error states to TaskSubmission

The contracts remain the same - only the data source changes.

