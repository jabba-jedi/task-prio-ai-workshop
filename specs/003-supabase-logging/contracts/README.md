# Data Contracts: Supabase Database Logging

This directory contains the data contracts for the Supabase database logging feature.

## Files

### database-schema.json

Defines the database table structure for storing task submissions. This includes:

- **Table name**: `task_submissions`
- **Columns**: All fields required to store a complete task analysis
- **Constraints**: Data validation rules (NOT NULL, CHECK constraints for enums)
- **Indexes**: Performance optimization for common query patterns

**Purpose**: This schema ensures data integrity and provides a clear contract for what data is persisted and in what format.

### task-submission-example.json

Provides a concrete example of how a task submission record looks when stored in the database.

**Purpose**: This example helps developers understand the actual data format, including data types, structure, and real-world values.

### supabase-insert.json

Documents the Supabase insert operation contract, including:

- **Request payload**: Fields sent to Supabase for insertion
- **Success response**: What the API returns on successful insert
- **Error responses**: Various failure scenarios with examples
- **Error handling**: How the application handles different error types
- **Code examples**: JavaScript implementation using @supabase/supabase-js

**Purpose**: This contract defines the API interaction pattern, error handling strategy, and implementation guidelines for the database logging operation.

## Usage Notes

### For Implementation

When implementing this feature:

1. Create the `task_submissions` table using the schema defined in `database-schema.json`
2. Ensure the database user has INSERT permissions on this table
3. Map AI analysis results to the corresponding database columns
4. Handle the auto-generated fields (id, created_at) appropriately

### For Testing

When testing this feature:

1. Verify that all columns from the schema are populated
2. Check that enum constraints (priority, complexity) are enforced
3. Confirm that categories array preserves order and individual values
4. Validate that timestamps are in the correct format (ISO 8601 with timezone)

### Data Validation

The database schema includes validation rules that must be respected:

- **Priority**: Must be exactly one of: `HIGH`, `MEDIUM`, `LOW`
- **Complexity**: Must be exactly one of: `HIGH`, `MEDIUM`, `LOW`
- **Categories**: Must be an array (can be empty but not null)
- **Task Text**: Must not be null or empty
- **Suggested Order**: Must not be null or empty

### Environment Variables

The database connection requires two environment variables:

- `VITE_SUPABASE_URL`: The URL of your Supabase project
- `VITE_SUPABASE_ANON_KEY`: The anonymous/public API key for your project

These should be configured in your `.env` file for local development and in your deployment environment.

## Schema Evolution

If the database schema needs to change in future iterations:

1. Document the change with a migration file
2. Update `database-schema.json` to reflect the new structure
3. Update `task-submission-example.json` to show the new format
4. Consider backwards compatibility for existing data

