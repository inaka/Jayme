// Jayme
// EntityParser.swift
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

/// Provides functions to be used within a repository for converting Dictionaries into Entities an chaining their results with `Future` convenient functions (e.g. `map` and `andThen`)
public class EntityParser<EntityType: DictionaryInitializable> {
    
    /// Public default initializer
    public init() { }
    
    /// Returns a `Future` containing an entity initialized with the dictionary value passed by parameter, or `JaymeError.ParsingError` if the entity could not be initialized.
    public func entityFromDictionary(dictionary: [String: AnyObject]) -> Future<EntityType, JaymeError> {
        return Future() { completion in
            guard let entity = try? EntityType(dictionary: dictionary) else {
                completion(.Failure(.ParsingError))
                return
            }
            completion(.Success(entity))
        }
    }
    
    /// Returns a `Future` containing an array of those entities that could be parsed from the `dictionaries` array passed by parameter.
    public func entitiesFromDictionaries(dictionaries: [[String: AnyObject]]) -> Future<[EntityType], JaymeError> {
        return Future() { completion in
            let entities = dictionaries.flatMap({ try? EntityType(dictionary: $0) })
            completion(.Success(entities))
        }
    }
    
}
