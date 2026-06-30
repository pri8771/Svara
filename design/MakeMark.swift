import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import Foundation

// Svara logomark: a rising sun (rays + disc) above a lotus, in white on a
// transparent background, for use over the brand's dawn gradient in-app.

let S: CGFloat = 600
let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: Int(S), height: Int(S),
                          bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError() }
func white(_ a: CGFloat) -> CGColor { CGColor(colorSpace: cs, components: [1,1,1,a])! }

ctx.clear(CGRect(x: 0, y: 0, width: S, height: S))

let sun = CGPoint(x: S/2, y: S*0.60)
let r: CGFloat = S*0.150

// Rays
ctx.setLineCap(.round)
let rays = 12
for i in 0..<rays {
    let ang = (CGFloat(i)/CGFloat(rays)) * .pi*2 + .pi/2
    if sin(ang) < -0.2 { continue }
    let inner = r*1.34, outer = r*1.74
    ctx.setStrokeColor(white(0.92))
    ctx.setLineWidth(S*0.020)
    ctx.move(to: CGPoint(x: sun.x + cos(ang)*inner, y: sun.y + sin(ang)*inner))
    ctx.addLine(to: CGPoint(x: sun.x + cos(ang)*outer, y: sun.y + sin(ang)*outer))
    ctx.strokePath()
}

// Sun disc
ctx.setFillColor(white(1.0))
ctx.addEllipse(in: CGRect(x: sun.x - r, y: sun.y - r, width: r*2, height: r*2))
ctx.fillPath()

// Lotus below the sun
func petal(_ c: CGPoint, _ angle: CGFloat, _ len: CGFloat, _ w: CGFloat, _ a: CGFloat) {
    ctx.saveGState(); ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: angle)
    let p = CGMutablePath()
    p.move(to: .zero)
    p.addQuadCurve(to: CGPoint(x: 0, y: len), control: CGPoint(x: w, y: len*0.55))
    p.addQuadCurve(to: .zero, control: CGPoint(x: -w, y: len*0.55))
    ctx.addPath(p); ctx.setFillColor(white(a)); ctx.fillPath(); ctx.restoreGState()
}
let base = CGPoint(x: S/2, y: S*0.300)
petal(base, 1.16, S*0.115, S*0.050, 0.80)
petal(base, -1.16, S*0.115, S*0.050, 0.80)
petal(base, 0.60, S*0.150, S*0.056, 0.90)
petal(base, -0.60, S*0.150, S*0.056, 0.90)
petal(base, 0.0, S*0.168, S*0.060, 1.0)

guard let img = ctx.makeImage() else { fatalError() }
let out = URL(fileURLWithPath: CommandLine.arguments[1])
let dest = CGImageDestinationCreateWithURL(out as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
print("Wrote \(out.path)")
