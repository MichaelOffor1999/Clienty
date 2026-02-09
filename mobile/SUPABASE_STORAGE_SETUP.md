# Supabase Storage Setup

You need to create storage buckets for avatars and business images.

## Create Buckets

Run this in Supabase SQL Editor:

```sql
-- Create avatars bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- Create business-images bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('business-images', 'business-images', true);

-- Allow authenticated users to upload their own avatars
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Avatars are publicly accessible"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'avatars');

-- Allow business owners to upload business images
CREATE POLICY "Owners can upload business images"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'business-images'
  AND EXISTS (
    SELECT 1 FROM public.businesses
    WHERE owner_id = auth.uid()
  )
);

CREATE POLICY "Business images are publicly accessible"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'business-images');
```

## OR via Supabase Dashboard

1. Go to **Storage** in Supabase Dashboard
2. Click **New Bucket**
3. Name: `avatars`, Public: ✅ ON
4. Click **New Bucket** again
5. Name: `business-images`, Public: ✅ ON
6. Then run the RLS policies above in SQL Editor
