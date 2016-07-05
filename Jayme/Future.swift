// Jayme
// Future.swift
//
// Copyright (c) 2016 Inaka - http://inaka.net/
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements. See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership. The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

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
