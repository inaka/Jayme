// Jayme
// CRUDRepository.swift
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

/// Provides a `Repository` with convenient implementations ready to be used in any repository that needs basic CRUD functionality.
public protocol CRUDRepository: Repository {
    var backend: URLSessionBackend { get }
}

// MARK: - Basic Methods API

public extension CRUDRepository {
    
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
        let path = self.path(for: id)
        return self.backend.future(path: path, method: .GET, parameters: nil)
            .andThen { DataParser().dictionary(from: $0.0) }
            .andThen { EntityParser().entity(from: $0) }
    }
    
    /// Creates the entity in the repository. Returns a `Future` with the created entity or a `JaymeError`.
    public func create(_ entity: EntityType) -> Future<EntityType, JaymeError> {
        let path = self.name
        return self.backend.future(path: path, method: .POST, parameters: entity.dictionaryValue)
            .andThen { DataParser().dictionary(from: $0.0) }
            .andThen { EntityParser().entity(from: $0) }
    }
    
    /// Updates the entity in the repository. Returns a `Future` with the updated entity or a `JaymeError`.
    public func update(_ entity: EntityType) -> Future<EntityType, JaymeError> {
        let path = self.path(for: entity.id)
        return self.backend.future(path: path, method: .PUT, parameters: entity.dictionaryValue)
            .andThen { DataParser().dictionary(from: $0.0) }
            .andThen { EntityParser().entity(from: $0) }
    }
    
    /// Deletes the entity from the repository. Returns a `Future` with a `Void` result or a `JaymeError`.
    public func delete(_ entity: EntityType) -> Future<Void, JaymeError> {
        let path = self.path(for: entity.id)
        return self.backend.future(path: path, method: .DELETE, parameters: nil)
            .map { _ in return }
    }
    
    // MARK: - Private
    
    fileprivate func path(for id: EntityType.IdentifierType) -> Path {
        return "\(self.name)/\(id)"
    }
    
}
