// Jayme
// Repository.swift
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

/// Abstraction that represents a repository of a certain kind of entities.
public protocol Repository {
    
    /// The backend type going to be used in the repository.
    associatedtype BackendType: Backend
    
    /// The `Backend` that the repository will use for performing asynchronous operations.
    /// Classes conforming to `Repository` must provide it.
    var backend: BackendType { get }
    
    /// A name that refers to the group of entities associated with the repository (e.g. `"users"`).
    /// Classes conforming to `Repository` must provide this name.
    /// This name will usually be used for composing paths (e.g. `"localhost:8080/users").
    var name: String { get }

}
