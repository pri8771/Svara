import Foundation
import os

/// Anything that can receive analytics events. A Firebase-backed sink can be
/// dropped in for v1 without changing any feature code.
protocol AnalyticsSink {
    func send(_ event: AnalyticsEvent)
}

/// v0 sink: structured console logging via `os.Logger`. Mirrors the shape of a
/// `logEvent(name:parameters:)` call so swapping in Firebase is mechanical.
struct ConsoleAnalyticsSink: AnalyticsSink {
    private let logger = Logger(subsystem: "com.mymandir.digitaltemple", category: "analytics")

    func send(_ event: AnalyticsEvent) {
        if event.parameters.isEmpty {
            logger.info("📿 \(event.name, privacy: .public)")
        } else {
            let params = event.parameters
                .map { "\($0.key)=\($0.value)" }
                .sorted()
                .joined(separator: ", ")
            logger.info("📿 \(event.name, privacy: .public) { \(params, privacy: .public) }")
        }
    }
}

/// App-wide analytics entry point. Inject as an `@Environment` value so views
/// and view models can `analytics.log(.somethingHappened)`.
final class AnalyticsService {
    static let shared = AnalyticsService()

    private var sinks: [AnalyticsSink]

    init(sinks: [AnalyticsSink] = [ConsoleAnalyticsSink()]) {
        self.sinks = sinks
    }

    func log(_ event: AnalyticsEvent) {
        sinks.forEach { $0.send(event) }
    }

    /// Hook for v1: `analytics.add(FirebaseAnalyticsSink())`.
    func add(_ sink: AnalyticsSink) {
        sinks.append(sink)
    }
}
