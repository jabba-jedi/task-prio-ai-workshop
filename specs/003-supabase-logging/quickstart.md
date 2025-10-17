# Quickstart Guide: Supabase Database Logging

**Feature**: Supabase Database Logging  
**Branch**: `003-supabase-logging`  
**Date**: October 17, 2025  
**Estimated Setup Time**: 15-20 minutes

## Overview

This guide walks you through setting up Supabase database logging for the Task Prioritizer. After completing this setup, every task analysis will be automatically logged to a PostgreSQL database for history tracking and analytics.

## Prerequisites

Before starting, ensure you have:

- ✅ Task Prioritizer application with Gemini AI integration (Feature 002) working
- ✅ Node.js and npm installed
- ✅ A web browser (Chrome, Firefox, Safari, or Edge)
- ✅ Internet connection
- ✅ A Supabase account (free - will create if needed)

## Setup Steps

### Step 1: Create Supabase Project (5 minutes)

1. **Go to Supabase**:
   - Visit https://supabase.com
   - Click "Start your project" or "Sign in" if you have an account

2. **Sign Up / Log In**:
   - Use GitHub, GitLab, Google, or email
   - Verify your email if required

3. **Create New Project**:
   - Click "+ New Project"
   - **Organization**: Create new or select existing
   - **Project Name**: `task-prioritizer-workshop` (or any name you prefer)
   - **Database Password**: Click "Generate" and copy to a safe place
   - **Region**: Select closest to your location (e.g., US East, EU West)
   - **Pricing Plan**: Free (sufficient for workshop)
   - Click "Create new project"
   - Wait 1-2 minutes for project initialization

4. **Copy Your Credentials**:
   - Once the project is ready, click "Settings" (gear icon in sidebar)
   - Go to "API" section
   - Copy **Project URL**: `https://xxxxxxxxx.supabase.co`
   - Copy **anon / public key**: Long string starting with `eyJ...`
   - Keep these safe - you'll need them in Step 3

---

### Step 2: Create Database Table (3 minutes)

1. **Open SQL Editor**:
   - In your Supabase project, click "SQL Editor" in the sidebar
   - Click "+ New query"

2. **Run Table Creation Script**:
   - Copy and paste the following SQL:

   ```sql
   -- Enable UUID extension
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

   -- Add table comment
   COMMENT ON TABLE task_submissions IS 
     'Stores task analysis submissions with AI-generated prioritization insights';
   ```

3. **Execute the Query**:
   - Click "Run" (or press Ctrl/Cmd + Enter)
   - You should see "Success. No rows returned"

4. **Verify Table Created**:
   - Click "Table Editor" in the sidebar
   - You should see `task_submissions` in the list
   - Click on it to see the empty table with all columns

---

### Step 3: Configure Environment Variables (2 minutes)

1. **Locate Your `.env` File**:
   - Navigate to your project root directory
   - If `.env` doesn't exist, create it (touch `.env` or create in your editor)

2. **Add Supabase Credentials**:
   - Open `.env` in your text editor
   - Add the following lines (replace with your actual values from Step 1):

   ```bash
   # Existing Gemini API configuration
   VITE_GEMINI_API_KEY=your_existing_gemini_key_here

   # New Supabase configuration
   VITE_SUPABASE_URL=https://your-project-ref.supabase.co
   VITE_SUPABASE_ANON_KEY=your_anonymous_public_key_starting_with_eyJ
   ```

3. **Verify `.env` is Ignored**:
   - Check that `.gitignore` includes `.env`
   - **NEVER commit `.env` to version control**

