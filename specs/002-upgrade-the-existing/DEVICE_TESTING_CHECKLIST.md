# Device Testing Checklist

**Device**: Samsung SM S918W (Android 15, API 35)  
**Date**: October 17, 2025  
**Tester**: [Your Name]  
**Build**: Debug Mode  

---

## Pre-Testing Setup

- [ ] **Device Connected**: Verify device appears in `flutter devices`
- [ ] **USB Debugging Enabled**: Check device developer settings
- [ ] **App Installed**: App successfully builds and installs on device
- [ ] **Internet Connection**: Verify device has WiFi/mobile data

---

## T070: Secure Storage Testing (CRITICAL)

### Initial Setup
- [ ] **First Launch**: App opens successfully
- [ ] **Navigate to Settings**: Can access settings screen
- [ ] **Enter API Credentials**:
  - [ ] Enter valid Google Cloud Vision API key
  - [ ] Optionally enter Project ID
  - [ ] Tap "Save Credentials"
  - [ ] Verify success message appears

### Secure Storage Verification
- [ ] **Credentials Persist**: Close app completely (swipe away from recents)
- [ ] **Reopen App**: Launch app again
- [ ] **Navigate to Settings**: Check if credentials are still present
- [ ] **Masked Display**: Verify API key shows as `AIza...xyz1` (masked)
- [ ] **Clear Credentials**:
  - [ ] Tap "Clear Credentials" button
  - [ ] Confirm in dialog
  - [ ] Verify credentials are removed
  - [ ] Close and reopen app
  - [ ] Verify credentials are gone

### Security Testing
- [ ] **Screenshot Protection**: Try taking screenshot of settings screen with API key
- [ ] **Screen Recording**: Verify API key is not visible in recordings (if possible)
- [ ] **Task Switcher**: Check if API key visible in recent apps preview

**Result**: ✅ Pass / ❌ Fail / ⚠️ Issues  
**Notes**:

---

## T080: Core Functionality Testing

### Home Screen
- [ ] **App Launches**: Home screen appears with "My Items" title
- [ ] **Empty State**: If no items, appropriate empty state shown
- [ ] **Navigation**: Bottom navigation bar visible and functional
- [ ] **UI Rendering**: No visual glitches or layout issues

### Add Item Flow
- [ ] **Camera Button**: Tap camera icon in home screen
- [ ] **Permission Request**: Camera permission dialog appears (if first time)
- [ ] **Camera Opens**: Device camera opens successfully
- [ ] **Take Photo**: Take photo of a household item
- [ ] **Photo Loaded**: Photo appears in add item screen
- [ ] **Recognition Triggered**: Loading indicator appears
- [ ] **API Call**: Cloud Vision API processes image (check status)
- [ ] **Results Display**: Recognition results appear (labels with confidence)
- [ ] **Edit Item**: Can edit item name, quantity, location
- [ ] **Save Item**: Item saves successfully
- [ ] **Return to Home**: Item appears in home screen list

### Gallery Flow
- [ ] **Gallery Button**: Select image from gallery option
- [ ] **Permission Request**: Storage permission dialog (if first time)
- [ ] **Gallery Opens**: Photo picker opens
- [ ] **Select Photo**: Choose existing photo
- [ ] **Recognition Works**: Same recognition flow as camera

**Result**: ✅ Pass / ❌ Fail / ⚠️ Issues  
**Notes**:

---

## T082: Household Items Recognition Testing

Test with various real household items:

### Groceries
- [ ] **Fresh Produce**: Banana, apple, orange, etc.
- [ ] **Packaged Food**: Cereal box, canned goods, snacks
- [ ] **Beverages**: Soda can, water bottle, juice box
- **Best Result**:
- **Worst Result**:

### Electronics
- [ ] **Phone/Tablet**: Smartphone, tablet device
- [ ] **Laptop/Computer**: Laptop, desktop, keyboard
- [ ] **Small Electronics**: Remote control, headphones, charger
- **Best Result**:
- **Worst Result**:

### Kitchen Items
- [ ] **Utensils**: Fork, spoon, knife, spatula
- [ ] **Cookware**: Pot, pan, bowl, plate
- [ ] **Appliances**: Toaster, blender, coffee maker
- **Best Result**:
- **Worst Result**:

### Furniture/Home
- [ ] **Furniture**: Chair, table, lamp
- [ ] **Decorations**: Picture frame, vase, plant
- [ ] **Tools**: Hammer, screwdriver, wrench
- **Best Result**:
- **Worst Result**:

**Overall Recognition Accuracy**: ___ out of ___ items correctly identified  
**Notes**:

---

## T083: Edge Cases & Error Handling

### Network Scenarios
- [ ] **Offline Mode**:
  - [ ] Turn off WiFi and mobile data
  - [ ] Try to recognize an item
  - [ ] Verify error message: "No internet connection..."
  - [ ] Can still enter item manually
  - [ ] Turn network back on
  - [ ] Verify recognition works again

- [ ] **Network Switch**:
  - [ ] Start recognition on WiFi
  - [ ] Switch to mobile data during API call
  - [ ] Verify graceful handling (success or timeout)

- [ ] **Weak Signal**:
  - [ ] Move to area with weak signal
  - [ ] Try recognition
  - [ ] Note if timeout message appears (if >30s)

### Image Edge Cases
- [ ] **No Recognizable Objects**:
  - [ ] Photo of plain wall or empty space
  - [ ] Verify appropriate message or low confidence labels

- [ ] **Multiple Objects**:
  - [ ] Photo with 3+ prominent objects
  - [ ] Verify top labels returned
  - [ ] Can select appropriate item from suggestions

