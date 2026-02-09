# Remaining Fixes for Business App

## ✅ Already Fixed
1. ✅ "Open now" logic now checks actual time against business hours
2. ✅ "Check in & Earn Stamp" button hidden from business owners
3. ✅ Multi-tier loyalty programs now grouped together in preview

## 🔧 Still Need to Fix

### 4. Business Photo Upload from Gallery
**Location**: `src/app/settings/shop-details.tsx` or create new screen
**What to do**:
- Use `expo-image-picker` to select image from gallery
- Upload to Supabase Storage
- Update `businesses` table with image URL
- Show blank/placeholder image if no photo set

**Code snippet**:
```typescript
import * as ImagePicker from 'expo-image-picker';

const pickImage = async () => {
  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ImagePicker.MediaTypeOptions.Images,
    allowsEditing: true,
    aspect: [16, 9],
    quality: 0.8,
  });

  if (!result.canceled && result.assets[0]) {
    // Upload to Supabase Storage
    const file = result.assets[0];
    // const { data, error } = await supabase.storage
    //   .from('business-images')
    //   .upload(`${businessId}/${Date.now()}.jpg`, file);
  }
};
```

### 5. Edit Staff Photos
**Location**: `src/app/settings/staff.tsx`
**What to do**:
- Add edit button to each staff member
- Allow image picker for staff avatar
- Update `staff` table with new avatar URL

### 6. Validate Real Phone Number and Address
**Location**: `src/app/business-onboarding/index.tsx`
**What to do**:
- Add validation for phone number format (regex)
- Add validation for address (check for "fake", "test", etc.)
- Show error message if invalid

**Code snippet**:
```typescript
const validatePhone = (phone: string) => {
  // US phone: (123) 456-7890 or 123-456-7890
  const phoneRegex = /^\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})$/;
  return phoneRegex.test(phone);
};

const validateAddress = (address: string) => {
  const fakeWords = ['fake', 'test', 'asdf', '123 main', 'none'];
  const lowerAddress = address.toLowerCase();
  return !fakeWords.some(word => lowerAddress.includes(word)) && address.length > 10;
};
```

### 7. Fix Opening Hours Editing
**Location**: `src/app/settings/hours.tsx`
**What to do**:
- Check if time inputs are editable
- Ensure `TextInput` is not `editable={false}`
- Make sure onChangeText handlers are working

### 8. Fix Business Owner Photo Not Saving
**Location**: Check `src/app/settings/edit-profile.tsx` or similar
**What to do**:
- After picking image, upload to Supabase Storage
- Update `profiles` table with avatar URL
- Make sure to use `useUpdateProfile` mutation to persist

**Issue**: Likely missing the database update after image selection

### 9. Fix Customer Profile Photo Not Saving
**Location**: Same as #8
**What to do**:
- Same fix as business owner photo
- Ensure mutation is called with proper avatar URL
- Check that AsyncStorage is updated

### 10. Show Blank Image When No Business Photo
**Location**: Everywhere business images are displayed
**What to do**:
- Replace with placeholder component when `images` array is empty
- Example: `{shop.images?.[0] || 'https://placehold.co/400x200/1A1A1A/888888?text=No+Image'}`

## Priority Order
1. **HIGH**: Fix opening hours editing (#7)
2. **HIGH**: Fix photo saving persistence (#8, #9)
3. **MEDIUM**: Add business photo upload (#4)
4. **MEDIUM**: Validate phone/address (#6)
5. **LOW**: Edit staff photos (#5)
6. **LOW**: Blank image placeholder (#10)

## Common Issue: Photo Not Saving
The photo not saving is likely because:
1. Image is selected but not uploaded to Supabase Storage
2. Upload happens but database isn't updated
3. Database is updated but AsyncStorage/state isn't refreshed

**Fix pattern**:
```typescript
const updatePhoto = async (imageUri: string) => {
  // 1. Upload to Supabase Storage
  const response = await fetch(imageUri);
  const blob = await response.blob();
  const fileName = `${userId}-${Date.now()}.jpg`;

  const { data, error } = await supabase.storage
    .from('avatars')
    .upload(fileName, blob);

  if (error) throw error;

  // 2. Get public URL
  const { data: { publicUrl } } = supabase.storage
    .from('avatars')
    .getPublicUrl(fileName);

  // 3. Update database
  await supabase
    .from('profiles')
    .update({ avatar: publicUrl })
    .eq('id', userId);

  // 4. Update local state
  await setUser({ ...user, avatar: publicUrl });
};
```
