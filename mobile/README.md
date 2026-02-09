# Clienty - Service Business Loyalty App

A mobile loyalty app for service businesses (salons, barbershops, nail studios, spas, etc.) with two completely separate user experiences.

## Overview

Clienty is a service-business-first loyalty platform where:
- **Customers** enjoy a smooth loyalty experience similar to SQUID
- **Business Owners** have full control over their business with a dedicated dashboard

## User Flows

### Customer Experience
1. Select "I'm a Customer" on onboarding
2. Choose to **Sign In** or **Create Account**
3. Access Customer UI with tabs:
   - **Discover** - Find businesses nearby (list & map view)
   - **Scan** - Scan QR code to earn loyalty stamps
   - **Wallet** - View loyalty cards & rewards
   - **Account** - Profile & settings

### Business Owner Experience
1. Select "I'm a Business Owner" on onboarding
2. Choose to **Sign In** or **Create Account**
3. Access Owner Dashboard with tabs:
   - **Dashboard** - Analytics, recent check-ins, quick actions
   - **Customers** - Customer profiles with visit history & notes
   - **Loyalty** - Create & manage loyalty rules
   - **Check-ins** - Live check-in system with QR display
   - **Settings** - Shop management, staff, branding

## Features

### For Customers
- Browse service businesses with ratings and reviews
- **Interactive Map View** - See nearby loyalty businesses on a map with:
  - Custom markers with shop images
  - Tap markers to see shop preview cards
  - Navigate to your location
  - Dark mode support
  - Businesses geocoded from address for accurate map placement
- View shop details, staff, and opening hours
- Digital loyalty cards with visual stamp progress
- Clear rewards display (e.g., "5 visits → 50% off")
- **QR Code Scanner** - Real camera-based QR scanning to check in at shops:
  - Scans `clienty://checkin/{businessId}` or `clienty://checkin/{businessId}/rule/{ruleId}` QR codes
  - Shows "QR Unable" error if business has no active loyalty rules
  - Validates rule-specific QR codes against active rules
  - Automatically creates check-in records in database
  - Updates loyalty card with new stamp count
  - Shows progress toward next reward
  - Automatically awards rewards when threshold is reached
  - **Stops counting at max** - Prevents stamps from exceeding the program limit
  - **Redeem prompt** - Shows "Redeem First!" when user has unclaimed reward at max tier
  - **Loop program support** - Stamps reset to 0 after redeeming max tier reward
- **Pull-to-refresh** - Refresh loyalty cards and business list by pulling down
- **Loyalty progress display** - See your current loyalty card progress on the scan-to-earn page
- Reward wallet and redemption
  - **Redeem rewards with code verification** - Business staff enters redemption code to confirm reward claimed
- **Wallet Filters** - Filter cards by:
  - All Cards
  - By Business (group/filter cards by specific business)
- **Grouped Loyalty Programs** - Multi-tier rules created together appear as one card:
  - Single-tier rules show individual stamp progress
  - Multi-tier rules show all tiers in one grouped card
  - Tap any card to see detailed stamp card modal
  - Stamps display shows progress per tier for multi-tier programs
  - Ready to redeem badges for completed tiers
- Edit profile and manage account settings
- View rewards history and visited shops
- **Messages** - View offers and promotions from businesses
  - See all offers sent by businesses you've visited
  - Discount details and expiry dates
  - Quick navigation to business shops

### For Business Owners
- **Send Offers** - Create and send promotional offers to all customers or selected customers
  - Choose discount type (percentage off, fixed amount, free item, or no discount)
  - Discount type is optional - can send informational messages too
  - Set offer validity period
  - **Email Preview Modal** - Preview and edit email before sending:
    - See all recipient emails
    - Edit subject and body content
    - View offer summary (title, description, discount, validity)
    - Opens native email app with pre-filled content
  - Offers saved to database and visible in customer notifications
