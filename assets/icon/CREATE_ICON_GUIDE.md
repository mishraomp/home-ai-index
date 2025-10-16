# Create Your "House + Magnifying Glass" Icon

## 🎨 Quick Creation Guide

### Method 1: Using Canva (Easiest - 5 minutes)

1. **Go to Canva**: https://www.canva.com/
2. **Create custom size**: 1024 x 1024 pixels
3. **Add elements**:
   - Search for "house icon" → Add a simple house
   - Search for "magnifying glass" → Add and overlay
   - Background: Blue gradient (#2196F3 to #4CAF50)
4. **Download** as PNG
5. **Save** as `assets/icon/app_icon.png`

### Method 2: Use Icon Generator (Fastest - 2 minutes)

1. **Go to**: https://icon.kitchen/
2. **Select**:
   - Style: "Clip Art"
   - Foreground: Search "home search" or "house magnifying"
   - Background: Gradient Blue (#2196F3) to Green (#4CAF50)
   - Shape: Rounded square
3. **Generate & Download**
4. **Save** as `assets/icon/app_icon.png`

### Method 3: Use This Figma Template

1. **Open**: https://www.figma.com/community/file/1234567890/app-icon-template
2. **Duplicate** to your drafts
3. **Design**:
   ```
   Background: Blue gradient (#2196F3 → #4CAF50)
   House Icon: White, centered, 400x400
   Magnifying Glass: White, 200x200, bottom-right overlay
   Padding: 150px from edges
   ```
4. **Export** as PNG 1024x1024
5. **Save** as `assets/icon/app_icon.png`

---

## 🎯 Design Specifications

**Layout:**
```
┌─────────────────────────┐
│  Blue → Green Gradient  │
│                         │
│       🏠 House          │
│         with            │
│      🔍 Magnifier       │
│                         │
└─────────────────────────┘
```

**Colors:**
- Background Start: `#2196F3` (Blue)
- Background End: `#4CAF50` (Green)
- Icons: White `#FFFFFF`

**Layout:**
- Canvas: 1024x1024 px
- House Icon: 450x450 px (centered)
- Magnifying Glass: 220x220 px (bottom-right of house)
- Padding: 150px from all edges

**Style:**
- Flat design
- Clean, simple icons
- Subtle shadow optional
- High contrast for visibility

---

## 🚀 After Creating Your Icon

Once you have your icon saved at `assets/icon/app_icon.png`:

```bash
# Generate all icon sizes
dart run flutter_launcher_icons

# Clean and rebuild
flutter clean
flutter run --release
```

---

## 🎨 Alternative: Use These Free Icons

If you want to use existing icons:

### Option A: Material Design Icons
1. **House**: https://fonts.google.com/icons?selected=Material+Icons:home
2. **Search**: https://fonts.google.com/icons?selected=Material+Icons:search
3. Combine in any image editor

### Option B: Flaticon
1. **Search**: https://www.flaticon.com/search?word=house%20search
2. Download free PNG
3. Add gradient background in Canva

### Option C: Icon8
1. **Browse**: https://icons8.com/icons/set/home-search
2. Download 1024x1024 PNG
3. Customize colors to match

---

## 📝 Quick Checklist

- [ ] Icon is 1024x1024 pixels
- [ ] Saved as `assets/icon/app_icon.png`
- [ ] PNG format with transparency
- [ ] Colors: Blue (#2196F3) and Green (#4CAF50)
- [ ] House and magnifying glass visible
- [ ] Looks good when small (test at 48x48)

---

## ⚡ Super Quick Option

If you need it RIGHT NOW:

1. Go to: **https://icon.kitchen/**
2. Click "Get Started"
3. Choose:
   - **Foreground**: "home" icon
   - **Background**: Gradient (blue to green)
   - **Padding**: 20%
4. Click "Generate"
5. Download PNG
6. Save as `assets/icon/app_icon.png`

**Done in under 2 minutes!** 🎉

---

## 🛠️ Then Run

```bash
dart run flutter_launcher_icons
flutter clean
flutter run --release
```

Your icon will appear on your phone! 📱✨
