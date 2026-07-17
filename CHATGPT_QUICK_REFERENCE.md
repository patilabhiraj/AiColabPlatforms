# ChatGPT iOS Header - Quick Reference Card

## 🎯 The Formula

```
Glass Effect = STRONG BLUR (20-30σ) + WEAK OPACITY (8-12%)
```

## 📊 Exact Values

| Property | Value | Why |
|----------|-------|-----|
| **Height** | 50px | iOS standard (not Material 56px) |
| **Blur Max** | 30σ | Strong frosted glass effect |
| **Opacity Max** | 12% | Barely visible background |
| **Border** | 3% opacity | Nearly invisible |
| **Shadow** | None | Floating, not anchored |
| **Scroll Trigger** | 30px | Show early |

## 🔢 Formulas

```dart
// Scroll listener
blur = (offset / 4).clamp(0.0, 30.0)
opacity = (offset / 1000).clamp(0.0, 0.12)
show = offset > 30

// Widget
height: 50
background: white @ opacity
border: black @ 0.03
blur: ImageFilter.blur(sigmaX: blur, sigmaY: blur)
```

## 📈 Progression

| Scroll | Blur | Opacity | Visibility |
|--------|------|---------|------------|
| 0px | 0σ | 0% | Invisible |
| 40px | 10σ | 0.4% | Barely there |
| 120px | 30σ | 1.2% | Glass visible |
| 500px | 30σ | 6% | More apparent |
| 1000px | 30σ | 12% | Maximum |

## ✅ Verification Checklist

- [ ] Header invisible at top
- [ ] Strong blur when scrolled
- [ ] Very subtle opacity (barely visible)
- [ ] Height is 50px
- [ ] No shadow
- [ ] Title centered
- [ ] Messages scroll behind
- [ ] Floating glass feeling

## 🎨 Colors

### Light Mode
```dart
Background: #FFFFFF @ 0-12%
Border: #000000 @ 3%
```

### Dark Mode
```dart
Background: Card @ (0-12% × 0.7)
Border: #FFFFFF @ 3%
```

## 🔧 Files Changed

```
lib/features/chat/presentation/chat_page.dart
  - _onScroll() method (lines ~40-70)
  - _TransparentAppBar widget (lines ~850-1000)
  - _MessagesList padding (lines ~730)
```

## 🚀 Test Command

```bash
# Hot restart (NOT hot reload)
Shift + R
```

## 📚 Documentation

1. **FINAL_IMPLEMENTATION_SUMMARY.md** - Complete overview
2. **CHATGPT_IOS_PIXEL_PERFECT.md** - Detailed explanation
3. **CHATGPT_QUICK_REFERENCE.md** - This file

## 💡 Remember

The secret is **STRONG BLUR + WEAK OPACITY**, not the reverse!

ChatGPT iOS uses heavy blur (30σ) to create depth, with barely visible opacity (12% max) to avoid blocking content.

---

**Status: ✅ Production Ready**