- **Offer Progress Tracking** - Visual dashboard showing:
  - Customer progress through offer validity period
  - Day-by-day breakdown of customers at each stage
  - Active vs completed vs upcoming tracking
- **Add Customers** - Manually add new customers with name, email, and phone
- **QR Code Display** - Full-screen QR codes for customer check-ins:
  - Shows warning if no loyalty programs are set up
  - **Groups multi-tier programs into single QR codes** - Each program has one QR code
  - **Program-specific QR codes** - Each QR code is unique to a specific loyalty rule
  - Displays program name and all tiers for each QR code
  - Share individual QR codes with program information
- **Redemption Code on Dashboard** - Quick access to set/edit reward redemption code directly from dashboard
- **Address Autocomplete** - Google Places-style address autocomplete during business onboarding
- **Staff Management** - Manage team members:
  - Add staff with name, specialty, and **gallery photo selection**
  - **Edit existing staff members** - Update name, specialty, and avatar
  - Remove staff members
  - **Icon placeholder** when no photo is selected (instead of default image)
- **Edit Loyalty Rules** - Full rule management:
  - Create new rules with visits required, reward type, and description
  - Edit existing rules (visits, reward, description, eligible services)
  - Toggle rules active/inactive
  - Delete rules
  - Proper submit button and keyboard handling
- Create custom loyalty rules:
  - Set visit requirements
  - Choose reward type (percentage, free, custom)
  - Select eligible services
  - **Program completion behavior**:
    - **Loop**: Card resets after completion, customer can earn rewards again
    - **Expires**: Card is complete after all tiers reached, with calendar-based expiry date picker
  - Multi-tier reward programs (e.g., 5 visits = 50% off, 10 visits = free service)
- Live customer check-in feed with search functionality
- Customer profiles with:
  - Visit history
  - Notes and preferences (editable with keyboard handling)
  - **Programs count** - Shows number of programs the customer is enrolled in
  - Progress toward next reward
- Analytics dashboard:
  - Total customers
  - Repeat rate
  - Rewards redeemed
  - Check-ins today/week/month
- Shop management:
  - Edit shop details and **single shop image** (replaces instead of adding)
  - **Redemption Code** - Set a unique code that customers must enter to redeem rewards
  - Manage staff/team members (add, edit, delete)
  - Set opening hours with **improved time picker UI** (centered numbers)
  - QR code for customer check-ins
  - **Visibility Toggle** - Make business public (visible) or private (hidden from discovery)
- **Business Profile Preview** - Shows programs with names instead of individual tiers
- **Owner Profile** - Default avatar (no photo picker for owners)
- Push notifications to customers
- Custom branding (colors & logo)

## Supported Business Types

Clienty works great for:
- Hair salons
- Barbershops
- Nail studios
- Spas
- Beauty salons
- And other service-based businesses!

## Tech Stack

- Expo SDK 53
- React Native 0.76.7
- TypeScript
- NativeWind (TailwindCSS)
- Zustand for state management
- React Query for async state
- expo-router for navigation
- react-native-reanimated for animations
- **Supabase** for database and authentication

## Database Setup (Supabase)

The app uses Supabase for backend services. To set up the database:

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** > **New Query**
3. Copy the contents of `supabase-schema.sql` and paste it into the editor
4. Click **Run** to create all tables and security policies

### IMPORTANT: RLS Policies

If you're getting errors like `"new row violates row-level security policy"`, you need to run the RLS policies:

1. Go to Supabase **SQL Editor** > **New Query**
2. Copy the **entire contents** of `RLS_POLICIES_TO_RUN.sql`
3. Paste and click **Run**

This sets up all the Row Level Security policies that allow:
- Users to create their own profile on signup
- Business owners to create and manage their business
- Customers to view businesses and check in
- All other CRUD operations with proper authorization

### Redemption Code Column

To enable the reward redemption code feature, run `ADD_REDEMPTION_CODE_COLUMN.sql`:

