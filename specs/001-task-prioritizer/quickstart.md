# Task Prioritizer - Quickstart Guide

**Feature**: Task Prioritizer Application  
**Branch**: `001-task-prioritizer`  
**Target Audience**: Workshop attendees and developers  
**Time to First Run**: ~2 minutes

## Overview

This quickstart guide will help you set up and run the Task Prioritizer application locally. The app is a minimal single-page web application built with Vite, vanilla JavaScript, HTML, and CSS.

## Prerequisites

- **Node.js**: Version 18.x or higher ([Download](https://nodejs.org/))
- **npm**: Version 9.x or higher (comes with Node.js)
- **Modern browser**: Chrome, Firefox, Safari, or Edge (last 2 versions)
- **Code editor**: VS Code, Sublime, or any text editor (optional for viewing code)

### Check Prerequisites

```bash
node --version  # Should be v18.x or higher
npm --version   # Should be v9.x or higher
```

## Quick Start (3 Steps)

### 1. Clone and Navigate

```bash
# If you haven't cloned yet
git clone <repository-url> task-prio-ai-workshop
cd task-prio-ai-workshop

# Switch to feature branch
git checkout 001-task-prioritizer
```

### 2. Install Dependencies

```bash
npm install
```

**Expected output**: Installs Vite and minimal dependencies (~10MB)

### 3. Start Development Server

```bash
npm run dev
```

**Expected output**:
```
VITE v5.x.x  ready in XXX ms

➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

**Open in browser**: Navigate to `http://localhost:5173/`

🎉 **You're done!** The app should be running.

## Using the Application

### Basic Workflow

1. **Enter a task** in the textarea:
   ```
   Fix the bug in the login form
   ```

2. **Click "Analyze Task"** button

3. **View results** in side-by-side layout:
   - **Left panel**: Your original task text
   - **Right panel**: AI analysis with priority, categories, complexity, and suggested order

### Try the Hardcoded Example

The app recognizes this specific input (required by FR-008):

**Input**:
```
Fix the bug in the login form
```

**Expected Output**:
- **Priority**: HIGH
- **Categories**: CRITICAL-PATH, USER-FACING, SECURITY
- **Estimated Complexity**: MEDIUM
- **Suggested Order**: "Do this before feature work - blocks user access"

### Try Other Examples

The app includes additional examples for demonstration:

1. `Write unit tests for payment module`
2. `Update README documentation`
3. `Refactor legacy API endpoints`
4. `Add dark mode toggle`
5. `Investigate performance bottleneck in search`

**Note**: Any unrecognized task will receive a default "MEDIUM" priority analysis.

## Project Structure

```
task-prio-ai-workshop/
├── index.html           # Single-page app (all code here)
├── package.json         # Vite configuration
├── vite.config.js       # Vite settings (minimal)
└── specs/               # Feature specifications
    └── 001-task-prioritizer/
        ├── spec.md
        ├── plan.md
        ├── research.md
        ├── data-model.md
        ├── quickstart.md (this file)
        └── contracts/
```

**Key file**: `index.html` contains:
- HTML structure (textarea, button, result panels)
- CSS styling (embedded in `<style>` tag)
- JavaScript logic (embedded in `<script>` tag)

## Development Commands

### Start Dev Server
```bash
npm run dev
```
- Starts Vite dev server with hot reload
- Automatically opens default browser (usually)
- Changes to `index.html` reload instantly

### Build for Production (Optional)
```bash
npm run build
```
- Creates optimized production build in `dist/` folder
- Minifies HTML, CSS, and JavaScript
- Output is a single HTML file

### Preview Production Build (Optional)
```bash
npm run preview
```
- Serves the production build locally
- Test the optimized version before deployment

### Stop Dev Server
Press `Ctrl+C` in the terminal running `npm run dev`

## Code Overview

### HTML Structure
```html
<main>
  <h1>Task Prioritizer</h1>
  
  <!-- Input Form -->
  <form id="task-form">
    <label for="task-input">Enter Task Description</label>
    <textarea id="task-input"></textarea>
    <button type="submit">Analyze Task</button>
    <div id="error-message"></div>
  </form>
  
  <!-- Results (hidden initially) -->
  <div id="results-container" class="hidden">
    <div class="panel">
      <h2>Original Task</h2>
      <div id="original-task"></div>
    </div>
    <div class="panel">
      <h2>AI Analysis</h2>
      <div id="analysis-result"></div>
    </div>
  </div>
</main>
```

### CSS Layout (CSS Grid)
```css
#results-container {
  display: grid;
  grid-template-columns: 1fr 1fr;  /* Two equal columns */
  gap: 2rem;
}

@media (max-width: 768px) {
  #results-container {
    grid-template-columns: 1fr;  /* Stack on mobile */
  }
}
```

### JavaScript Functions
```javascript
// Mock data storage
const mockAnalyses = { /* ... */ };

// Main functions
function analyzeTask(taskDescription)     // Lookup mock data
function validateTaskInput(text)          // Check if input valid
function displayResults(submission)       // Update UI with results
function handleSubmit(event)             // Form submission handler
```

## Acceptance Testing

### Test Scenario 1: Required Example
1. Enter: `Fix the bug in the login form`
2. Click submit
3. ✅ Left panel shows exact text
4. ✅ Right panel shows HIGH priority, 3 categories, MEDIUM complexity

### Test Scenario 2: Empty Input
1. Leave textarea empty
2. Click submit
3. ✅ Error message appears: "Please enter a task description"
4. ✅ No results displayed

### Test Scenario 3: Multiple Submissions
1. Enter any task, submit
2. Enter different task, submit
3. ✅ Results update to show new task
4. ✅ Previous results are replaced

### Test Scenario 4: Responsive Layout
1. Open browser DevTools (F12)
2. Toggle device toolbar (mobile view)
3. ✅ Panels stack vertically on screens < 768px
4. ✅ Panels display side-by-side on screens ≥ 768px

## Troubleshooting

### Port 5173 Already in Use
**Error**: `Port 5173 is already in use`

**Solution**:
```bash
# Stop other Vite instances, or use different port
npm run dev -- --port 3000
```

### Browser Doesn't Auto-Open
**Issue**: Server starts but browser doesn't open

**Solution**: Manually navigate to `http://localhost:5173/`

### Changes Not Appearing
**Issue**: Edited `index.html` but changes don't show

**Solution**:
1. Check terminal - dev server should still be running
2. Hard refresh browser: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
3. Restart dev server: `Ctrl+C`, then `npm run dev`

### Module Not Found Errors
**Error**: Cannot find module errors

**Solution**:
```bash
rm -rf node_modules
npm install
```

### Blank Page
**Issue**: Page loads but shows nothing

**Solution**:
1. Open browser DevTools (F12) → Console tab
2. Check for JavaScript errors
3. Verify `index.html` has no syntax errors
4. Try hard refresh: `Ctrl+Shift+R`

## Next Steps

### For Workshop Attendees

1. **Explore the code**: Open `index.html` in your editor
2. **Modify styling**: Change colors, fonts, layout in `<style>` section
3. **Add mock examples**: Extend `mockAnalyses` object with new tasks
4. **Customize analysis**: Modify analysis fields or add new ones

### For Developers

1. **Review specification**: Read `spec.md` for requirements
2. **Understand data model**: Review `data-model.md` for structure
3. **Check contracts**: See `contracts/` for data schemas
4. **Plan implementation**: Review `plan.md` for architecture decisions

### Future Enhancements

Ready to extend the app? Consider:

1. **Real AI integration**: Replace mock data with API calls
2. **Task history**: Store multiple submissions in array
3. **Export results**: Add button to download as JSON/CSV
4. **Filtering**: Allow users to filter by priority or category
5. **Drag-and-drop**: Reorder tasks by priority
6. **Persistence**: Save tasks to localStorage or backend

See `data-model.md` → "Future Extensibility" section for detailed guidance.

## Resources

- **Vite Documentation**: https://vitejs.dev/
- **CSS Grid Guide**: https://css-tricks.com/snippets/css/complete-guide-grid/
- **MDN Web Docs**: https://developer.mozilla.org/
- **Project Specification**: `specs/001-task-prioritizer/spec.md`
- **Implementation Plan**: `specs/001-task-prioritizer/plan.md`

## Getting Help

- **Check specification**: All requirements documented in `spec.md`
- **Review contracts**: Data structures defined in `contracts/`
- **Read research**: Technical decisions explained in `research.md`
- **Open issue**: If you find a bug or have questions

## Success Criteria Checklist

Verify your setup is working:

- [ ] Dev server starts without errors
- [ ] Browser loads page at `http://localhost:5173/`
- [ ] Can enter text in textarea
- [ ] Submit button is clickable
- [ ] Required example produces correct output
- [ ] Empty submission shows error message
- [ ] Side-by-side layout visible on desktop
- [ ] Layout stacks vertically on mobile (< 768px)

✅ **All checked?** You're ready for the workshop!

---

**Last Updated**: October 16, 2025  
**Version**: 1.0.0  
**Maintainer**: Task Prioritizer Workshop Team

