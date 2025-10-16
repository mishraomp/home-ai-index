# App Icon Guide - Home AI Index

This guide explains how to add a custom icon/logo for your Flutter app.

## 🎨 Quick Start

### Method 1: Using flutter_launcher_icons (Recommended) ✅

This method automatically generates all required icon sizes for Android and iOS.

#### Step 1: Prepare Your Icon Image

Create an app icon image with these specifications:

**Requirements:**
- **Size**: 1024x1024 pixels (minimum 512x512)
- **Format**: PNG with transparency (for adaptive icons)
- **Design**: Simple, recognizable, looks good at small sizes
- **Background**: Transparent or solid color
- **Safe Area**: Keep important elements in the center 60% area

**Design Tips:**
- Use high contrast colors
- Avoid thin lines (they disappear at small sizes)
- Test how it looks at 48x48 pixels
- Avoid text (hard to read at small sizes)
- Use simple, iconic shapes

#### Step 2: Save Your Icon

Save your icon as:
```
assets/icon/app_icon.png
```

Create the directory if it doesn't exist:
```bash
mkdir -p assets/icon
```

#### Step 3: Install Dependencies

```bash
flutter pub get
```

#### Step 4: Generate Icons

Run the icon generator:

```bash
# Generate icons for all platforms
dart run flutter_launcher_icons

# Or use flutter pub run (older versions)
flutter pub run flutter_launcher_icons
```

This will automatically:
- ✅ Generate all required Android icon sizes
- ✅ Generate all required iOS icon sizes
- ✅ Update AndroidManifest.xml
- ✅ Create adaptive icons for Android 8.0+

#### Step 5: Verify and Build

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build and run
flutter run --release
```

---

## 🎨 Method 2: Manual Icon Creation (Advanced)

If you prefer manual control or need custom per-platform icons:

### For Android

1. **Create icon files** in different sizes:
   - mipmap-mdpi: 48x48 px
   - mipmap-hdpi: 72x72 px
   - mipmap-xhdpi: 96x96 px
   - mipmap-xxhdpi: 144x144 px
   - mipmap-xxxhdpi: 192x192 px

2. **Place files** in:
   ```
   android/app/src/main/res/
   ├── mipmap-mdpi/ic_launcher.png
   ├── mipmap-hdpi/ic_launcher.png
   ├── mipmap-xhdpi/ic_launcher.png
   ├── mipmap-xxhdpi/ic_launcher.png
   └── mipmap-xxxhdpi/ic_launcher.png
   ```

3. **Update AndroidManifest.xml**:
   ```xml
   <application
       android:icon="@mipmap/ic_launcher"
       ...>
   ```

### For iOS

1. **Open Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Navigate to**: Runner → Runner → Assets.xcassets → AppIcon

3. **Drag and drop** your icons for each size

4. **Required sizes**:
   - 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024

---

## 🛠️ Using Online Tools

### Recommended Icon Generators:

1. **AppIcon.co** (https://www.appicon.co/)
   - Upload 1024x1024 image
   - Downloads all sizes for Android & iOS
   - Free and easy to use

2. **Icon Kitchen** (https://icon.kitchen/)
   - Online generator
   - Adaptive icon support
   - Preview on devices

3. **Android Asset Studio** (https://romannurik.github.io/AndroidAssetStudio/)
   - Official Android tool
   - Adaptive icons
   - Material Design guidelines

---

## 📋 Configuration Options

### Basic Configuration (pubspec.yaml)

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
```

### Advanced Configuration

```yaml
flutter_launcher_icons:
  # Generate for Android
  android: true
  
  # Generate for iOS
  ios: true
  
  # Main icon image (1024x1024 recommended)
  image_path: "assets/icon/app_icon.png"
  
  # Adaptive icons (Android 8.0+)
  adaptive_icon_background: "#FFFFFF"  # Solid color or image path
  adaptive_icon_foreground: "assets/icon/foreground.png"
  
  # Platform-specific overrides
  image_path_android: "assets/icon/android_icon.png"
  image_path_ios: "assets/icon/ios_icon.png"
  
  # Icon name (default: ic_launcher)
  android_icon_name: "ic_launcher"
  ios_icon_name: "AppIcon"
  
  # Remove alpha channel for iOS
  remove_alpha_ios: true
  
  # Minimum SDK version
  min_sdk_android: 21
```

---

## 🎯 Quick Design Templates

### Template 1: Simple Letter Icon
```
- Background: Gradient (Blue #2196F3 → Purple #9C27B0)
- Text: "HAI" (Home AI Index) in white
- Font: Bold, Sans-serif
- Size: 1024x1024
```

