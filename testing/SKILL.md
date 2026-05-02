---
name: testing
description: Unit testing workflow for the Care iOS codebase - enforces deterministic tests (no Task.sleep, Thread.sleep, asyncAfter, Task.yield), preferred async patterns (direct await, XCTestExpectation with mock callbacks, Combine sinks), and mock-via-protocol pattern. Use before writing or modifying unit tests, or when reviewing test code for flakiness.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Testing Workflow

Use this command when writing or modifying unit tests.

## Runtime First

Always wait for runtime validation before writing unit tests. After implementing a feature or fix, ask if runtime testing has been completed. Do not proceed to unit tests until the user confirms the changes work correctly at runtime.

## Test Scope: Relevant Scenarios Only

Only write tests for meaningful, real-world scenarios. Do not write tests for edge cases, unlikely inputs, or defensive checks that don't reflect actual usage. Each test should justify its existence by covering behavior that matters to the feature.

## Core Principle: Deterministic Tests

Tests must be deterministic — they should produce the same result every run, regardless of timing, thread scheduling, or system load. A test that passes 99% of the time is a flaky test, and flaky tests erode trust in the suite.

**Never use any of these in tests:**
- `Task.sleep` / `Thread.sleep` / `usleep`
- `DispatchQueue.main.asyncAfter` / `DispatchQueue.global().async`
- `Task.yield()`
- Any arbitrary delay or engineered race condition

These are all timing-dependent and will eventually flake. There are no exceptions.

## Async Testing Patterns

### Preferred: Direct `await`
If the method is `async`, just `await` it directly — this is the simplest and most deterministic approach:
```swift
func test_removeService_shouldMarkInactive() async {
    mockService.categoriesToReturn = [expectedDTO]
    await sut.removeService(service)
    XCTAssertTrue(sut.currentServices.first?.rateLines.allSatisfy { !$0.isActive } ?? false)
}
```

### When direct `await` isn't possible: Expectations with callbacks
For fire-and-forget methods (non-async methods that launch internal Tasks), use `XCTestExpectation` with mock callbacks:
```swift
func test_fetchData_shouldPopulateResults() async {
    let expectation = XCTestExpectation(description: "fetch completed")
    mockService.onFetchCalled = { expectation.fulfill() }

    sut.fetchData()

    await fulfillment(of: [expectation], timeout: 2.0)
    XCTAssertEqual(sut.results.count, 1)
}
```

### When observing @Published properties: Combine expectations
```swift
func test_isLoaded_shouldBecomeTrue() async {
    let expectation = XCTestExpectation(description: "isLoaded becomes true")
    let cancellable = sut.$isLoaded
        .dropFirst()
        .filter { $0 }
        .sink { _ in expectation.fulfill() }

    sut.fetchData()

    await fulfillment(of: [expectation], timeout: 2.0)
    cancellable.cancel()
    XCTAssertTrue(sut.isLoaded)
}
```

## Mock Pattern

Test through the public interface. Avoid adding test-only hooks or exposing internals just for testing. Mocks should conform to existing protocols:

```swift
class MockSomeService: SomeServiceProtocol {
    var onMethodCalled: (() -> Void)?
    var resultToReturn: SomeResult = .default
    var errorToThrow: Error?

    func someMethod() async throws -> SomeResult {
        onMethodCalled?()
        if let error = errorToThrow { throw error }
        return resultToReturn
    }
}
```
