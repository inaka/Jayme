// Jayme
// DataParser.swift
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

/// Provides functions to be used within a repository for converting dictionaries into entities an chaining their results with convenient `Future` functions (e.g. `map` and `andThen`).
open class DataParser {
    
    /// Public default initializer.
    public init() { }
    
    /// Returns a `Future` containing a dictionary initialized with the optional data passed by parameter, or `JaymeError.badResponse` if the dictionary can't be initialized from that data.
    open func dictionary(from possibleData: Data?) -> Future<[AnyHashable: Any], JaymeError> {
        return Future() { completion in
            guard let
                data = possibleData,
                let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let dictionary = result as? [AnyHashable: Any]
                else {
                    completion(.failure(.badResponse))
                    return
            }
            completion(.success(dictionary))
        }
    }
    
     /// Returns a `Future` containing an array of dictionaries initialized with the optional data passed by parameter, or `JaymeError.badResponse` if the array can't be initialized from that data.
    open func dictionaries(from possibleData: Data?) -> Future<[[AnyHashable: Any]], JaymeError> {
        return Future() { completion in
            guard
                let data = possibleData,
                let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let array = result as? [[AnyHashable: Any]]
                else {
                    completion(.failure(.badResponse))
                    return
            }
            completion(.success(array))
        }
    }
    
}
