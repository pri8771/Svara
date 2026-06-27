import Foundation

/// Type-safe navigation targets reachable from the mandir home. The home is the
/// only anchor; every other screen is a push onto this stack (no tab bar).
enum MandirRoute: Hashable {
    case fulfillSankalp(Sankalp)
    case reflect(Sankalp)
    case newSankalp
    case memories
    case newMemory
    case sacredTime
    case settings
    case devotionalIdentity
}
