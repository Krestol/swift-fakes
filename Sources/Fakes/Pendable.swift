import Foundation

/// Default values for use with Pendable.
public final class PendableDefaults: @unchecked Sendable {
    public static let shared = PendableDefaults()
    private let lock = NSLock()

    public init() {}

    public static var delay: TimeInterval {
        get {
            PendableDefaults.shared.delay
        }
        set {
            PendableDefaults.shared.delay = newValue
        }
    }

    private var _delay: TimeInterval = 1
    public var delay: TimeInterval {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _delay
        }
        set {
            lock.lock()
            _delay = newValue
            lock.unlock()
        }
    }
}

/// Pendable represents the 2 states that an asynchronous call can be in
///
/// - `pending`, the state while waiting for some asynchronous call to finish
/// - `finished`, the state once an asynchronous call has finished.
///
/// Oftentimes, async calls also throw. For that, use the `ThrowingPendable` type.
/// `ThrowingPendable` is a typealias for when `Value` is
/// a `Result<Success, Failure>`.
///
/// Pendable is a static value, there is no way to dynamically resolve a Pendable.
/// This is because to allow you to resolve the call whenever you want is
/// the equivalent of forcing Swift Concurrency to wait until some other function returns.
/// Which is possible, but incredibly tricky and very prone to deadlocks.
/// Using a Static value for Pendable enables us to essentially cheat that.
public enum Pendable<Value> {
    /// an in-progress call state
    ///
    /// The associated value is a fallback value.
    case pending(fallback: Value)

    /// a finished call state
    case finished(Value)

    public func resolve(
        delay: TimeInterval = PendableDefaults.delay
    ) async -> Value {
        switch self {
        case .pending(let fallback):
            _ = try? await Task.sleep(
                nanoseconds: UInt64(1_000_000_000 * delay)
            )
            return fallback
        case .finished(let value):
            return value
        }
    }

    public func resolve<Success, Failure: Error>(
        delay: TimeInterval = PendableDefaults.delay
    ) async throws -> Success where Value == Result<Success, Failure> {
        switch self {
        case .pending(let fallback):
            _ = try? await Task.sleep(
                nanoseconds: UInt64(1_000_000_000 * delay)
            )
            return try fallback.get()
        case .finished(let value):
            return try value.get()
        }
    }
}

public typealias ThrowingPendable<
    Success,
    Failure: Error
> = Pendable<Result<Success, Failure>>

extension Pendable: Sendable where Value: Sendable {}
