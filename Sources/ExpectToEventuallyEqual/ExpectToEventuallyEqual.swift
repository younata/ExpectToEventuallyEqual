// SPDX-License-Identifier: MIT

import XCTest

public func expectToEventuallyEqual<T: Equatable>(
    actual: () throws -> T,
    expected: T,
    timeout: TimeInterval = 1.0,
    file: StaticString = #filePath,
    line: UInt = #line,
    fail: (String, StaticString, UInt) -> Void = XCTFail
) throws {
    let runLoop = RunLoop.current
    let timeoutDate = Date(timeIntervalSinceNow: timeout)

    var lastActual = try actual()
    var tryCount = 0
    repeat {
        tryCount += 1
        if lastActual == expected {
            return
        }
        runLoop.run(until: Date(timeIntervalSinceNow: 0.01))
        lastActual = try actual()
    } while Date().compare(timeoutDate) == .orderedAscending

    fail(
        "\(messageNotEqual(T.self, expected: expected, actual: lastActual)) after \(tryCount) tries, timing out after \(timeout) seconds",
        file,
        line
    )
}

func messageNotEqual<T>(_ type: T.Type, expected: T, actual: T) -> String {
    return "Expected \(describe(type, value: expected)), but was \(describe(type, value: actual))"
}
