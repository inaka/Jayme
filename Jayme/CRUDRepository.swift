// Jayme
// CRUDRepository.swift
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

/// Provides a Repository with convenient implementations ready to be used in any repository that needs basic CRUD functionality.
public protocol CRUDRepository: Repository {
    var backend: NSURLSessionBackend { get }
}

// MARK: - Basic Methods API

public extension CRUDRepository {
    
    /// Returns a `Future` containing an array of all the `Entity` objects in the repository.
    public func findAll() -> Future<[EntityType], JaymeError> {
        let path = self.name
        return self.backend.futureForPath(path, method: .GET, parameters: nil)
            .andThen { DataParser().dictionariesFromData($0.0) }
            .andThen { EntityParser().entitiesFromDictionaries($0) }
    }
    
    /// Returns a `Future` containing the `Entity` matching the `id`.
    /// Watch out for a `.Failure` case with `EntityNotFound` error.
    public func findByID(id: EntityType.IdentifierType) -> Future<EntityType, JaymeError> {
        let path = self.pathForID(id)
        return self.backend.futureForPath(path, method: .GET, parameters: nil)
            .andThen { DataParser().dictionaryFromData($0.0) }
            .andThen { EntityParser().entityFromDictionary($0) }
    }
    
    /// Creates the entity in the repository. Returns a `Future` with the `Void` result or a `JaymeError`
    public func create(entity: EntityType) -> Future<Void, JaymeError> {
        let path = self.pathForID(entity.id)
        return self.backend.futureForPath(path, method: .POST, parameters: entity.dictionaryValue)
            .map { _ in return }
    }
    
    /// Updates the entity in the repository. Returns a `Future` with the `Void` result or a `JaymeError`
    public func update(entity: EntityType) -> Future<Void, JaymeError> {
        let path = self.pathForID(entity.id)
        return self.backend.futureForPath(path, method: .PUT, parameters: entity.dictionaryValue)
            .map { _ in return }
    }
    
    /// Deletes the entity from the repository. Returns a `Future` with the `Void` result or a `JaymeError`
    public func delete(entity: EntityType) -> Future<Void, JaymeError> {
        let path = self.pathForID(entity.id)
        return self.backend.futureForPath(path, method: .DELETE, parameters: entity.dictionaryValue)
            .map { _ in return }
    }
    
    // MARK: - Private
    
    private func pathForID(id: EntityType.IdentifierType) -> Path {
        return "\(self.name)/\(id)"
    }
    
}
