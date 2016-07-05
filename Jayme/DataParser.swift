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

/// Provides functions to be used within a repository for converting Dictionaries into Entities an chaining their results with `Future` convenient functions (e.g. `map` and `andThen`
public class DataParser {
    
    /// Public default initializer
    public init() { }
    
    /// Returns a `Future` containing a dictionary initialized with the optional data passed by parameter, or `JaymeError.BadResponse` if the dictionary can't be initialized from that data.
    public func dictionaryFromData(maybeData: NSData?) -> Future<[String: AnyObject], JaymeError> {
        return Future() { completion in
            guard let
                data = maybeData,
                result = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments),
                dictionary = result as? [String: AnyObject]
                else {
                    completion(.Failure(.BadResponse))
                    return
            }
            completion(.Success(dictionary))
        }
    }
    
     /// Returns a `Future` containing an array of dictionaries initialized with the optional data passed by parameter, or `JaymeError.BadResponse` if the array can't be initialized from that data.
    public func dictionariesFromData(maybeData: NSData?) -> Future<[[String: AnyObject]], JaymeError> {
        return Future() { completion in
            guard let
                data = maybeData,
                result = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments),
                array = result as? [[String: AnyObject]]
                else {
                    completion(.Failure(.BadResponse))
                    return
            }
            completion(.Success(array))
        }
    }
    
}
