# Svara — Brand art (Claude design)

Bespoke brand art for Svara, generated with CoreGraphics so it is reproducible,
vector-precise, and dependency-free (no Sketch/Figma/SVG toolchain needed).

The motif follows ProductGuardrails §8.1: **sunrise + lotus** (Svara's hopeful,
daily-renewal symbols) in the brand palette — deep indigo night warming into
saffron at the horizon. There is intentionally **no bell** (too temple-coded).

## Files
- `MakeIcon.swift` → `Svara/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`
  (1024×1024, opaque, no alpha — App Store compliant).
- `MakeMark.swift` → `Svara/Resources/Assets.xcassets/SvaraMark.imageset/*`
  (white sun+lotus logomark on transparent, for use over the dawn gradient in-app).

## Regenerate
```sh
swift design/MakeIcon.swift Svara/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png

swift design/MakeMark.swift /tmp/mark.png
sips -z 600 600 /tmp/mark.png --out Svara/Resources/Assets.xcassets/SvaraMark.imageset/SvaraMark@3x.png
sips -z 400 400 /tmp/mark.png --out Svara/Resources/Assets.xcassets/SvaraMark.imageset/SvaraMark@2x.png
sips -z 200 200 /tmp/mark.png --out Svara/Resources/Assets.xcassets/SvaraMark.imageset/SvaraMark.png
```

## Palette (from `SvaraTheme`)
indigo `#1E1B4B` · saffron `#F5A23B` · lotus `#E0729A` · cream `#FBF4E8`
