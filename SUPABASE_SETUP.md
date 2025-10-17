# Supabase Setup Guide - Task Prioritizer

**Quick Setup Time**: ~10 minutes  
**Status**: Ready to test Phase 1 implementation

---

## Current Implementation Status ✅

The code is already integrated and ready to log tasks! Here's what's been implemented:

- ✅ **Phase 1**: Dependencies installed, `.env.example` created
- ✅ **Phase 3**: Supabase client integration with fire-and-forget logging
- ✅ **Phase 4**: Error handling with warning banners
- ✅ **Phase 5**: Graceful degradation when credentials are missing

**What you need**: Just the Supabase setup (Phase 2) to make it work!

---

## Step-by-Step Supabase Setup

### Step 1: Create Supabase Account & Project (5 min)

1. **Visit Supabase**
   ```
   https://supabase.com
   ```

2. **Sign Up / Sign In**
   - Click "Start your project"
   - Use GitHub, Google, or email
   - Verify your email if required

3. **Create a New Project**
   - Click "+ New Project"
   - **Organization**: Create new or select existing
   - **Project Name**: `task-prioritizer-demo` (or any name you like)
   - **Database Password**: Click "Generate" and **SAVE IT SOMEWHERE SAFE**
   - **Region**: Select closest to you (e.g., `US East (North Virginia)`)
   - **Pricing Plan**: Free (perfect for this demo)
   - Click "Create new project"
   - ⏳ Wait ~2 minutes for project initialization

4. **Get Your Credentials**
   - Once ready, click **Settings** (gear icon) in the left sidebar
   - Click **API** section
   - You'll need two values:
     - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
     - **anon public key**: Long JWT token starting with `eyJ...`
   - Keep this tab open - you'll need these values next!

---

### Step 2: Configure Environment Variables (1 min)

1. **Create your `.env` file**
   ```bash
   cd /Users/maryia.yermakovich/Projects/task-prio-ai-workshop
   cp .env.example .env
   ```

2. **Edit `.env` file** with your actual credentials:
   ```bash
   # Add your existing Gemini API key (if you have one)
   VITE_GEMINI_API_KEY=your_actual_gemini_key_here
   
   # Add your Supabase credentials from Step 1
   VITE_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
   VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. **Restart the dev server**
   ```bash
   # Stop the current server (Ctrl+C in the terminal)
   npm run dev
   ```

---

### Step 3: Create Database Table (2 min)

1. **Open SQL Editor** in your Supabase dashboard
   - Click **SQL Editor** in the left sidebar
   - Click **+ New query**

2. **Copy and paste this SQL** (creates the `task_submissions` table):

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

-- Add table comment for documentation
COMMENT ON TABLE task_submissions IS 
  'Stores task analysis submissions with AI-generated prioritization insights';
```

3. **Execute the query**
   - Click **Run** (or press `Ctrl/Cmd + Enter`)
   - You should see: ✅ "Success. No rows returned"

4. **Verify table was created**
   - Click **Table Editor** in the left sidebar
   - You should see `task_submissions` in the table list
   - Click on it to see the empty table with 7 columns

---

### Step 4: Configure Row Level Security (2 min)

Supabase blocks all database access by default. We need to allow inserts for this demo.

1. **Open SQL Editor again** (SQL Editor → + New query)

2. **Copy and paste this SQL** (creates RLS policies):

```sql
-- Enable RLS on the table
ALTER TABLE task_submissions ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous inserts (demo/workshop use only)
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
```

3. **Execute the query**
   - Click **Run**
   - You should see: ✅ "Success. No rows returned"

4. **Verify policies were created**
   - Click **Authentication** → **Policies** in the sidebar
   - You should see "Allow anonymous inserts" policy for `task_submissions`

**⚠️ Security Note**: This permissive policy is fine for demos. Production apps should use authenticated users with strict RLS policies.

---

## Testing Your Setup 🧪

### Test 1: Check Environment Variables

1. **Open your browser** to `http://localhost:5173`
2. **Open Developer Console** (F12 or Right-click → Inspect)
3. **Type in the Console**:
   ```javascript
   console.log('Supabase URL:', import.meta.env.VITE_SUPABASE_URL);
   console.log('Has Anon Key:', !!import.meta.env.VITE_SUPABASE_ANON_KEY);
   ```
4. **Expected output**:
   ```
   Supabase URL: https://xxxxxxxxxxxxx.supabase.co
   Has Anon Key: true
   ```

### Test 2: Submit a Task

1. **In the application**, enter this task:
   ```
   Test Supabase database logging feature
   ```

2. **Click "Analyze Task"**

3. **Watch the Console** for these messages:
   ```
   ✅ Supabase client initialized successfully
   ✅ Task logged to database successfully: [...]
   ```

