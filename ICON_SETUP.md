# 🎨 Quick Icon Setup - Home AI Index

## ⚡ 3-Step Process

### 1️⃣ Create Your Icon (1024x1024 PNG)

**Easy options:**
- 🎨 **Canva**: https://www.canva.com/ → "App Icon" template
- 🖼️ **AppIcon.co**: https://www.appicon.co/ → Upload & generate
- 🎯 **Figma**: https://www.figma.com/ → Free design tool

**Quick design ideas:**
```
Option 1: Letter Icon
- Background: Blue gradient
- Text: "HAI" in white
- Style: Bold, modern

Option 2: Symbol Icon
- Background: Green #4CAF50
- Icon: House + magnifying glass
- Style: Flat design

Option 3: Minimal Logo
- Background: White
- Shape: Simple geometric icon
- Color: Brand color
```

### 2️⃣ Save Your Icon

```bash
# Create directory (if needed)
mkdir assets\icon

# Save your image as:
assets/icon/app_icon.png
```

### 3️⃣ Generate & Build

```bash
# Install packages
flutter pub get

# Generate icons (automatically creates all sizes)
dart run flutter_launcher_icons

# Clean and rebuild
flutter clean
flutter run --release
```

---

## 📋 Icon Specifications

| Property | Value |
|----------|-------|
| Size | 1024x1024 pixels |
| Format | PNG with transparency |
| DPI | 72+ |
| Color | RGB/RGBA |
| Quality | High (not upscaled) |

---

## 🛠️ Configuration (Already Done!)

Your `pubspec.yaml` is already configured:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon.png"
```

---

## ✅ Verification

After generating, check:

```bash
# Android icons generated here:
android/app/src/main/res/mipmap-*/ic_launcher.png

# iOS icons generated here:
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

---

## 🚨 Troubleshooting

### Icon not updating?

```bash
# Uninstall app first
adb uninstall com.homeai.home_ai_index

# Clean rebuild
flutter clean && flutter pub get && flutter run
```

### Generator error?

```bash
# Ensure image exists
ls assets/icon/app_icon.png

# Reinstall package
flutter pub get

# Run with verbose
dart run flutter_launcher_icons -v
```

---

## 🎯 Current Status

- ✅ Package installed: `flutter_launcher_icons: ^0.13.1`
- ✅ Configuration added to `pubspec.yaml`
- ✅ Directory created: `assets/icon/`
- ⏳ **Next**: Add your `app_icon.png` file
- ⏳ **Then**: Run `dart run flutter_launcher_icons`

---

## 📚 More Help

- **Full Guide**: `docs/APP_ICON_GUIDE.md`
- **Assets Folder**: `assets/icon/README.md`
- **Package Docs**: https://pub.dev/packages/flutter_launcher_icons

---

**Ready to create your icon!** 🚀

Just add `assets/icon/app_icon.png` and run the generator!