4. **Update `.env.example`** (optional but recommended):
   ```bash
   # .env.example - Template for environment variables
   VITE_GEMINI_API_KEY=your_gemini_api_key_here
   VITE_SUPABASE_URL=https://your-project-ref.supabase.co
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

---

### Step 4: Configure Row Level Security (3 minutes)

Supabase requires explicit permission policies to allow database operations. For this workshop demo, we'll use a permissive policy.

1. **Open SQL Editor** (same as Step 2)

2. **Run RLS Policy Script**:
   ```sql
   -- Enable RLS on the table
   ALTER TABLE task_submissions ENABLE ROW LEVEL SECURITY;

   -- Policy: Allow anonymous inserts (workshop demo)
   CREATE POLICY "Allow anonymous inserts"
     ON task_submissions
     FOR INSERT
     TO anon
     WITH CHECK (true);

   -- Policy: Block anonymous reads (optional privacy)
   CREATE POLICY "Block anonymous reads"
     ON task_submissions
     FOR SELECT
     TO anon
     USING (false);
   ```

3. **Execute the Query**:
   - Click "Run"
   - You should see "Success. No rows returned"

4. **Verify Policies Created**:
   - Go to "Authentication" → "Policies" in Supabase
   - You should see "Allow anonymous inserts" policy for `task_submissions`

**Security Note**: This permissive policy is appropriate for workshop demos. Production applications should use authenticated users with strict policies.

---

### Step 5: Install Supabase Client Library (2 minutes)

1. **Open Terminal** in your project directory

2. **Install Package**:
   ```bash
   npm install @supabase/supabase-js
   ```

3. **Verify Installation**:
   - Check `package.json` - you should see:
   ```json
   "dependencies": {
     "@google/generative-ai": "^0.24.1",
     "@supabase/supabase-js": "^2.x.x",
     "vite": "^5.4.20"
   }
   ```

---

### Step 6: Restart Development Server (1 minute)

Environment variables are loaded at startup, so you need to restart:

1. **Stop Current Server**:
   - Press Ctrl+C in your terminal where Vite is running

2. **Start Server Again**:
   ```bash
   npm run dev
   ```

3. **Verify Environment Variables Loaded**:
   - Open browser console (F12)
   - Type: `import.meta.env.VITE_SUPABASE_URL`
   - You should see your Supabase URL (not undefined)

---

### Step 7: Test the Integration (5 minutes)

1. **Open the Application**:
   - Navigate to http://localhost:5173 (or your Vite dev server URL)

2. **Submit a Test Task**:
   - Enter: "Test database logging functionality"
   - Click "Analyze Task"
   - Wait for AI analysis to appear

3. **Verify Results Display** (this should work as before):
   - Left panel: Your original text
   - Right panel: AI analysis with Priority, Categories, Complexity, Suggested Order

4. **Check Browser Console**:
   - Open Developer Tools (F12) → Console tab
   - Look for: `Task logged successfully: [...]`
   - If you see an error, proceed to Troubleshooting section below

5. **Verify in Supabase Dashboard**:
   - Go to your Supabase project
   - Click "Table Editor"
   - Click "task_submissions"
   - You should see 1 row with your test task
   - Verify all columns are populated correctly

6. **Test Error Handling**:
   - In `.env`, temporarily change `VITE_SUPABASE_URL` to an invalid URL
   - Restart dev server (`Ctrl+C`, then `npm run dev`)
   - Submit another task
   - You should see:
     - ✅ AI analysis still displays normally
     - ⚠️ Warning banner: "Task history could not be saved at this time"
     - Console warning about database failure
   - Restore correct URL and restart server

---

## Verification Checklist

After completing setup, verify:

- [ ] Supabase project is created and accessible
- [ ] `task_submissions` table exists with correct schema
- [ ] Environment variables are set in `.env`
- [ ] `.env` is in `.gitignore` (never committed)
- [ ] @supabase/supabase-js package is installed
- [ ] Development server restarted after adding env variables
- [ ] Test task submission displays AI analysis
- [ ] Test task appears in Supabase Table Editor
- [ ] All database fields are populated (7 columns total)
- [ ] Console shows "Task logged successfully"
- [ ] Error scenario shows warning (not crash)

---

## Usage

Once setup is complete, the database logging works automatically:

1. **Normal Workflow**:
   - User submits task → AI analyzes → Results display → Database logs in background
   - No user action required for logging
   - No loading state or delay

2. **Viewing Logs**:
   - Go to Supabase dashboard → Table Editor → task_submissions
   - See all historical submissions with timestamps
   - Use SQL Editor for advanced queries

3. **Analyzing Data**:
   ```sql
   -- Count tasks by priority
   SELECT priority, COUNT(*) FROM task_submissions GROUP BY priority;
   
   -- Recent high-priority tasks
   SELECT task_text, created_at 
   FROM task_submissions 
   WHERE priority = 'HIGH' 
   ORDER BY created_at DESC 
   LIMIT 10;
   
   -- Tasks with specific category
   SELECT task_text, categories 
   FROM task_submissions 
   WHERE 'SECURITY' = ANY(categories);
   ```

---

## Troubleshooting

### Issue: "Supabase not configured" in console

**Symptoms**: Console shows warning, no logging occurs

**Causes**:
- Environment variables not set
- Development server not restarted after adding variables
- Typo in variable names (must be VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY)

**Solutions**:
1. Check `.env` file has both variables with correct names
2. Verify no extra spaces or quotes around values
3. Restart dev server (Ctrl+C, then npm run dev)
4. Test: `console.log(import.meta.env.VITE_SUPABASE_URL)` should show your URL

---

### Issue: "Insert failed" or "Permission denied"

**Symptoms**: Console error about permissions, no data in table

**Causes**:
- RLS policies not configured correctly
- Wrong anon key used

**Solutions**:
1. Verify RLS policy exists: Supabase → Authentication → Policies
2. Check policy allows INSERT for anon role
3. Confirm you copied the "anon public" key (not the "service role secret" key)
4. Re-run the RLS policy SQL from Step 4

---

### Issue: Database insert succeeds but fields are NULL

**Symptoms**: Row appears in table but some fields are empty

**Causes**:
- Gemini response format changed
- Field name mismatch in code

**Solutions**:
1. Check console for the actual Gemini response structure
2. Verify field mapping: `analysis.priority`, `analysis.categories`, `analysis.complexity`, `analysis.suggestion`
3. Check contracts/supabase-insert.json for correct field names

---

### Issue: "Invalid API key" or 401 errors

**Symptoms**: Authentication failure messages

**Causes**:
- Wrong API key copied
- Key copied with extra whitespace
- Service role key used instead of anon key

**Solutions**:
1. Go to Supabase → Settings → API
2. Copy the "anon public" key (long string starting with eyJ)
3. Paste in `.env` with no extra spaces or quotes
4. Restart dev server

---

### Issue: Data not appearing in Table Editor

**Symptoms**: Console says "success" but table is empty

**Causes**:
- Wrong database selected (if multiple projects)
- Cached view in dashboard
- Insert went to different table

**Solutions**:
1. Refresh the Table Editor page in browser
2. Verify you're looking at the correct project
3. Check SQL Editor: `SELECT * FROM task_submissions;`
4. Verify table name is exactly `task_submissions` (lowercase, underscore)

---

### Issue: Application crashes or becomes unresponsive

**Symptoms**: Error modal, blank screen, or infinite loading

**Causes**:
- Unhandled promise rejection
- Await on fire-and-forget function
- Missing error handling

**Solutions**:
1. Check browser console for stack trace
2. Verify logging function uses `.catch()` not `await`
3. Ensure database errors don't propagate to main UI
4. Check implementation matches fire-and-forget pattern from contracts

---

## Common Queries

### View All Submissions
```sql
SELECT * FROM task_submissions ORDER BY created_at DESC;
```

### Count by Priority
```sql
SELECT priority, COUNT(*) as count
FROM task_submissions
GROUP BY priority
ORDER BY count DESC;
```

### Find Recent High Priority
```sql
SELECT task_text, suggested_order, created_at
FROM task_submissions
WHERE priority = 'HIGH'
  AND created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

