// Jayme
// Readable.swift
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

/// A repository that is capable of reading entities
public protocol Readable: Repository {
    associatedtype EntityType: Identifiable, DictionaryInitializable
    var backend: URLSessionBackend { get }
}

public extension Readable {
    
    /// Returns a `Future` containing an array of all the entities in the repository, or the relevant `JaymeError` that could occur.
    public func findAll() -> Future<[EntityType], JaymeError> {
        let path = self.name
        return self.backend.future(path: path, method: .GET, parameters: nil)
            .andThen { DataParser().dictionaries(from: $0.0) }
            .andThen { EntityParser().entities(from: $0) }
    }
    
    /// Returns a `Future` containing the entity matching the `id`, or the relevant `JaymeError` that could occur.
    /// Watch out for a `.failure` case with `JaymeError.entityNotFound`.
    public func find(byId id: EntityType.IdentifierType) -> Future<EntityType, JaymeError> {
        let path = "\(self.name)/\(id)"
        return self.backend.future(path: path, method: .GET, parameters: nil)
            .andThen { DataParser().dictionary(from: $0.0) }
            .andThen { EntityParser().entity(from: $0) }
    }
    
}
