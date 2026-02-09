-- ================================================================
-- RLS POLICIES TO FIX BUSINESS CREATION
-- Run this SQL in your Supabase SQL Editor
-- ================================================================

-- First, make sure RLS is enabled on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opening_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offer_recipients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_notes ENABLE ROW LEVEL SECURITY;

-- ================================================================
-- PROFILES TABLE POLICIES
-- ================================================================

-- Drop existing policies first (ignore errors if they don't exist)
DROP POLICY IF EXISTS "Profiles: owner select" ON public.profiles;
DROP POLICY IF EXISTS "Profiles: owner update" ON public.profiles;
DROP POLICY IF EXISTS "Profiles: owner insert" ON public.profiles;
DROP POLICY IF EXISTS "profiles_select_policy" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert_policy" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_policy" ON public.profiles;

-- Allow users to read their own profile
CREATE POLICY "profiles_select_policy" ON public.profiles
  FOR SELECT TO authenticated
  USING (id = auth.uid());

-- Allow users to create their own profile (critical for signup!)
CREATE POLICY "profiles_insert_policy" ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid());

-- Allow users to update their own profile
CREATE POLICY "profiles_update_policy" ON public.profiles
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- ================================================================
-- BUSINESSES TABLE POLICIES
-- ================================================================

-- Drop existing policies first
DROP POLICY IF EXISTS "Businesses: owner access" ON public.businesses;
DROP POLICY IF EXISTS "businesses_select_policy" ON public.businesses;
DROP POLICY IF EXISTS "businesses_insert_policy" ON public.businesses;
DROP POLICY IF EXISTS "businesses_update_policy" ON public.businesses;
DROP POLICY IF EXISTS "businesses_delete_policy" ON public.businesses;
DROP POLICY IF EXISTS "businesses_public_select" ON public.businesses;

-- Allow anyone authenticated to view businesses (for customer browsing)
CREATE POLICY "businesses_public_select" ON public.businesses
  FOR SELECT TO authenticated
  USING (true);

-- Allow users to create businesses with themselves as owner
CREATE POLICY "businesses_insert_policy" ON public.businesses
  FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid());

-- Allow owners to update their own businesses
CREATE POLICY "businesses_update_policy" ON public.businesses
  FOR UPDATE TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

-- Allow owners to delete their own businesses
CREATE POLICY "businesses_delete_policy" ON public.businesses
  FOR DELETE TO authenticated
  USING (owner_id = auth.uid());

-- ================================================================
-- OPENING HOURS TABLE POLICIES
-- ================================================================

DROP POLICY IF EXISTS "opening_hours_select_policy" ON public.opening_hours;
DROP POLICY IF EXISTS "opening_hours_insert_policy" ON public.opening_hours;
DROP POLICY IF EXISTS "opening_hours_update_policy" ON public.opening_hours;
DROP POLICY IF EXISTS "opening_hours_delete_policy" ON public.opening_hours;

-- Anyone can view opening hours
CREATE POLICY "opening_hours_select_policy" ON public.opening_hours
  FOR SELECT TO authenticated
  USING (true);

-- Business owners can insert opening hours for their business
CREATE POLICY "opening_hours_insert_policy" ON public.opening_hours
  FOR INSERT TO authenticated
  WITH CHECK (
    business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
  );

