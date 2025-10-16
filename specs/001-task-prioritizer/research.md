# Research & Technical Decisions: Task Prioritizer Application

**Feature**: Task Prioritizer Application  
**Branch**: `001-task-prioritizer`  
**Date**: October 16, 2025  
**Status**: Phase 0 Complete

## Overview

This document captures all technical research and decisions made during Phase 0 planning for the Task Prioritizer application. The goal is to create a minimal, workshop-friendly single-page application using vanilla JavaScript.

## Technology Stack Decisions

### 1. Build Tool: Vite

**Decision**: Use Vite as the development server and build tool

**Rationale**:
- **Fast dev server**: Instant hot module reload (HMR) for rapid development
- **Zero configuration**: Works out-of-box with vanilla JavaScript, HTML, CSS
- **Modern**: Native ES modules support, no bundling during development
- **Workshop-friendly**: Simple `npm run dev` command to start
- **Lightweight**: Minimal dependencies compared to Webpack or other bundlers
- **Production-ready**: Optional build command for deployment

**Alternatives Considered**:
- **Live Server / http-server**: Simpler but no HMR, requires manual refresh
- **Parcel**: Automatic but less explicit, harder to demonstrate
- **Webpack**: Too complex for a workshop demo, requires extensive configuration
- **No build tool**: Possible but misses modern dev experience (HMR, module imports)

**Implementation**:
```bash
npm create vite@latest . -- --template vanilla
```

---

### 2. Frontend Framework: None (Vanilla JavaScript)

**Decision**: Use vanilla JavaScript with no framework or library

**Rationale**:
- **Workshop requirement**: Explicit requirement for minimal, framework-free code
- **Learning value**: Shows fundamental DOM manipulation and event handling
- **Zero dependencies**: No runtime libraries, just browser APIs
- **Performance**: Instant load time, no framework overhead
- **Simplicity**: Easy to understand for workshop attendees
- **Code visibility**: All logic visible in a single file

**Alternatives Considered**:
- **React**: Too much abstraction, requires JSX understanding, build complexity
- **Vue**: Simpler than React but still adds framework concepts
- **Svelte**: Compiles away but adds build step complexity
- **Alpine.js**: Lightweight but still a dependency
- **Preact**: Minimal React alternative but unnecessary for this scope

**Best Practices for Vanilla JS**:
- Use modern ES6+ features (arrow functions, template literals, destructuring)
- Organize code with clear functions for each responsibility
- Use `querySelector` and `getElementById` for DOM access
- Handle events with `addEventListener`
- Use `textContent` for safe text insertion (prevents XSS)

---

### 3. Layout: CSS Grid

**Decision**: Use CSS Grid for side-by-side layout

**Rationale**:
- **Workshop requirement**: Explicit requirement for CSS Grid
- **Two-column layout**: Perfect use case for Grid (`grid-template-columns: 1fr 1fr`)
- **Responsive**: Easy to switch to single column on mobile with media queries
- **Modern**: Widely supported in all modern browsers
- **Semantic**: Clear structure with named grid areas
- **Minimal code**: Less CSS than Flexbox for this specific layout

**Alternatives Considered**:
- **Flexbox**: Good alternative but Grid is more explicit for two-column layouts
- **Float layout**: Outdated, harder to maintain, poor responsive behavior
- **Table display**: Semantic issues, not recommended for layout
- **Absolute positioning**: Complex, not responsive-friendly

**Implementation Pattern**:
```css
.results-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

@media (max-width: 768px) {
  .results-container {
    grid-template-columns: 1fr;
  }
}
```

---

### 4. Code Organization: Single HTML File with Embedded Styles and Scripts

**Decision**: All code in `index.html` with `<style>` and `<script>` tags

**Rationale**:
- **Workshop requirement**: Explicit requirement for single HTML file
- **Demo-friendly**: Attendees see all code in one place
- **No imports**: No module system to explain
- **Copy-paste ready**: Easy to share complete working code
- **Progressive enhancement**: Can extract to separate files later

**Alternatives Considered**:
- **Separate files**: Better for production but adds complexity for workshop
- **Inline styles**: Too mixed with HTML, harder to read
- **External JS modules**: Requires import/export understanding

**Structure**:
```html
<!DOCTYPE html>
<html>
<head>
  <style>
    /* All CSS here */
  </style>
</head>
<body>
  <!-- HTML structure -->
  <script>
    // All JavaScript here
  </script>
</body>
</html>
```

---

### 5. Form Validation: Client-Side JavaScript

**Decision**: Simple empty-textarea check with visual feedback

**Rationale**:
- **Requirement**: FR-009 requires empty submission prevention
- **User experience**: Immediate feedback without page reload
- **Simple implementation**: Just check `textarea.value.trim()` length
- **Workshop-appropriate**: Easy to demonstrate and understand

