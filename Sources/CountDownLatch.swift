//
// Copyright 2020 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

import Foundation
import XCTest

/// CountDown latch to be used for asserts and expectations
public class CountDownLatch {
    private let initialCount: Int32
    
    private let queue: DispatchQueue = .init(label: "com.adobe.testutils.countdownlatch.queue")
    private var _currentCount: Int32 = 0
    private var currentCount: Int32 {
        get { queue.sync { self._currentCount } }
        set { queue.async { self._currentCount = newValue } }
    }
    
    private let waitSemaphore = DispatchSemaphore(value: 0)

    public init(_ expectedCount: Int32) {
        guard expectedCount > 0 else {
            self.initialCount = 0
            assertionFailure("CountDownLatch requires a count greater than 0")
            return
        }

        self.initialCount = expectedCount
        self.currentCount = expectedCount
    }

    public func getCurrentCount() -> Int32 {
        return currentCount
    }

    public func getInitialCount() -> Int32 {
        return initialCount
    }

    public func await(timeout: TimeInterval = 1) -> DispatchTimeoutResult {
        return currentCount > 0 ? waitSemaphore.wait(timeout: (DispatchTime.now() + timeout)) : DispatchTimeoutResult.success
    }

    public func countDown() {
        OSAtomicDecrement32(&currentCount)
        if currentCount == 0 {
            waitSemaphore.signal()
        }

        if currentCount < 0 {
            print("Count Down decreased more times than expected.")
        }
    }
}
