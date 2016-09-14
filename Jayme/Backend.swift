// Jayme
// Backend.swift
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

public typealias Path = String

/// Abstraction for performing asynchronous operations and returning a `Future` given a path, an HTTP method and, optionally, a parameters dictionary.
public protocol Backend {
    
    /// The associated type for returning within the `Future` object in `futureForPath`
    /// Classes conforming to `Backend` must tie this associated type to a concrete type
    associatedtype BackendReturnType
    
    /// The associated type for handling errors within the `Future` object in `futureForPath`
    /// Classes conforming to `Backend` must tie this associated type to a concrete type
    associatedtype BackendErrorType: Error
    
    /// Returns a `Future` for a given path with a specific HTTPMethod, optionally passing a parameters dictionary.
    func future(path: String, method: HTTPMethodName, parameters: [String: Any]?) -> Future<BackendReturnType, BackendErrorType>
    
}
