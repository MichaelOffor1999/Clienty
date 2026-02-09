-- ClipCard Database Schema
-- Run this SQL in your Supabase SQL Editor (Dashboard > SQL Editor > New Query)

-- =====================================================
-- STEP 1: DROP TRIGGERS FIRST (before dropping tables/functions)
-- =====================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS update_businesses_updated_at ON public.businesses;
DROP TRIGGER IF EXISTS update_loyalty_cards_updated_at ON public.loyalty_cards;
DROP TRIGGER IF EXISTS update_customer_notes_updated_at ON public.customer_notes;

-- =====================================================
-- STEP 2: DROP FUNCTIONS
-- =====================================================
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

-- =====================================================
-- STEP 3: DROP EXISTING TABLES (in correct order due to foreign keys)
-- =====================================================
DROP TABLE IF EXISTS public.customer_notes;
DROP TABLE IF EXISTS public.offer_recipients;
DROP TABLE IF EXISTS public.offers;
DROP TABLE IF EXISTS public.check_ins;
DROP TABLE IF EXISTS public.rewards;
DROP TABLE IF EXISTS public.loyalty_cards;
DROP TABLE IF EXISTS public.loyalty_rules;
DROP TABLE IF EXISTS public.staff;
DROP TABLE IF EXISTS public.opening_hours;
DROP TABLE IF EXISTS public.businesses;
DROP TABLE IF EXISTS public.profiles;

-- =====================================================
-- STEP 4: CREATE TABLES
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  avatar TEXT,
  role TEXT NOT NULL CHECK (role IN ('customer', 'owner')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Businesses table
CREATE TABLE public.businesses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  phone TEXT,
  images TEXT[] DEFAULT '{}',
  rating NUMERIC(2,1) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  is_public BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Opening hours table
CREATE TABLE public.opening_hours (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  day TEXT NOT NULL,
  open_time TEXT,
  close_time TEXT,
  is_closed BOOLEAN DEFAULT FALSE
);

-- Staff table
CREATE TABLE public.staff (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  avatar TEXT,
  specialty TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Loyalty rules table
CREATE TABLE public.loyalty_rules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  visits_required INTEGER NOT NULL,
  reward_type TEXT NOT NULL CHECK (reward_type IN ('percentage', 'free', 'custom')),
  reward_value INTEGER DEFAULT 0,
  reward_description TEXT NOT NULL,
  eligible_services TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Loyalty cards table (customer's loyalty progress at a business)
CREATE TABLE public.loyalty_cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  current_visits INTEGER DEFAULT 0,
  total_visits INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(customer_id, business_id)
);

-- Rewards table (earned rewards)
CREATE TABLE public.rewards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  loyalty_card_id UUID NOT NULL REFERENCES public.loyalty_cards(id) ON DELETE CASCADE,
  loyalty_rule_id UUID NOT NULL REFERENCES public.loyalty_rules(id) ON DELETE CASCADE,
  is_redeemed BOOLEAN DEFAULT FALSE,
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  redeemed_at TIMESTAMPTZ
);

-- Check-ins table
CREATE TABLE public.check_ins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  staff_id UUID REFERENCES public.staff(id) ON DELETE SET NULL,
  service TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Offers table
CREATE TABLE public.offers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  discount_type TEXT CHECK (discount_type IS NULL OR discount_type IN ('percentage', 'fixed', 'free')),
  discount_value INTEGER DEFAULT 0,
  valid_days INTEGER DEFAULT 7,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Offer recipients table
CREATE TABLE public.offer_recipients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  offer_id UUID NOT NULL REFERENCES public.offers(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  email_sent BOOLEAN DEFAULT FALSE
);

-- Customer notes table (business owner's notes about customers)
CREATE TABLE public.customer_notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  notes TEXT,
  preferences TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(business_id, customer_id)
);

-- =====================================================
-- STEP 5: ENABLE ROW LEVEL SECURITY
-- =====================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opening_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offer_recipients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_notes ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 6: RLS POLICIES
-- =====================================================

-- Profiles: Users can read all profiles, but only update their own
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Businesses: Everyone can view, only owners can modify their own
CREATE POLICY "Businesses are viewable by everyone" ON public.businesses
  FOR SELECT USING (true);

CREATE POLICY "Owners can insert their business" ON public.businesses
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can update their business" ON public.businesses
  FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Owners can delete their business" ON public.businesses
  FOR DELETE USING (auth.uid() = owner_id);

-- Opening hours: Everyone can view, only business owners can modify
CREATE POLICY "Opening hours are viewable by everyone" ON public.opening_hours
  FOR SELECT USING (true);

CREATE POLICY "Business owners can manage opening hours" ON public.opening_hours
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = opening_hours.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

-- Staff: Everyone can view, only business owners can modify
CREATE POLICY "Staff are viewable by everyone" ON public.staff
  FOR SELECT USING (true);

CREATE POLICY "Business owners can manage staff" ON public.staff
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = staff.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

-- Loyalty rules: Everyone can view active rules, only business owners can modify
CREATE POLICY "Active loyalty rules are viewable by everyone" ON public.loyalty_rules
  FOR SELECT USING (true);

CREATE POLICY "Business owners can manage loyalty rules" ON public.loyalty_rules
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = loyalty_rules.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

-- Loyalty cards: Customers can view their own, business owners can view their business's cards
CREATE POLICY "Customers can view own loyalty cards" ON public.loyalty_cards
  FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "Business owners can view their business loyalty cards" ON public.loyalty_cards
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = loyalty_cards.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

CREATE POLICY "Loyalty cards can be created for customers" ON public.loyalty_cards
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Loyalty cards can be updated" ON public.loyalty_cards
  FOR UPDATE USING (true);

-- Rewards: Customers can view their own, business owners can view/modify
CREATE POLICY "Customers can view own rewards" ON public.rewards
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.loyalty_cards
      WHERE loyalty_cards.id = rewards.loyalty_card_id
      AND loyalty_cards.customer_id = auth.uid()
    )
  );