1. Go to Supabase **SQL Editor** > **New Query**
2. Copy the contents of `ADD_REDEMPTION_CODE_COLUMN.sql`
3. Paste and click **Run**

The schema includes:
- `profiles` - User profiles (extends Supabase auth)
- `businesses` - Business/shop information
- `staff` - Staff members for each business
- `loyalty_rules` - Loyalty program rules
- `loyalty_cards` - Customer loyalty progress
- `check_ins` - Visit records
- `offers` - Promotional offers
- `customer_notes` - Business owner notes about customers

All tables have Row Level Security (RLS) policies configured for proper access control.

## Project Structure

```
src/
├── app/
│   ├── _layout.tsx          # Root layout with role-based navigation
│   ├── onboarding.tsx       # Role selection screen
│   ├── auth/                # Authentication screens
│   │   ├── sign-in.tsx      # Sign in page
│   │   └── register.tsx     # Registration page
│   ├── (customer)/          # Customer tab navigator
│   │   ├── _layout.tsx
│   │   ├── index.tsx        # Discover
│   │   ├── tap.tsx          # QR/NFC check-in
│   │   ├── wallet.tsx       # Loyalty cards
│   │   └── account.tsx      # Profile
│   ├── (owner)/             # Owner tab navigator
│   │   ├── _layout.tsx
│   │   ├── index.tsx        # Dashboard
│   │   ├── customers.tsx    # Customer list
│   │   ├── loyalty.tsx      # Loyalty rules
│   │   ├── checkins.tsx     # Check-in feed
│   │   └── settings.tsx     # Shop settings
│   ├── settings/            # Settings screens (shared)
│   │   ├── notifications.tsx
│   │   ├── appearance.tsx
│   │   ├── privacy.tsx
│   │   ├── help.tsx
│   │   ├── app-settings.tsx
│   │   ├── rewards.tsx
│   │   ├── visited-shops.tsx
│   │   ├── edit-profile.tsx
│   │   ├── shop-details.tsx
│   │   ├── staff.tsx
│   │   ├── hours.tsx
│   │   ├── qr-code.tsx
│   │   ├── loyalty-programs.tsx
│   │   ├── push-notifications.tsx
│   │   └── branding.tsx
│   ├── shop/[id].tsx        # Shop detail page
│   ├── card/[id].tsx        # Loyalty card detail
│   ├── customer/[id].tsx    # Customer profile (owner view)
│   ├── send-offer.tsx       # Create and send offers
│   ├── offers.tsx           # View offers with progress tracking
│   └── qr-display.tsx       # QR code display modal
├── components/              # Reusable UI components
├── data/
│   └── mockData.ts          # Mock data for development
├── lib/
│   └── cn.ts                # className merge utility
├── stores/
│   ├── authStore.ts         # Authentication & role state
│   └── businessStore.ts     # Business data (customers, check-ins, offers)
└── types/
    └── index.ts             # TypeScript interfaces
```

## Permission Model

| Feature | Customer | Owner |
|---------|----------|-------|
| Browse businesses | ✓ | ✗ |
| View loyalty cards | ✓ | ✗ |
| Check-in to earn stamps | ✓ | ✗ |
| Redeem rewards | ✓ | ✗ |
| Edit loyalty rules | ✗ | ✓ |
| View analytics | ✗ | ✓ |
| Manage customers | ✗ | ✓ |
| Add customers | ✗ | ✓ |
| Send offers | ✗ | ✓ |
| Track offer progress | ✗ | ✓ |
| Display QR code | ✗ | ✓ |

## Brand Colors

- Brand: `#C97B3A` (warm copper)
- Charcoal: `#1A1A1A` (dark background)
- Cream: `#FDF8F3` (light text)
- Gold: `#C9A050` (VIP/premium)
- Success: `#22C55E`
- Warning: `#F59E0B`
- Danger: `#EF4444`