### Category Frequency
```sql
SELECT unnest(categories) as category, COUNT(*) as frequency
FROM task_submissions
GROUP BY category
ORDER BY frequency DESC;
```

### Export Data (CSV)
In Supabase Table Editor:
1. Select query results
2. Click "..." menu → "Download as CSV"

---

## Security Best Practices

### For Workshop Demos ✅

- ✅ Use personal Supabase accounts (not corporate)
- ✅ Keep `.env` file out of version control
- ✅ Use free tier projects (limited exposure)
- ✅ Rotate keys after public demos
- ✅ Don't share screenshots with visible keys
- ✅ Delete demo projects after workshop

### For Production ⚠️

If you plan to deploy this for real use:

- ⚠️ **DO NOT** use anonymous inserts (require authentication)
- ⚠️ **DO NOT** expose database credentials in frontend
- ⚠️ **DO** implement backend API proxy
- ⚠️ **DO** use strict RLS policies (users see only their data)
- ⚠️ **DO** add rate limiting
- ⚠️ **DO** encrypt sensitive data
- ⚠️ **DO** monitor for unusual activity
- ⚠️ **DO** implement proper user authentication

**Production Architecture**:
```
Frontend → Backend API → Supabase
         (credentials secured)
         (auth middleware)
         (rate limiting)
```

---

## Next Steps

### After Setup

1. **Experiment**: Submit various tasks and see how they're categorized
2. **Analyze**: Use SQL queries to find patterns in your task data
3. **Extend** (optional):
   - Add date range filters
   - Create charts/graphs from data
   - Export data for external analysis
   - Add user authentication
   - Display historical tasks in UI

### Resources

- **Supabase Docs**: https://supabase.com/docs
- **JavaScript Client Docs**: https://supabase.com/docs/reference/javascript/introduction
- **RLS Guide**: https://supabase.com/docs/guides/auth/row-level-security
- **PostgreSQL Array Functions**: https://www.postgresql.org/docs/current/functions-array.html

---

## Support

If you encounter issues not covered in troubleshooting:

1. Check browser console for detailed error messages
2. Verify all setup steps completed correctly
3. Review contracts/ directory for expected data formats
4. Check Supabase project logs (Settings → Logs)
5. Consult data-model.md for validation rules

**Common Workshop Questions**:

Q: Why do I see "Task history could not be saved" but analysis still works?  
A: This is expected behavior! Database failures don't break core functionality.

Q: Can I see my data in the application UI?  
A: Not in this phase - viewing history in the UI would be a future enhancement.

Q: Is my API key secure?  
A: For workshops, yes (free tier, personal projects). For production, no (need backend proxy).

Q: Can I delete test data?  
A: Yes! Go to Table Editor, select rows, click "Delete selected rows".

Q: How much data can I store?  
A: Free tier: 50,000 rows and 500MB - more than enough for workshops!

---

**Setup Complete!** 🎉

Your Task Prioritizer now automatically logs all submissions to Supabase. Try submitting a few tasks and explore your data in the Supabase dashboard!


