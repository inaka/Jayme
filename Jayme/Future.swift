// Jayme
// Future.swift
//
// Copyright (c) 2016 Inaka - http://inaka.net/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// Structure representing the future value of an asynchronous computation
public struct Future<T, E: ErrorType> {
    
    public typealias FutureResultType = Result<T, E>
    public typealias FutureCompletion = FutureResultType -> ()
    public typealias FutureAsyncOperation = FutureCompletion -> ()
    
    /// Parameters:
    /// - `operation`: The asynchronous operation going to be performed
    public init(operation: FutureAsyncOperation) {
        self.operation = operation
    }
    
    /// Begins the asynchronous operation and executes the `completion` closure once it has been completed.
    public func start(completion: FutureCompletion) {
        self.operation() { result in
            completion(result)
        }
    }
    
    // MARK: - Private
    
    private let operation: FutureAsyncOperation
    
}

public extension Future {
    
    /// Maps the result of a future by performing `f` onto the result
    public func map<U>(f: T -> U) -> Future<U, E> {
        return Future<U, E>(operation: { completion in
            self.start { result in
                switch result {
                case .Success(let value): completion(.Success(f(value)))
                case .Failure(let error): completion(.Failure(error))
                }
            }
        })
    }
    
    /// Maps the result of a future by performing `f` onto the result, returning a new `Future` object.
    /// Useful for chaining different asynchronous operations that are dependent on each other's results
    public func andThen<U>(f: T -> Future<U, E>) -> Future<U, E> {
        return Future<U, E>(operation: { completion in
            self.start { firstFutureResult in
                switch firstFutureResult {
                case .Success(let value): f(value).start(completion)
                case .Failure(let error): completion(.Failure(error))
                }
            }
        })
    }
    
}
