-- =====================================================
-- COMPLETE FIX: Add Missing Indexes + Fix RLS Policies
-- This will fix both the performance issues AND the RLS error
-- Run this in your Supabase SQL Editor
-- =====================================================

-- =====================================================
-- PART 1: CREATE MISSING INDEXES
-- =====================================================
-- These indexes are CRITICAL for RLS policy performance
-- Without them, auth.uid() lookups can fail or be very slow

-- Businesses table indexes
CREATE INDEX IF NOT EXISTS idx_businesses_owner_id ON public.businesses(owner_id);

-- Opening hours indexes
CREATE INDEX IF NOT EXISTS idx_opening_hours_business_id ON public.opening_hours(business_id);

-- Staff indexes
CREATE INDEX IF NOT EXISTS idx_staff_business_id ON public.staff(business_id);

-- Loyalty rules indexes
CREATE INDEX IF NOT EXISTS idx_loyalty_rules_business_id ON public.loyalty_rules(business_id);

-- Loyalty cards indexes
CREATE INDEX IF NOT EXISTS idx_loyalty_cards_customer_id ON public.loyalty_cards(customer_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_cards_business_id ON public.loyalty_cards(business_id);

-- Rewards indexes
CREATE INDEX IF NOT EXISTS idx_rewards_loyalty_card_id ON public.rewards(loyalty_card_id);
CREATE INDEX IF NOT EXISTS idx_rewards_loyalty_rule_id ON public.rewards(loyalty_rule_id);

-- Check-ins indexes
CREATE INDEX IF NOT EXISTS idx_check_ins_customer_id ON public.check_ins(customer_id);
CREATE INDEX IF NOT EXISTS idx_check_ins_business_id ON public.check_ins(business_id);
CREATE INDEX IF NOT EXISTS idx_check_ins_staff_id ON public.check_ins(staff_id);

-- Offers indexes
CREATE INDEX IF NOT EXISTS idx_offers_business_id ON public.offers(business_id);

-- Offer recipients indexes
CREATE INDEX IF NOT EXISTS idx_offer_recipients_offer_id ON public.offer_recipients(offer_id);
CREATE INDEX IF NOT EXISTS idx_offer_recipients_customer_id ON public.offer_recipients(customer_id);

-- Customer notes indexes
CREATE INDEX IF NOT EXISTS idx_customer_notes_business_id ON public.customer_notes(business_id);
CREATE INDEX IF NOT EXISTS idx_customer_notes_customer_id ON public.customer_notes(customer_id);

-- =====================================================
-- PART 2: FIX RLS POLICIES
-- =====================================================
-- Remove all old conflicting policies and create fresh ones

-- Businesses policies
DROP POLICY IF EXISTS "Businesses are viewable by everyone" ON public.businesses;
DROP POLICY IF EXISTS "Owners can insert their business" ON public.businesses;
DROP POLICY IF EXISTS "Owners can update their business" ON public.businesses;
DROP POLICY IF EXISTS "Owners can delete their business" ON public.businesses;
DROP POLICY IF EXISTS "Users can insert own business" ON public.businesses;
DROP POLICY IF EXISTS "Users can view own business" ON public.businesses;
DROP POLICY IF EXISTS "Users can update own business" ON public.businesses;

CREATE POLICY "businesses_select_policy" ON public.businesses
  FOR SELECT USING (true);

CREATE POLICY "businesses_insert_policy" ON public.businesses
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "businesses_update_policy" ON public.businesses
  FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "businesses_delete_policy" ON public.businesses
  FOR DELETE USING (auth.uid() = owner_id);

-- Opening hours policies
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

-- Staff policies
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

-- =====================================================
-- VERIFY THE FIX
-- =====================================================
-- This should return all the indexes we just created
SELECT
  schemaname,
  tablename,
  indexname
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- This should return all the new policies we just created
SELECT
  schemaname,
  tablename,
  policyname,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('businesses', 'opening_hours', 'staff')
ORDER BY tablename, policyname;
