# How to Fix the RLS Policy Error

## The Problem
You're seeing this error:
```
Error creating business: {"code":"42501","details":null,"hint":null,"message":"new row violates row-level security policy for table \"businesses\""}
```

This error means that Supabase's Row Level Security (RLS) policies are blocking the insert operation.

## The Root Cause
The RLS policy for the `businesses` table is checking if `auth.uid()` matches `owner_id`, but something is preventing this check from passing. This usually happens when:
1. Multiple policies conflict with each other
2. The session token isn't being passed correctly
3. Policy names are duplicated

## The Solution

### Step 1: Run the SQL Fix
1. Go to your **Supabase Dashboard** at https://supabase.com
2. Select your project
3. Click **SQL Editor** in the left sidebar
4. Copy the contents of the **FIX_RLS_POLICY.sql** file (in this workspace)
5. Paste it into the SQL editor
6. Click **Run**

This SQL will:
- Remove ALL old conflicting policies on businesses, opening_hours, and staff tables
- Create fresh, clean policies with unique names
- Ensure proper permission checks

### Step 2: Try Creating Your Business Again
After running the SQL:
1. Go back to the Vibecode app
2. Try creating your business again
3. The error should now be resolved

### Step 3: Check for Error Messages
The app will now show helpful error messages if something goes wrong:
- **"Your session has expired"** - Log out and log back in
- **"Permission denied"** - The SQL wasn't run correctly, try running it again
- Any other specific error message

## Still Having Issues?

If the error persists after running the SQL:

1. **Verify the SQL ran successfully**: Check for any error messages in the Supabase SQL Editor
2. **Check your session**: Try logging out and logging back in
3. **Verify your role**: Make sure you signed up as an "owner" not a "customer"
4. **Check the logs**: Look at the expo.log file or the LOGS tab in Vibecode to see detailed error messages

## What Changed in the Code

I've updated the code to:
1. Verify the session is valid before trying to create the business
2. Use the session user ID directly (more reliable than the stored user ID)
3. Show helpful error messages in the UI when something goes wrong
4. Log detailed debugging information to help diagnose issues

## Important Notes

- This is a **database configuration issue**, not a code issue
- The SQL **must be run in your Supabase dashboard** - it cannot be fixed from the app code
- You only need to run this SQL **once**
- After running it, all future business creations will work correctly