**Implementation Pattern**:
```javascript
form.addEventListener('submit', (e) => {
  e.preventDefault();
  const taskText = textarea.value.trim();
  
  if (!taskText) {
    // Show error message
    return;
  }
  
  // Process submission
});
```

**Error Handling**:
- Display inline error message below textarea
- Use aria-live for accessibility
- Clear error on next input

---

### 6. Mock Data Strategy: Hardcoded JavaScript Object

**Decision**: Use a simple JavaScript object matching input text to output data

**Rationale**:
- **Requirement**: FR-008 specifies exact hardcoded example
- **Simplicity**: No API calls, no async complexity
- **Predictable**: Always returns same result for same input
- **Workshop-friendly**: Easy to add more examples by extending the object

**Implementation Pattern**:
```javascript
const mockAnalyses = {
  "Fix the bug in the login form": {
    priority: "HIGH",
    categories: ["CRITICAL-PATH", "USER-FACING", "SECURITY"],
    complexity: "MEDIUM",
    suggestedOrder: "Do this before feature work - blocks user access"
  },
  // Can add more examples for demo
};

function analyzeTask(taskDescription) {
  const normalized = taskDescription.trim();
  return mockAnalyses[normalized] || getDefaultAnalysis();
}
```

---

### 7. Responsive Design: Mobile-First with Breakpoint at 768px

**Decision**: Stack panels vertically on mobile, side-by-side on tablet+

**Rationale**:
- **Success Criterion**: SC-003 specifies 768px minimum for side-by-side
- **User experience**: Better readability on small screens
- **Standard breakpoint**: 768px is common tablet/desktop threshold
- **CSS Grid**: Easy to implement with media query

**Breakpoints**:
- **< 768px**: Single column, stacked layout
- **≥ 768px**: Two columns, side-by-side layout

---

### 8. Accessibility Considerations

**Decision**: Include basic accessibility features

**Rationale**:
- **Best practice**: Even demos should model good behavior
- **Workshop value**: Teaches accessibility fundamentals
- **Minimal effort**: Basic ARIA attributes and semantic HTML

**Features**:
- Semantic HTML (`<main>`, `<form>`, `<label>`)
- Form labels with `for` attribute
- ARIA live regions for dynamic content
- Keyboard navigation support (native form elements)
- Sufficient color contrast in visual design

---

### 9. Browser Compatibility

**Decision**: Target modern evergreen browsers (last 2 versions)

**Rationale**:
- **ES6+ features**: Using modern JavaScript syntax
- **CSS Grid**: Requires modern browser support
- **Workshop context**: Attendees likely using recent browsers
- **No polyfills**: Keeps code minimal

**Supported Browsers**:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

**Not Supporting**:
- Internet Explorer (retired)
- Older mobile browsers

---

### 10. Development Workflow

**Decision**: Vite dev server with hot reload for development

**Rationale**:
- **Fast iteration**: Changes appear immediately
- **Workshop-friendly**: Students see changes instantly
- **Standard workflow**: Same as modern web development

**Commands**:
```bash
npm install        # Install Vite
npm run dev        # Start dev server (default: http://localhost:5173)
npm run build      # Optional: Build for production
npm run preview    # Optional: Preview production build
```

---

## Research Summary

### Questions Resolved

1. **What build tool to use?**
   - ✅ Vite - fast, minimal, workshop-friendly

2. **How to structure the code?**
   - ✅ Single HTML file with embedded CSS and JS

3. **How to implement side-by-side layout?**
   - ✅ CSS Grid with `grid-template-columns: 1fr 1fr`

4. **How to handle form validation?**
   - ✅ Client-side JavaScript with trim() check

5. **How to store mock data?**
   - ✅ JavaScript object with task text as key

6. **What responsive strategy to use?**
   - ✅ Mobile-first with 768px breakpoint

7. **What level of accessibility to include?**
   - ✅ Basic semantic HTML and ARIA attributes

8. **What browsers to support?**
   - ✅ Modern evergreen browsers (last 2 versions)

### No Clarifications Needed

All technical decisions have been made based on:
- Explicit user requirements (Vite, vanilla JS, CSS Grid, single file)
- Feature specification (side-by-side layout, form validation, hardcoded data)
- Workshop context (clean, readable, demo-friendly code)
- Industry best practices (accessibility, responsive design, semantic HTML)

---

## Next Steps

Proceed to **Phase 1: Design & Contracts**:
1. Generate `data-model.md` with Task and TaskAnalysis structures
2. Create `contracts/mock-data-contract.json` with data shape
3. Generate `quickstart.md` with setup instructions
4. Update agent context with Vite + vanilla JS stack

