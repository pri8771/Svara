import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import Foundation

// Svara app icon — a calm dawn: an indigo night sky warming into saffron at the
// horizon, a rising cream sun with gentle rays, and a stylised lotus on the
// water. Brand palette; sunrise + lotus are canonical Svara symbols (no bell).

let S: CGFloat = 1024
let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: Int(S), height: Int(S),
                          bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
    fatalError("ctx")
}

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: cs, components: [r/255, g/255, b/255, a])!
}

// Opaque base (no alpha for App Store).
ctx.setFillColor(rgb(251, 244, 232))
ctx.fill(CGRect(x: 0, y: 0, width: S, height: S))

// --- Dawn sky gradient (top indigo -> warm saffron near horizon) ---
let skyColors = [
    rgb(24, 21, 64),    // deep indigo (top)
    rgb(58, 47, 110),   // indigo
    rgb(123, 78, 138),  // indigo->lotus
    rgb(224, 114, 154), // lotus
    rgb(245, 162, 59),  // saffron (near horizon)
    rgb(248, 196, 120)  // warm glow at horizon
] as CFArray
let skyStops: [CGFloat] = [0.0, 0.30, 0.50, 0.66, 0.82, 1.0]
let horizonY: CGFloat = S * 0.40
if let sky = CGGradient(colorsSpace: cs, colors: skyColors, locations: skyStops) {
    ctx.saveGState()
    ctx.clip(to: CGRect(x: 0, y: horizonY, width: S, height: S - horizonY))
    ctx.drawLinearGradient(sky,
        start: CGPoint(x: 0, y: S),
        end: CGPoint(x: 0, y: horizonY),
        options: [])
    ctx.restoreGState()
}

// --- Foreground / water (horizon down) ---
let waterColors = [
    rgb(245, 162, 59),  // saffron at the waterline
    rgb(224, 127, 28),  // saffronDeep
    rgb(150, 70, 40)     // deep warm shadow at the very bottom
] as CFArray
if let water = CGGradient(colorsSpace: cs, colors: waterColors, locations: [0.0, 0.5, 1.0]) {
    ctx.saveGState()
    ctx.clip(to: CGRect(x: 0, y: 0, width: S, height: horizonY))
    ctx.drawLinearGradient(water,
        start: CGPoint(x: 0, y: horizonY),
        end: CGPoint(x: 0, y: 0),
        options: [])
    ctx.restoreGState()
}

let sunCenter = CGPoint(x: S/2, y: horizonY + S*0.300)
let sunR: CGFloat = S * 0.132

// --- Soft glow behind the sun ---
let glowColors = [rgb(255, 244, 214, 0.95), rgb(255, 244, 214, 0.0)] as CFArray
if let glow = CGGradient(colorsSpace: cs, colors: glowColors, locations: [0.0, 1.0]) {
    ctx.saveGState()
    ctx.clip(to: CGRect(x: 0, y: horizonY, width: S, height: S - horizonY))
    ctx.drawRadialGradient(glow,
        startCenter: sunCenter, startRadius: sunR * 0.6,
        endCenter: sunCenter, endRadius: sunR * 3.4,
        options: [])
    ctx.restoreGState()
}

// --- Rays (gentle, evenly spaced, fading upward) ---
ctx.saveGState()
ctx.setLineCap(.round)
let rayCount = 12
for i in 0..<rayCount {
    let ang = (CGFloat(i) / CGFloat(rayCount)) * .pi * 2 + .pi/2
    // Only draw rays that point upward/outward (above the horizon arc).
    let dy = sin(ang)
    if dy < -0.15 { continue }
    let inner = sunR * 1.30
    let outer = sunR * (1.62 + 0.10 * cos(CGFloat(i)))
    let p0 = CGPoint(x: sunCenter.x + cos(ang) * inner, y: sunCenter.y + sin(ang) * inner)
    let p1 = CGPoint(x: sunCenter.x + cos(ang) * outer, y: sunCenter.y + sin(ang) * outer)
    let alpha: CGFloat = 0.55 + 0.25 * max(0, dy)
    ctx.setStrokeColor(rgb(255, 248, 224, alpha))
    ctx.setLineWidth(S * 0.012)
    ctx.move(to: p0); ctx.addLine(to: p1); ctx.strokePath()
}
ctx.restoreGState()

