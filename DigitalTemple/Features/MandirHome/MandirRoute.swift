import Foundation

/// Type-safe navigation targets pushed from the mandir home. The altar and its
/// ritual modes (offer / reflect / thread) live in-place on the home; these are
/// the deeper screens reached by a push. (No tab bar.)
enum MandirRoute: Hashable {
    case fulfillSankalp(Sankalp)
    case newSankalp
    case sacredTime
    case settings
    case devotionalIdentity
}
