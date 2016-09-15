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

/// Structure representing the future value of an asynchronous computation.
public struct Future<T, E: Error> {
    
    public typealias FutureResultType = Result<T, E>
    public typealias FutureCompletion = (FutureResultType) -> ()
    public typealias FutureAsyncOperation = (@escaping FutureCompletion) -> ()
    
    /// Parameters:
    /// - `operation`: The asynchronous operation going to be performed.
    public init(operation: @escaping FutureAsyncOperation) {
        self.operation = operation
    }
    
    /// Begins the asynchronous operation and executes the `completion` closure once it has been completed.
    public func start(_ completion: @escaping FutureCompletion) {
        self.operation() { result in
            completion(result)
        }
    }
    
    // MARK: - Private
    
    fileprivate let operation: FutureAsyncOperation
    
}

public extension Future {
    
    /// Maps the result of a future by performing `f` onto the result.
    public func map<U>(_ f: @escaping (T) -> U) -> Future<U, E> {
        return Future<U, E>(operation: { completion in
            self.start { result in
                switch result {
                case .success(let value): completion(.success(f(value)))
                case .failure(let error): completion(.failure(error))
                }
            }
        })
    }
    
    /// Maps the result of a future by performing `f` onto the result, returning a new `Future` object.
    /// Useful for chaining different asynchronous operations that are dependent on each other's results.
    public func andThen<U>(_ f: @escaping (T) -> Future<U, E>) -> Future<U, E> {
        return Future<U, E>(operation: { completion in
            self.start { firstFutureResult in
                switch firstFutureResult {
                case .success(let value): f(value).start(completion)
                case .failure(let error): completion(.failure(error))
                }
            }
        })
    }
    
}