CREATE POLICY "Business owners can manage rewards" ON public.rewards
  FOR ALL USING (true);

-- Check-ins: Customers can view their own, business owners can view/create for their business
CREATE POLICY "Customers can view own check-ins" ON public.check_ins
  FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "Business owners can view their business check-ins" ON public.check_ins
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = check_ins.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

CREATE POLICY "Check-ins can be created" ON public.check_ins
  FOR INSERT WITH CHECK (true);

-- Offers: Everyone can view, only business owners can modify
CREATE POLICY "Offers are viewable by everyone" ON public.offers
  FOR SELECT USING (true);

CREATE POLICY "Business owners can manage offers" ON public.offers
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = offers.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

-- Offer recipients: Customers can view their own, business owners can manage
CREATE POLICY "Customers can view own offer recipients" ON public.offer_recipients
  FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "Business owners can manage offer recipients" ON public.offer_recipients
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.offers
      JOIN public.businesses ON businesses.id = offers.business_id
      WHERE offers.id = offer_recipients.offer_id
      AND businesses.owner_id = auth.uid()
    )
  );

-- Customer notes: Only business owners can view/manage
CREATE POLICY "Business owners can manage customer notes" ON public.customer_notes
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = customer_notes.business_id
      AND businesses.owner_id = auth.uid()
    )
  );

-- =====================================================
-- STEP 7: FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_businesses_updated_at
  BEFORE UPDATE ON public.businesses
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_loyalty_cards_updated_at
  BEFORE UPDATE ON public.loyalty_cards
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_customer_notes_updated_at
  BEFORE UPDATE ON public.customer_notes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- SUCCESS!
-- =====================================================
SELECT 'ClipCard database schema created successfully!' as message;
