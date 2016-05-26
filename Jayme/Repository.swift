// Jayme
// Repository.swift
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


/// Abstraction for representing a Repository of a certain kind of Entities
public protocol Repository {
        
    /// The Entity type going to be used in the Repository
    /// Classes conforming to `Repository` must tie this associated type to a concrete type
    associatedtype EntityType: Identifiable, DictionaryInitializable, DictionaryRepresentable
    
    /// The Backend type going to be used in the Repository
    associatedtype BackendType: Backend
    
    /// The Backend that the repository will use for performing asynchronous operations
    /// Classes conforming to `Repository` must provide it
    var backend: BackendType { get }
    
    /// A name that refers to the group of entities associated with the repository (e.g. "users")
    /// Classes conforming to `Repository` must provide this name
    var name: String { get }

}
