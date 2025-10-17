# Quickstart Guide: Gemini AI Integration

**Feature**: Gemini AI Integration for Task Prioritization  
**Branch**: `002-gemini-ai-integration`  
**Date**: October 17, 2025

## Overview

This guide walks you through setting up the Gemini AI integration for the Task Prioritizer application. You'll configure your API key, install dependencies, and test the AI-powered task analysis feature.

**Prerequisites**:
- Node.js v18+ installed
- Basic familiarity with terminal/command line
- Git installed (optional, for cloning)

**Time to complete**: ~10 minutes

---

## Step 1: Get a Gemini API Key

### 1.1 Sign in to Google AI Studio

1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Sign in with your Google account
3. Accept the terms of service if prompted

### 1.2 Create an API Key

1. Click **"Get API Key"** in the top navigation
2. Click **"Create API Key"** button
3. Choose **"Create API key in new project"** (recommended for demos)
4. Copy the generated API key (format: `AIza...`)
5. ⚠️ **Important**: Keep this key private - don't share publicly

**Free Tier Limits**:
- 15 requests per minute
- 1,500 requests per day
- Sufficient for workshop demos and testing

---

## Step 2: Clone and Install

### 2.1 Clone the Repository (if not already done)

```bash
git clone <repository-url>
cd task-prio-ai-workshop
```

### 2.2 Checkout the Feature Branch

```bash
git checkout 002-gemini-ai-integration
```

### 2.3 Install Dependencies

```bash
npm install
```

This installs:
- `vite` - Development server (existing)
- `@google/generative-ai` - Gemini SDK (new)

**Expected output**:
```
added 2 packages, and audited 3 packages in 2s
found 0 vulnerabilities
```

---

## Step 3: Configure API Key

### 3.1 Create `.env` File

In the project root directory, create a new file named `.env`:

```bash
# On Mac/Linux
touch .env

# On Windows
type nul > .env
```

### 3.2 Add API Key

Open `.env` in your text editor and add:

```bash
VITE_GEMINI_API_KEY=your_actual_api_key_here
```

Replace `your_actual_api_key_here` with the API key you copied in Step 1.

**Example**:
```bash
VITE_GEMINI_API_KEY=AIzaSyC-abcdefghijklmnopqrstuvwxyz123456
```

### 3.3 Verify `.env` is Ignored by Git

Check that `.env` is listed in `.gitignore`:

```bash
cat .gitignore | grep .env
```

Expected output: `.env`

⚠️ **Security**: Never commit the `.env` file to Git. It contains your private API key.

---

## Step 4: Start the Development Server

### 4.1 Run the Dev Server

```bash
npm run dev
```

**Expected output**:
```
  VITE v5.4.20  ready in 150 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

### 4.2 Open in Browser

The browser should open automatically to `http://localhost:5173/`

If not, manually open: http://localhost:5173/

---

## Step 5: Test the Integration

### 5.1 Basic Functionality Test

1. **Enter a task**: Type "Fix the bug in the login form" in the textarea
2. **Click "Analyze Task"** button
3. **Wait 1-3 seconds**: You'll see "Analyzing..." on the button
4. **View results**: The page displays:
   - **Left panel**: Your original task text
   - **Right panel**: AI analysis with Priority, Categories, Complexity, and Suggested Order

**Expected result**:
```
Priority: HIGH
Categories: CRITICAL-PATH, USER-FACING, SECURITY
Estimated Complexity: MEDIUM
Suggested Order: "Do this before feature work - blocks user access"
```

### 5.2 Try Different Tasks

Test with various task descriptions:

**High Priority Example**:
```
Fix critical security vulnerability in user authentication
```

**Medium Priority Example**:
```
Add dark mode toggle to the settings page
```

**Low Priority Example**:
```
Update README documentation with new screenshots
```

**Vague Task Example**:
```
Make the app better
```

Each should return contextually relevant analysis.

---

## Step 6: Test Error Handling

### 6.1 Test Missing API Key

1. Rename `.env` to `.env.backup`
2. Refresh the page
3. Submit a task
4. **Expected**: Error message "Gemini API key not configured. Please add VITE_GEMINI_API_KEY to your .env file."
5. Rename `.env.backup` back to `.env`

### 6.2 Test Invalid API Key

1. Edit `.env` and change the API key to `INVALID_KEY`
2. Refresh the page
3. Submit a task
4. **Expected**: Error message "API authentication failed. Please check your Gemini API key."
5. Restore the correct API key in `.env`

### 6.3 Test Network Error (Optional)

1. Disconnect from the internet
2. Submit a task
3. **Expected**: Error message "Unable to connect to Gemini AI. Please check your internet connection and try again."
4. Reconnect to the internet

---

## Troubleshooting

### Problem: "VITE_GEMINI_API_KEY is undefined"

**Cause**: Environment variable not loaded

**Solutions**:
1. Verify `.env` file exists in project root (not in subdirectory)
2. Check the variable name is exactly `VITE_GEMINI_API_KEY` (including `VITE_` prefix)
3. Restart the dev server (`Ctrl+C` then `npm run dev`)
4. Clear browser cache and refresh

---

### Problem: "API authentication failed"

**Cause**: Invalid or expired API key

**Solutions**:
1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Verify your API key is active
3. Generate a new API key if needed
4. Update `.env` with the new key
5. Refresh the browser

---

### Problem: "AI service rate limit reached"

**Cause**: Exceeded 15 requests per minute

**Solutions**:
1. Wait 60 seconds before submitting again
2. Check Google AI Studio for quota usage
3. Consider upgrading to paid tier if needed for production

---