// --- The sun disc ---
ctx.saveGState()
let discColors = [rgb(255, 253, 248), rgb(255, 234, 196)] as CFArray
if let disc = CGGradient(colorsSpace: cs, colors: discColors, locations: [0.0, 1.0]) {
    ctx.addEllipse(in: CGRect(x: sunCenter.x - sunR, y: sunCenter.y - sunR, width: sunR*2, height: sunR*2))
    ctx.clip()
    ctx.drawRadialGradient(disc,
        startCenter: CGPoint(x: sunCenter.x, y: sunCenter.y + sunR*0.3), startRadius: 0,
        endCenter: sunCenter, endRadius: sunR,
        options: [])
}
ctx.restoreGState()

// --- A stylised lotus on the water, centred under the sun ---
func petal(center c: CGPoint, angle: CGFloat, length: CGFloat, width: CGFloat, color: CGColor) {
    ctx.saveGState()
    ctx.translateBy(x: c.x, y: c.y)
    ctx.rotate(by: angle)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addQuadCurve(to: CGPoint(x: 0, y: length), control: CGPoint(x: width, y: length*0.55))
    path.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: -width, y: length*0.55))
    ctx.addPath(path)
    ctx.setFillColor(color)
    ctx.fillPath()
    ctx.restoreGState()
}

let lotusBase = CGPoint(x: S/2, y: horizonY + S*0.004)
let petalColor = rgb(255, 250, 241)
let petalColorSide = rgb(255, 238, 214)
let petalColorOuter = rgb(252, 224, 186)
// soft shadow under the lotus on the water
ctx.saveGState()
ctx.setFillColor(rgb(150, 70, 40, 0.22))
ctx.addEllipse(in: CGRect(x: S/2 - S*0.20, y: horizonY - S*0.028, width: S*0.40, height: S*0.040))
ctx.fillPath()
ctx.restoreGState()
// outermost petals
petal(center: lotusBase, angle: 1.18, length: S*0.120, width: S*0.050, color: petalColorOuter)
petal(center: lotusBase, angle: -1.18, length: S*0.120, width: S*0.050, color: petalColorOuter)
// side petals
petal(center: lotusBase, angle: 0.62, length: S*0.150, width: S*0.056, color: petalColorSide)
petal(center: lotusBase, angle: -0.62, length: S*0.150, width: S*0.056, color: petalColorSide)
// center petal
petal(center: lotusBase, angle: 0.0, length: S*0.168, width: S*0.060, color: petalColor)

// A calm reflection of the sun on the water.
ctx.saveGState()
ctx.clip(to: CGRect(x: 0, y: 0, width: S, height: horizonY - S*0.02))
let reflColors = [rgb(255, 246, 220, 0.28), rgb(255, 246, 220, 0.0)] as CFArray
if let refl = CGGradient(colorsSpace: cs, colors: reflColors, locations: [0,1]) {
    ctx.drawRadialGradient(refl,
        startCenter: CGPoint(x: S/2, y: horizonY), startRadius: 0,
        endCenter: CGPoint(x: S/2, y: horizonY), endRadius: S*0.34, options: [])
}
ctx.restoreGState()

// --- Export PNG ---
guard let image = ctx.makeImage() else { fatalError("image") }
let outURL = URL(fileURLWithPath: CommandLine.arguments[1])
guard let dest = CGImageDestinationCreateWithURL(outURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("dest")
}
CGImageDestinationAddImage(dest, image, nil)
CGImageDestinationFinalize(dest)
print("Wrote \(outURL.path)")