### Template 2: Icon with Symbol
```
- Background: Solid color #4CAF50 (green)
- Symbol: House icon with magnifying glass
- Style: Flat design, white icon
- Padding: 200px from edges
```

### Template 3: Minimalist Logo
```
- Background: White or transparent
- Icon: Simple geometric shape (cube, hexagon)
- Colors: Primary brand color
- Shadow: Subtle drop shadow
```

---

## 🖼️ Creating Your Icon

### Option 1: Use Figma (Recommended)

1. Create 1024x1024 artboard
2. Design your icon
3. Export as PNG with transparency
4. Save to `assets/icon/app_icon.png`

### Option 2: Use Canva

1. Create custom size: 1024x1024
2. Use templates or design from scratch
3. Download as PNG
4. Save to project

### Option 3: Use GIMP/Photoshop

1. New file: 1024x1024, 72 DPI
2. Design with layers
3. Export as PNG-24 (with transparency)
4. Save to assets folder

---

## ✅ Verification Checklist

After generating icons:

- [ ] Icon appears in app drawer (Android)
- [ ] Icon appears on home screen (iOS)
- [ ] Icon looks sharp (not blurry)
- [ ] Icon is recognizable at small size
- [ ] Adaptive icon works on Android 8.0+
- [ ] No white/black borders around icon
- [ ] Icon matches brand colors
- [ ] Icon is unique and identifiable

---

## 🐛 Troubleshooting

### Icon not updating

**Solution 1: Clean rebuild**
```bash
flutter clean
flutter pub get
flutter run
```

**Solution 2: Uninstall app**
```bash
# Uninstall from device
adb uninstall com.homeai.home_ai_index

# Reinstall
flutter run
```

**Solution 3: Clear cache**
```bash
# Android
adb shell pm clear com.homeai.home_ai_index

# Then reinstall
flutter run
```

### Icons are blurry

**Cause**: Image resolution too low

**Solution**: 
- Use minimum 1024x1024 image
- Ensure image is high quality (not scaled up)
- Use vector graphics if possible

### Adaptive icon background is wrong

**Solution**: 
Update `pubspec.yaml`:
```yaml
adaptive_icon_background: "#FFFFFF"  # Use your color
# or
adaptive_icon_background: "assets/icon/background.png"
```

### Icons not generated

**Solution**:
```bash
# Make sure package is installed
flutter pub get

# Run with verbose output
dart run flutter_launcher_icons -v
```

---

## 📱 Platform-Specific Notes

### Android

- **Adaptive Icons**: Required for Android 8.0+ (API 26+)
- **Icon Shape**: System determines shape (circle, square, rounded)
- **Safe Zone**: Keep important content in center 66% of icon
- **Background**: Can be solid color or image

### iOS

- **Format**: PNG without transparency (or remove alpha)
- **Rounded Corners**: System adds automatically
- **Sizes**: Multiple sizes required for different devices
- **App Store**: 1024x1024 required for submission

---

## 🎨 Design Resources

### Free Icon Tools
- **Figma**: https://www.figma.com/ (Free tier)
- **Canva**: https://www.canva.com/ (Free templates)
- **Inkscape**: https://inkscape.org/ (Free vector editor)
- **GIMP**: https://www.gimp.org/ (Free image editor)

### Icon Inspiration
- **Dribbble**: https://dribbble.com/tags/app-icon
- **Behance**: https://www.behance.net/search/projects?search=app+icon
- **Material Icons**: https://fonts.google.com/icons

### Design Guidelines
- **Material Design**: https://m3.material.io/
- **iOS Human Interface**: https://developer.apple.com/design/human-interface-guidelines/app-icons

---

## 📝 Current Configuration

Your app is configured with:

```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon.png"
  remove_alpha_ios: true
```

**Next steps:**
1. Create your 1024x1024 icon image
2. Save it as `assets/icon/app_icon.png`
3. Run `dart run flutter_launcher_icons`
4. Build and test your app

---

## 🚀 Quick Commands Reference

```bash
# Install dependencies
flutter pub get

# Generate icons
dart run flutter_launcher_icons

# Clean build
flutter clean

# Build APK with new icon
flutter build apk --release

# Run on device
flutter run --release

# Check current icon
# Android: Look in android/app/src/main/res/mipmap-*/
# iOS: Look in ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

---

**Ready to create your app icon!** 🎨

Just place your 1024x1024 PNG at `assets/icon/app_icon.png` and run the generator!
