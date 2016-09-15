// Jayme
// EntityParser.swift
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

/// Provides functions to be used within a repository for converting dictionaries into entities an chaining their results with convenient `Future`  functions (e.g. `map` and `andThen`).
open class EntityParser<EntityType: DictionaryInitializable> {
    
    /// Public default initializer.
    public init() { }
    
    /// Returns a `Future` containing an entity initialized with the dictionary value passed by parameter, or `JaymeError.parsingError` if the entity could not be initialized.
    open func entity(from dictionary: [String: Any]) -> Future<EntityType, JaymeError> {
        return Future() { completion in
            guard let entity = try? EntityType(dictionary: dictionary) else {
                completion(.failure(.parsingError))
                return
            }
            completion(.success(entity))
        }
    }
    
    /// Returns a `Future` containing an array of those entities that could be parsed from the `dictionaries` array passed by parameter. Any entity that can't be parsed is discarded in the array.
    open func entities(from dictionaries: [[String: Any]]) -> Future<[EntityType], JaymeError> {
        return Future() { completion in
            let entities = dictionaries.flatMap({ try? EntityType(dictionary: $0) })
            completion(.success(entities))
        }
    }
    
}
