// Jayme
// ServerRepository.swift
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

/// Provides a Repository with convenient implementations to be used in most of basic repositories that follow Inaka's conventions.
protocol ServerRepository: Repository {
    var backend: ServerBackend { get }
}

// MARK: - Basic Methods API

extension ServerRepository {
    
    /// Returns a `Future` containing an array of all the `Entity` objects in the repository.
    func findAll() -> Future<[EntityType], ServerBackendError> {
        let path = self.path
        return self.backend.futureForPath(path, method: .GET, parameters: nil)
            .andThen { self.parseDataAsArray($0.0) }
            .andThen { self.parseEntitiesFromArray($0) }
    }
    
    /// Returns a `Future` containing the `Entity` matching the `id`.
    /// Watch out for a `.Failure` case with `EntityNotFound` error.
    func findByID(id: Identifier) -> Future<EntityType, ServerBackendError> {
        let path = self.pathForID(id)
        return self.backend.futureForPath(path, method: .GET, parameters: nil)
            .andThen { self.parseDataAsDictionary($0.0) }
            .andThen { self.parseEntityFromDictionary($0) }
    }
    
    /// Creates the entity in the repository. Returns a `Future` with the `Void` result or a `ServerBackendError`
    func create(entity: EntityType) -> Future<Void, ServerBackendError> {
        let path = self.pathForID(entity.id)
        return self.backend.futureForPath(path, method: .POST, parameters: entity.dictionaryValue)
            .map { _ in return }
    }
    
    /// Updates the entity in the repository. Returns a `Future` with the `Void` result or a `ServerBackendError`
    func update(entity: EntityType) -> Future<Void, ServerBackendError> {
        let path = self.pathForID(entity.id)
        return self.backend.futureForPath(path, method: .PUT, parameters: entity.dictionaryValue)
            .map { _ in return }
    }
    
    /// Deletes the entity from the repository. Returns a `Future` with the `Void` result or a `ServerBackendError`
    func delete(entity: EntityType) -> Future<Void, ServerBackendError> {
        let path = self.pathForID(entity.id)
        return self.backend.futureForPath(path, method: .DELETE, parameters: entity.dictionaryValue)
            .map { _ in return }
    }
    
    // MARK: - Private
    
    internal func pathForID(id: Identifier) -> Path {
        return self.path + "/" + id
    }
    
}

// MARK: - Parsing

/// Provides convenient parsing implementations
extension ServerRepository {
    
    /// Parses data structured as array of dictionaries, and returns a corresponding `Future`
    func parseDataAsArray(maybeData: NSData?) -> Future<[StringDictionary], ServerBackendError> {
        return Future() { completion in
            guard let
                data = maybeData,
                result = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments),
                array = result as? [StringDictionary]
                else {
                    completion(.Failure(.BadResponse))
                    return
            }
            completion(.Success(array))
        }
    }
    
    /// Parses data structured as a single dictionary, and returns a corresponding `Future`
    func parseDataAsDictionary(maybeData: NSData?) -> Future<StringDictionary, ServerBackendError> {
        return Future() { completion in
            guard let
                data = maybeData,
                result = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments),
                dictionary = result as? StringDictionary
                else {
                    completion(.Failure(.BadResponse))
                    return
            }
            completion(.Success(dictionary))
        }
    }
    
    /// Converts an array of dictionaries to an array of Entities, and returns a corresponding `Future`
    func parseEntitiesFromArray(array: [StringDictionary]) -> Future<[EntityType], ServerBackendError> {
        return Future() { completion in
            let entities = array.flatMap({ EntityType(dictionary: $0) })
            completion(.Success(entities))
        }
    }
    
    /// Converts a single dictionary to an Entity, and returns a corresponding `Future`
    func parseEntityFromDictionary(dictionary: StringDictionary) -> Future<EntityType, ServerBackendError> {
        return Future() { completion in
            guard let entity = EntityType(dictionary: dictionary) else {
                completion(.Failure(.ParsingError))
                return
            }
            completion(.Success(entity))
        }
    }
    
}

