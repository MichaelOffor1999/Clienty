-- =====================================================
-- FIX RLS POLICIES FOR BUSINESSES TABLE
-- Run this in your Supabase SQL Editor
-- =====================================================

-- First, drop ALL existing policies on businesses table
DROP POLICY IF EXISTS "Businesses are viewable by everyone" ON public.businesses;
DROP POLICY IF EXISTS "Owners can insert their business" ON public.businesses;
DROP POLICY IF EXISTS "Owners can update their business" ON public.businesses;
DROP POLICY IF EXISTS "Owners can delete their business" ON public.businesses;
DROP POLICY IF EXISTS "Users can insert own business" ON public.businesses;
DROP POLICY IF EXISTS "Users can view own business" ON public.businesses;
DROP POLICY IF EXISTS "Users can update own business" ON public.businesses;

-- Now create fresh policies
CREATE POLICY "businesses_select_policy" ON public.businesses
  FOR SELECT USING (true);

CREATE POLICY "businesses_insert_policy" ON public.businesses
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "businesses_update_policy" ON public.businesses
  FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "businesses_delete_policy" ON public.businesses
  FOR DELETE USING (auth.uid() = owner_id);

-- Fix opening_hours policies
DROP POLICY IF EXISTS "Opening hours are viewable by everyone" ON public.opening_hours;
DROP POLICY IF EXISTS "Business owners can manage opening hours" ON public.opening_hours;
DROP POLICY IF EXISTS "Business owners can insert opening hours" ON public.opening_hours;

CREATE POLICY "opening_hours_select_policy" ON public.opening_hours
  FOR SELECT USING (true);

CREATE POLICY "opening_hours_insert_policy" ON public.opening_hours
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = opening_hours.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

CREATE POLICY "opening_hours_update_policy" ON public.opening_hours
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = opening_hours.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

CREATE POLICY "opening_hours_delete_policy" ON public.opening_hours
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = opening_hours.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

-- Fix staff policies
DROP POLICY IF EXISTS "Staff are viewable by everyone" ON public.staff;
DROP POLICY IF EXISTS "Business owners can manage staff" ON public.staff;
DROP POLICY IF EXISTS "Business owners can insert staff" ON public.staff;

CREATE POLICY "staff_select_policy" ON public.staff
  FOR SELECT USING (true);

CREATE POLICY "staff_insert_policy" ON public.staff
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = staff.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

CREATE POLICY "staff_update_policy" ON public.staff
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = staff.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

CREATE POLICY "staff_delete_policy" ON public.staff
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = staff.business_id
      AND businesses.owner_id = auth.uid()
    )
  );