### Problem: Page shows mock data instead of AI responses

**Cause**: API integration not implemented yet, or API key fallback

**Solutions**:
1. Verify you're on the correct branch: `git branch` should show `002-gemini-ai-integration`
2. Check that the code has been implemented (see `index.html` for Gemini import)
3. Verify API key is configured in `.env`

---

### Problem: Loading indicator appears but never completes

**Cause**: API timeout or network issue

**Solutions**:
1. Check browser console for error messages (`F12` → Console tab)
2. Verify internet connection is stable
3. Try a shorter task description
4. Check Google AI Studio for service status

---

## Development Workflow

### Running Tests

Manual testing checklist:
- ✅ Empty submission shows error
- ✅ Valid task shows AI analysis
- ✅ Results display in side-by-side layout
- ✅ Loading state appears during API call
- ✅ Errors show user-friendly messages
- ✅ Multiple submissions work correctly

### Making Code Changes

1. Edit `index.html` with your changes
2. Save the file
3. Vite automatically reloads the browser
4. Test your changes immediately

### Viewing API Requests

1. Open browser DevTools (`F12`)
2. Go to **Network** tab
3. Submit a task
4. Look for request to `generativelanguage.googleapis.com`
5. Click to view request/response details

**Note**: The API key will be visible in the request headers (acceptable for demos).

---

## Project Structure

```
task-prio-ai-workshop/
├── index.html              # Main application (modified for Gemini)
├── .env                    # Your API key (not committed)
├── .env.example            # API key template (committed)
├── package.json            # Dependencies including @google/generative-ai
├── vite.config.js          # Vite configuration (unchanged)
└── specs/
    └── 002-gemini-ai-integration/
        ├── spec.md         # Feature requirements
        ├── plan.md         # Implementation plan
        ├── research.md     # Technology decisions
        ├── data-model.md   # API structures
        ├── quickstart.md   # This guide
        └── contracts/      # API contracts
            ├── gemini-request.json
            ├── gemini-response.json
            └── README.md
```

---

## Environment Variables Reference

### VITE_GEMINI_API_KEY

**Required**: Yes  
**Format**: String (typically 39 characters)  
**Example**: `AIzaSyC-abcdefghijklmnopqrstuvwxyz123456`  
**Where to get**: [Google AI Studio](https://aistudio.google.com/)  
**Security**: Keep private, never commit to Git

**Why the `VITE_` prefix?**
- Vite only exposes environment variables with this prefix to client code
- Prevents accidental exposure of server-side secrets
- Standard Vite convention for frontend environment variables

**Accessing in code**:
```javascript
const apiKey = import.meta.env.VITE_GEMINI_API_KEY;
```

---

## API Usage Monitoring

### Check Your Usage

1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Click **"API Keys"** in the navigation
3. View **"Quota"** section for your key
4. Monitor requests per minute and per day

### Free Tier Limits

| Metric | Limit | Workshop Usage |
| ------ | ----- | -------------- |
| Requests per minute | 15 | ~5-10 during demo |
| Requests per day | 1,500 | ~50-100 for workshop |
| Tokens per minute | 1,000,000 | Not a concern |

**Note**: Each task submission = 1 request

---

## Next Steps

### After Setup is Working

1. **Experiment with different tasks**: Try various descriptions and observe how AI categorizes them
2. **Review the contracts**: Check `contracts/README.md` to understand API structure
3. **Explore the code**: Look at `index.html` to see how the Gemini SDK is used
4. **Test edge cases**: Submit very short, very long, or vague tasks

### For Production Use

This implementation is for **workshop demo purposes only**. For production:

1. **Add backend API proxy**: Never expose API keys in frontend
2. **Implement rate limiting**: Prevent abuse of your API quota
3. **Add response caching**: Reduce API costs for repeated queries
4. **Monitor API usage**: Track costs and performance
5. **Add retry logic**: Handle transient failures gracefully
6. **Implement user authentication**: Control who can use the feature

---

## Additional Resources

### Documentation
- [Google Gemini API Docs](https://ai.google.dev/docs)
- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)
- [Feature Spec](./spec.md)
- [API Contracts](./contracts/README.md)

### Tools
- [Google AI Studio](https://aistudio.google.com/) - Manage API keys and test prompts
- [Vite DevTools](https://vitejs.dev/) - Build tool documentation

### Support
- Check [research.md](./research.md) for technology decisions
- Review [data-model.md](./data-model.md) for API structures
- See [contracts/](./contracts/) for request/response examples

---

## Summary

You've successfully:
- ✅ Created a Gemini API key
- ✅ Installed project dependencies
- ✅ Configured the API key in `.env`
- ✅ Started the development server
- ✅ Tested AI-powered task analysis
- ✅ Verified error handling

The Task Prioritizer now uses real AI instead of hardcoded responses! 🎉

**Time to implement**: The setup takes ~10 minutes. The actual code implementation adds ~100-150 lines to `index.html`.

---

## Checklist

Before considering this feature complete, verify:

- [ ] `.env` file created with valid API key
- [ ] `npm install` completed successfully
- [ ] Dev server starts without errors
- [ ] Task submission returns AI analysis (not mock data)
- [ ] All four fields displayed (priority, categories, complexity, suggestion)
- [ ] Loading state appears during API call
- [ ] Error handling tested (missing key, invalid key)
- [ ] Multiple submissions work correctly
- [ ] Results display in side-by-side layout
- [ ] API key not committed to Git (check `.gitignore`)

---

**Happy coding! 🚀**

*Questions? Check the [Troubleshooting](#troubleshooting) section or review the [contracts documentation](./contracts/README.md).*

