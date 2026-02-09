-- Run this SQL in your Supabase SQL Editor to add the is_public column to the businesses table
-- This allows business owners to toggle their business visibility (public/private)

-- Add is_public column to businesses table (defaults to TRUE so all existing businesses remain visible)
ALTER TABLE public.businesses
ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT TRUE;

-- Update all existing businesses to be public by default
UPDATE public.businesses
SET is_public = TRUE
WHERE is_public IS NULL;
