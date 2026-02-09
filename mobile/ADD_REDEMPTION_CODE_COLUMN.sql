-- Add redemption_code column to businesses table
-- This allows business owners to set a unique code that customers must enter to redeem rewards

ALTER TABLE businesses
ADD COLUMN IF NOT EXISTS redemption_code TEXT DEFAULT NULL;

-- Add an index for faster lookups (optional, but good for verification)
CREATE INDEX IF NOT EXISTS idx_businesses_redemption_code ON businesses(redemption_code) WHERE redemption_code IS NOT NULL;