-- Business owners can update opening hours for their business
CREATE POLICY "opening_hours_update_policy" ON public.opening_hours
  FOR UPDATE TO authenticated
  USING (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()))
  WITH CHECK (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

-- Business owners can delete opening hours for their business
CREATE POLICY "opening_hours_delete_policy" ON public.opening_hours
  FOR DELETE TO authenticated
  USING (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

-- ================================================================
-- STAFF TABLE POLICIES
-- ================================================================

DROP POLICY IF EXISTS "staff_select_policy" ON public.staff;
DROP POLICY IF EXISTS "staff_insert_policy" ON public.staff;
DROP POLICY IF EXISTS "staff_update_policy" ON public.staff;
DROP POLICY IF EXISTS "staff_delete_policy" ON public.staff;

-- Anyone can view staff
CREATE POLICY "staff_select_policy" ON public.staff
  FOR SELECT TO authenticated
  USING (true);

-- Business owners can manage staff for their business
CREATE POLICY "staff_insert_policy" ON public.staff
  FOR INSERT TO authenticated
  WITH CHECK (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

CREATE POLICY "staff_update_policy" ON public.staff
  FOR UPDATE TO authenticated
  USING (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()))
  WITH CHECK (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

CREATE POLICY "staff_delete_policy" ON public.staff
  FOR DELETE TO authenticated
  USING (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

-- ================================================================
-- LOYALTY RULES TABLE POLICIES
-- ================================================================

DROP POLICY IF EXISTS "Loyalty rules: business access" ON public.loyalty_rules;
DROP POLICY IF EXISTS "loyalty_rules_select_policy" ON public.loyalty_rules;
DROP POLICY IF EXISTS "loyalty_rules_insert_policy" ON public.loyalty_rules;
DROP POLICY IF EXISTS "loyalty_rules_update_policy" ON public.loyalty_rules;
DROP POLICY IF EXISTS "loyalty_rules_delete_policy" ON public.loyalty_rules;

-- Anyone can view loyalty rules
CREATE POLICY "loyalty_rules_select_policy" ON public.loyalty_rules
  FOR SELECT TO authenticated
  USING (true);

-- Business owners can manage loyalty rules
CREATE POLICY "loyalty_rules_insert_policy" ON public.loyalty_rules
  FOR INSERT TO authenticated
  WITH CHECK (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

CREATE POLICY "loyalty_rules_update_policy" ON public.loyalty_rules
  FOR UPDATE TO authenticated
  USING (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()))
  WITH CHECK (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

CREATE POLICY "loyalty_rules_delete_policy" ON public.loyalty_rules
  FOR DELETE TO authenticated
  USING (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

-- ================================================================
-- LOYALTY CARDS TABLE POLICIES
-- ================================================================

DROP POLICY IF EXISTS "Loyalty cards: owner or customer" ON public.loyalty_cards;
DROP POLICY IF EXISTS "loyalty_cards_select_policy" ON public.loyalty_cards;
DROP POLICY IF EXISTS "loyalty_cards_insert_policy" ON public.loyalty_cards;
DROP POLICY IF EXISTS "loyalty_cards_update_policy" ON public.loyalty_cards;

-- Customers can view their own cards, business owners can view cards for their business
CREATE POLICY "loyalty_cards_select_policy" ON public.loyalty_cards
  FOR SELECT TO authenticated
  USING (
    customer_id = auth.uid()
    OR business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
  );

-- Anyone can create a loyalty card (when checking in)
CREATE POLICY "loyalty_cards_insert_policy" ON public.loyalty_cards
  FOR INSERT TO authenticated
  WITH CHECK (
    customer_id = auth.uid()
    OR business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
  );

-- Customers or business owners can update cards
CREATE POLICY "loyalty_cards_update_policy" ON public.loyalty_cards
  FOR UPDATE TO authenticated
  USING (
    customer_id = auth.uid()
    OR business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
  )
  WITH CHECK (
    customer_id = auth.uid()
    OR business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
  );

-- ================================================================
-- CHECK-INS TABLE POLICIES
-- ================================================================

DROP POLICY IF EXISTS "Checkins: customer insert" ON public.check_ins;
DROP POLICY IF EXISTS "Checkins: business select" ON public.check_ins;
DROP POLICY IF EXISTS "check_ins_select_policy" ON public.check_ins;
DROP POLICY IF EXISTS "check_ins_insert_policy" ON public.check_ins;

-- Customers can view their check-ins, business owners can view check-ins for their business
CREATE POLICY "check_ins_select_policy" ON public.check_ins
  FOR SELECT TO authenticated
  USING (
    customer_id = auth.uid()
    OR business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
  );

-- Customers can create check-ins, or business owners can create check-ins for customers
CREATE POLICY "check_ins_insert_policy" ON public.check_ins
  FOR INSERT TO authenticated
  WITH CHECK (
    customer_id = auth.uid()
    OR business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
  );

-- ================================================================
-- REWARDS TABLE POLICIES
-- ================================================================

DROP POLICY IF EXISTS "rewards_select_policy" ON public.rewards;
DROP POLICY IF EXISTS "rewards_insert_policy" ON public.rewards;
DROP POLICY IF EXISTS "rewards_update_policy" ON public.rewards;

-- Customers can view their rewards (via loyalty card), business owners can view rewards for their business
CREATE POLICY "rewards_select_policy" ON public.rewards
  FOR SELECT TO authenticated
  USING (
    loyalty_card_id IN (
      SELECT id FROM public.loyalty_cards
      WHERE customer_id = auth.uid()
      OR business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
    )
  );

-- Allow inserting rewards when checking in
CREATE POLICY "rewards_insert_policy" ON public.rewards
  FOR INSERT TO authenticated
  WITH CHECK (
    loyalty_card_id IN (
      SELECT id FROM public.loyalty_cards
      WHERE customer_id = auth.uid()
      OR business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
    )
  );

-- Allow updating rewards (for redemption)
CREATE POLICY "rewards_update_policy" ON public.rewards
  FOR UPDATE TO authenticated
  USING (
    loyalty_card_id IN (
      SELECT id FROM public.loyalty_cards
      WHERE customer_id = auth.uid()
      OR business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
    )
  )
  WITH CHECK (
    loyalty_card_id IN (
      SELECT id FROM public.loyalty_cards
      WHERE customer_id = auth.uid()
      OR business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid())
    )
  );

-- ================================================================
-- OFFERS TABLE POLICIES
-- ================================================================

DROP POLICY IF EXISTS "Offers: business access" ON public.offers;
DROP POLICY IF EXISTS "offers_select_policy" ON public.offers;
DROP POLICY IF EXISTS "offers_insert_policy" ON public.offers;
DROP POLICY IF EXISTS "offers_update_policy" ON public.offers;
DROP POLICY IF EXISTS "offers_delete_policy" ON public.offers;

-- Anyone can view offers
CREATE POLICY "offers_select_policy" ON public.offers
  FOR SELECT TO authenticated
  USING (true);

-- Business owners can manage offers
CREATE POLICY "offers_insert_policy" ON public.offers
  FOR INSERT TO authenticated
  WITH CHECK (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

CREATE POLICY "offers_update_policy" ON public.offers
  FOR UPDATE TO authenticated
  USING (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()))
  WITH CHECK (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

CREATE POLICY "offers_delete_policy" ON public.offers
  FOR DELETE TO authenticated
  USING (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

-- ================================================================
-- OFFER RECIPIENTS TABLE POLICIES
-- ================================================================

DROP POLICY IF EXISTS "offer_recipients_select_policy" ON public.offer_recipients;
DROP POLICY IF EXISTS "offer_recipients_insert_policy" ON public.offer_recipients;

-- Customers can view offers sent to them, business owners can view recipients
CREATE POLICY "offer_recipients_select_policy" ON public.offer_recipients
  FOR SELECT TO authenticated
  USING (
    customer_id = auth.uid()
    OR offer_id IN (SELECT id FROM public.offers WHERE business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()))
  );

-- Business owners can send offers to customers
CREATE POLICY "offer_recipients_insert_policy" ON public.offer_recipients
  FOR INSERT TO authenticated
  WITH CHECK (
    offer_id IN (SELECT id FROM public.offers WHERE business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()))
  );

-- ================================================================
-- CUSTOMER NOTES TABLE POLICIES
-- ================================================================

DROP POLICY IF EXISTS "customer_notes_select_policy" ON public.customer_notes;
DROP POLICY IF EXISTS "customer_notes_insert_policy" ON public.customer_notes;
DROP POLICY IF EXISTS "customer_notes_update_policy" ON public.customer_notes;

-- Business owners can manage customer notes for their business
CREATE POLICY "customer_notes_select_policy" ON public.customer_notes
  FOR SELECT TO authenticated
  USING (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

CREATE POLICY "customer_notes_insert_policy" ON public.customer_notes
  FOR INSERT TO authenticated
  WITH CHECK (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

CREATE POLICY "customer_notes_update_policy" ON public.customer_notes
  FOR UPDATE TO authenticated
  USING (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()))
  WITH CHECK (business_id IN (SELECT id FROM public.businesses WHERE owner_id = auth.uid()));

-- ================================================================
-- DONE! All RLS policies have been set up.
-- ================================================================
