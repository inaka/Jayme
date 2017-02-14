// Jayme
// Creatable.swift
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

/// A repository that is capable of creating entities
public protocol Creatable: Repository {
    associatedtype EntityType: DictionaryInitializable, DictionaryRepresentable
    var backend: URLSessionBackend { get }
}

public extension Creatable {
    
    /// Requests an entity to be created in the backend.
    /// Returns a `Future` with the created entity or a `JaymeError`.
    public func create(_ entity: EntityType) -> Future<EntityType, JaymeError> {
        let path = self.name
        return self.backend.future(path: path, method: .POST, parameters: entity.dictionaryValue)
            .andThen { DataParser().dictionary(from: $0.0) }
            .andThen { EntityParser().entity(from: $0) }
    }
    
    /// Requests entities to be created in the backend.
    /// Returns a `Future` with the created entities or a `JaymeError`.
    public func create(_ entities: [EntityType]) -> Future<[EntityType], JaymeError> {
        let path = self.name
        let parameters = entities.map { $0.dictionaryValue }
        return self.backend.future(path: path, method: .POST, parameters: parameters)
            .andThen { DataParser().dictionaries(from: $0.0) }
            .andThen { EntityParser().entities(from: $0) }
    }
    
}
