# APK Release Build Fix - Complete Guide

## Problem
The app works perfectly in **debug mode** but doesn't get chat responses in **release APK** build. This is a common issue with Flutter release builds due to:
1. Missing internet permissions
2. Missing network security configuration
3. Code obfuscation by ProGuard breaking network calls

## Solution Implemented

### 1. Internet Permissions ✅
**File**: `android/app/src/main/AndroidManifest.xml`

Added required permissions:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 2. Network Security Configuration ✅
**File**: `android/app/src/main/res/xml/network_security_config.xml`

Created network security config to allow HTTPS connections to backend:
```xml
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
    
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">ai-colab-chat-manan-backend.onrender.com</domain>
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </domain-config>
</network-security-config>
```

**Updated AndroidManifest.xml** to reference this config:
```xml
<application
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config">
```

### 3. ProGuard Rules ✅
**File**: `android/app/proguard-rules.pro`

Added comprehensive ProGuard rules to prevent code obfuscation from breaking:
- Flutter framework classes
- Dio HTTP client
- Gson JSON serialization
- SSE (Server-Sent Events) streaming
- Data models

Key rules:
```proguard
## Flutter wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Dio
-dontwarn okio.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

## Gson
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

## Keep data models
-keep class com.example.colabplatforms_ai.** { *; }
```

### 4. Build Configuration ✅
**File**: `android/app/build.gradle.kts`

Updated release build configuration:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        
        // Enable minification and shrinking
        isMinifyEnabled = true
        isShrinkResources = true
        
        // Proguard rules
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

## Next Steps - Build and Test

### Step 1: Clean Build
Run these commands in terminal:
```bash
flutter clean
flutter pub get
```

### Step 2: Build Release APK
```bash
flutter build apk --release
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 3: Install on Physical Device
```bash
flutter install --release
```

Or manually transfer the APK to your phone and install it.

### Step 4: Test All Features
Test these critical features in the release APK:
- ✅ Login with email/password
- ✅ Google OAuth login
- ✅ Email verification OTP
- ✅ Chat message sending
- ✅ Chat response streaming (SSE)
- ✅ Like/Dislike buttons
- ✅ Regenerate response
- ✅ Multiple model selection UI
- ✅ Profile display with image
- ✅ Logout functionality

## Troubleshooting

### If Still No Response in Release APK:

1. **Check Logs**:
   Connect device via USB and run:
   ```bash
   flutter logs
   ```
   or
   ```bash
   adb logcat | grep flutter
   ```

2. **Verify Network Calls**:
   Look for these in logs:
   - `*** Request ***` - Shows outgoing API calls
   - `*** Response ***` - Shows API responses
   - `DioException` - Shows network errors

3. **Common Issues**:
   - **401 Unauthorized**: Token not being saved/retrieved properly
   - **Connection timeout**: Network security config issue
   - **No logs at all**: ProGuard rules too aggressive

4. **Additional ProGuard Rules**:
   If specific classes are being obfuscated, add more specific rules:
   ```proguard
   -keep class com.example.colabplatforms_ai.features.** { *; }
   -keep class com.example.colabplatforms_ai.core.** { *; }
   ```

## Backend URL
Current backend: `https://ai-colab-chat-manan-backend.onrender.com`

This URL is:
- ✅ Configured in `lib/core/constants/api_constants.dart`
- ✅ Whitelisted in `network_security_config.xml`
- ✅ Uses HTTPS (secure connection)

## Summary
All necessary configurations have been added to make the release APK work properly:
- Internet permissions granted
- Network security configured for backend domain
- ProGuard rules prevent code obfuscation issues
- Release build properly configured

**The release APK should now work exactly like debug mode!**

---

**Last Updated**: May 28, 2026
**Status**: Ready for testing