4. **Check Supabase Dashboard**:
   - Go to **Table Editor** → `task_submissions`
   - You should see **1 new row** with:
     - `task_text`: "Test Supabase database logging feature"
     - `priority`: HIGH/MEDIUM/LOW (from AI)
     - `categories`: Array of tags
     - `complexity`: HIGH/MEDIUM/LOW
     - `suggested_order`: AI explanation
     - `created_at`: Current timestamp
     - `id`: Auto-generated UUID

**✅ Success!** Your task was logged to Supabase!

### Test 3: Error Handling (Optional)

Test that the app works even when database fails:

1. **Stop dev server** (Ctrl+C)
2. **Edit `.env`** - change URL to something invalid:
   ```bash
   VITE_SUPABASE_URL=https://invalid-url.supabase.co
   ```
3. **Restart dev server**: `npm run dev`
4. **Submit a task**
5. **Expected behavior**:
   - ✅ AI analysis still displays normally
   - ⚠️ Warning banner appears: "Note: Task history could not be saved at this time"
   - Console shows: "❌ Database logging failed: ..."
   - App continues working!

6. **Restore correct URL** in `.env` and restart

---

## Viewing Your Data

### In Supabase Dashboard

**Table Editor** (easiest way):
- Click **Table Editor** → `task_submissions`
- See all your logged tasks in a nice UI
- Filter, sort, and export data

**SQL Editor** (for queries):
```sql
-- View all submissions
SELECT * FROM task_submissions ORDER BY created_at DESC;

-- Count by priority
SELECT priority, COUNT(*) FROM task_submissions GROUP BY priority;

-- Recent high-priority tasks
SELECT task_text, suggested_order, created_at
FROM task_submissions
WHERE priority = 'HIGH'
  AND created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;

-- Find tasks with specific category
SELECT task_text, categories, priority
FROM task_submissions
WHERE 'SECURITY' = ANY(categories);
```

---

## Troubleshooting 🔧

### Issue: "Supabase credentials not configured"

**Console shows**: `⚠️ Supabase credentials not configured - database logging disabled`

**Solutions**:
1. Check `.env` file has both `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`
2. Verify no extra spaces or quotes around values
3. Restart dev server after editing `.env`
4. Clear browser cache and reload

### Issue: "Permission denied" or "Row Level Security"

**Console shows**: `Permission denied (RLS policy)`

**Solutions**:
1. Go to Supabase → Authentication → Policies
2. Verify "Allow anonymous inserts" policy exists for `task_submissions`
3. Re-run the RLS SQL from Step 4 if needed

### Issue: No data appears in Supabase Table Editor

**Console says "success" but table is empty**

**Solutions**:
1. Refresh the Table Editor page
2. Verify you're looking at the correct project
3. Run SQL query: `SELECT * FROM task_submissions;`
4. Check the table name is exactly `task_submissions` (lowercase, underscore)

### Issue: "Invalid API key" or 401 errors

**Console shows authentication failure**

**Solutions**:
1. Go to Supabase → Settings → API
2. Copy the **"anon public"** key (NOT the "service_role" key)
3. Paste in `.env` with no extra spaces
4. Restart dev server

---

## What's Working Now ✨

After setup, you have:

1. **✅ Transparent Logging**: Every AI analysis automatically saves to database
2. **✅ Zero UI Impact**: Logging happens in the background, never blocks user
3. **✅ Graceful Errors**: Database failures show subtle warning, app keeps working
4. **✅ Secure Config**: Credentials in `.env` (not committed to git)
5. **✅ Data Verification**: View all logged tasks in Supabase dashboard

---

## Next Steps 🚀

**For Workshop/Demo**:
- Submit various tasks to build up data
- Try SQL queries to analyze patterns
- Show the warning banner (temporarily break database connection)
- Export data as CSV from Table Editor

**For Production** (future):
- Add user authentication
- Implement backend API proxy
- Restrict RLS policies to authenticated users
- Add rate limiting
- Set up monitoring and alerts

---

## Quick Reference

**Current Dev Server**: `http://localhost:5173`

**Supabase Dashboard**: `https://supabase.com/dashboard`

**Environment Variables** (in `.env`):
```bash
VITE_GEMINI_API_KEY=your_gemini_key
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

**Key Files**:
- Configuration: `.env` (your credentials - not committed)
- Template: `.env.example` (documentation - committed)
- Implementation: `index.html` (all code in one file)
- Detailed Guide: `specs/003-supabase-logging/quickstart.md`

---

## Support

Need help? Check:
1. Browser console for detailed error messages
2. Supabase project logs: Settings → Logs
3. `specs/003-supabase-logging/quickstart.md` for more details
4. `specs/003-supabase-logging/contracts/` for API examples

---

**Setup Complete!** 🎉

Your Task Prioritizer now logs every analysis to Supabase. Try it out!

