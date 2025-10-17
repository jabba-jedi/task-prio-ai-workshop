-- ============================================================================
-- Supabase Database Setup for Task Prioritizer
-- ============================================================================
-- Run this SQL in your Supabase SQL Editor
-- Project: briucpivptkqkoxklmcd
-- Instructions: Copy and paste this entire file into Supabase SQL Editor and click "Run"
-- ============================================================================

-- Step 1: Enable UUID extension (for auto-generating unique IDs)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Step 2: Create the task_submissions table
CREATE TABLE IF NOT EXISTS task_submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_text TEXT NOT NULL,
  priority TEXT NOT NULL CHECK (priority IN ('HIGH', 'MEDIUM', 'LOW')),
  categories TEXT[] NOT NULL,
  complexity TEXT NOT NULL CHECK (complexity IN ('HIGH', 'MEDIUM', 'LOW')),
  suggested_order TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Step 3: Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_task_submissions_created_at 
  ON task_submissions(created_at);

CREATE INDEX IF NOT EXISTS idx_task_submissions_priority 
  ON task_submissions(priority);

-- Step 4: Add table comments for documentation
COMMENT ON TABLE task_submissions IS 
  'Stores task analysis submissions with AI-generated prioritization insights';

COMMENT ON COLUMN task_submissions.task_text IS 
  'Original task description exactly as entered by user';

COMMENT ON COLUMN task_submissions.priority IS 
  'AI-determined priority: HIGH, MEDIUM, or LOW';

COMMENT ON COLUMN task_submissions.categories IS 
  'Array of classification tags (e.g., CRITICAL-PATH, USER-FACING, SECURITY)';

COMMENT ON COLUMN task_submissions.complexity IS 
  'AI-assessed effort level: HIGH, MEDIUM, or LOW';

COMMENT ON COLUMN task_submissions.suggested_order IS 
  'AI-generated explanation of when/why to prioritize this task';

COMMENT ON COLUMN task_submissions.created_at IS 
  'Server timestamp when submission was logged';

-- Step 5: Enable Row Level Security (RLS)
ALTER TABLE task_submissions ENABLE ROW LEVEL SECURITY;

-- Step 6: Create RLS policies

-- Policy 1: Allow anonymous users to insert tasks (for demo/workshop)
DROP POLICY IF EXISTS "Allow anonymous inserts" ON task_submissions;
CREATE POLICY "Allow anonymous inserts"
  ON task_submissions
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy 2: Block anonymous reads (optional privacy protection)
-- Note: You can still view data in Supabase dashboard as an authenticated admin
DROP POLICY IF EXISTS "Block anonymous reads" ON task_submissions;
CREATE POLICY "Block anonymous reads"
  ON task_submissions
  FOR SELECT
  TO anon
  USING (false);

-- ============================================================================
-- Setup Complete! ✅
-- ============================================================================
-- 
-- What was created:
-- ✅ task_submissions table with 7 columns
-- ✅ UUID extension for auto-generating IDs
-- ✅ Indexes on created_at and priority for fast queries
-- ✅ CHECK constraints to enforce valid priority/complexity values
-- ✅ RLS policies to allow inserts but block reads from anonymous users
--
-- Next steps:
-- 1. Go to Table Editor in Supabase to see the empty table
-- 2. Open your app at http://localhost:5173
-- 3. Submit a test task
-- 4. Come back to Table Editor and see the logged data!
--
-- ============================================================================