- [ ] **Large Image**:
  - [ ] High-resolution photo (>10MB if possible)
  - [ ] Verify image processes without crash
  - [ ] Note processing time

- [ ] **Very Dark/Bright**:
  - [ ] Photo in poor lighting
  - [ ] Photo with glare/overexposure
  - [ ] Check if recognition still works

- [ ] **Blurry Photo**:
  - [ ] Out-of-focus image
  - [ ] Check recognition quality

### API Scenarios
- [ ] **Invalid API Key**:
  - [ ] Enter incorrect API key in settings
  - [ ] Try recognition
  - [ ] Verify error: "Authentication failed..."

- [ ] **No Credentials**:
  - [ ] Clear all credentials
  - [ ] Try recognition
  - [ ] Verify error: "Please configure API credentials..."

**Result**: ✅ Pass / ❌ Fail / ⚠️ Issues  
**Notes**:

---

## T064-T067: Performance Testing

### API Latency (T064)
- [ ] **Normal Network**: Measure time from photo taken to results displayed
  - Trial 1: ___ seconds
  - Trial 2: ___ seconds
  - Trial 3: ___ seconds
  - **Average**: ___ seconds (Target: <3s)

### Image Preprocessing (T065)
- [ ] **Large Image**: Take high-res photo, note preprocessing time
  - **Time from photo to API call**: ___ seconds (Target: <1s)

### Slow Network (T066)
- [ ] **3G Simulation**: If possible, limit connection speed
  - [ ] Recognition still works
  - [ ] Timeout handling activates if >30s
  - **Time**: ___ seconds

### Startup Time (T067)
- [ ] **Cold Start**: Kill app, reopen, measure time to home screen
  - Trial 1: ___ seconds
  - Trial 2: ___ seconds
  - Trial 3: ___ seconds
  - **Average**: ___ seconds
- [ ] **Compare to Expected**: No significant regression noted

**Result**: ✅ Pass / ❌ Fail / ⚠️ Issues  
**Notes**:

---

## UI/UX Testing

### Responsiveness
- [ ] **Smooth Scrolling**: Lists scroll smoothly without lag
- [ ] **Button Feedback**: Buttons respond immediately to taps
- [ ] **Animations**: Transitions are smooth and appropriate
- [ ] **Loading States**: Loading indicators appear for async operations

### Visual Quality
- [ ] **Text Readability**: All text is clear and properly sized
- [ ] **Touch Targets**: Buttons/interactive elements easy to tap (≥48dp)
- [ ] **Spacing**: Proper padding and margins throughout
- [ ] **Colors**: Good contrast, readable in various lighting
- [ ] **Images**: Photos display correctly without distortion

### Error States
- [ ] **Error Messages**: Clear, user-friendly error messages
- [ ] **Retry Options**: Can retry failed operations
- [ ] **Graceful Degradation**: App doesn't crash on errors

**Result**: ✅ Pass / ❌ Fail / ⚠️ Issues  
**Notes**:

---

## Data Persistence Testing

### Items Management
- [ ] **Add Items**: Add 5-10 items with photos
- [ ] **Close App**: Completely close app (swipe from recents)
- [ ] **Reopen App**: Launch app again
- [ ] **Verify Items**: All items still present with photos
- [ ] **Edit Item**: Modify an existing item
- [ ] **Delete Item**: Remove an item
- [ ] **Persistence**: Changes persist after app restart

### Settings Persistence
- [ ] **Offline Mode**: Enable offline mode setting
- [ ] **App Restart**: Close and reopen
- [ ] **Setting Persists**: Offline mode still enabled
- [ ] **Theme**: Change theme (if available)
- [ ] **Theme Persists**: Theme setting survives restart

**Result**: ✅ Pass / ❌ Fail / ⚠️ Issues  
**Notes**:

---

## Critical Issues Found

List any critical bugs or issues:

1. **Issue**: 
   **Severity**: Critical / High / Medium / Low
   **Steps to Reproduce**:
   **Expected**:
   **Actual**:

2. **Issue**: 
   **Severity**: Critical / High / Medium / Low
   **Steps to Reproduce**:
   **Expected**:
   **Actual**:

---

## Optional: Accessibility Testing (T072-T073)

### Screen Reader (TalkBack)
- [ ] **Enable TalkBack**: Settings > Accessibility > TalkBack
- [ ] **Navigate App**: Can navigate all screens with TalkBack
- [ ] **Button Labels**: All buttons have meaningful labels
- [ ] **Image Descriptions**: Important images have descriptions
- [ ] **Form Fields**: Input fields properly labeled

### Touch Targets (T072)
- [ ] **Button Size**: All tappable elements ≥48dp x 48dp
- [ ] **Spacing**: Adequate space between interactive elements
- [ ] **No Accidental Taps**: Buttons not too close together

**Result**: ✅ Pass / ❌ Fail / ⚠️ Issues  
**Notes**:

---

## Test Summary

**Device**: Samsung SM S918W (Android 15, API 35)  
**Test Date**: October 17, 2025  
**Total Test Cases**: ___  
**Passed**: ___  
**Failed**: ___  
**Issues Found**: ___  

**Overall Assessment**: 
- [ ] ✅ Ready for production
- [ ] ⚠️ Minor issues, acceptable for release
- [ ] ❌ Critical issues, needs fixes before release

**Recommendations**:

**Next Steps**:

---

## Notes

(Add any additional observations, concerns, or suggestions here)

---

**Signed**: ___________________  
**Date**: October 17, 2025
