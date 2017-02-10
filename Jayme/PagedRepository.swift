// Jayme
// PagedRepository.swift
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

/// Provides a `Repository` serving read functionality with pagination, based on Grape conventions (https://github.com/davidcelis/api-pagination)
public protocol PagedRepository: Repository {
    associatedtype EntityType: DictionaryInitializable
    /// Indicates the number of entities to be fetched per page.
    var pageSize: Int { get }
    var backend: URLSessionBackend { get }
}

public extension PagedRepository {
    
    /// Returns a `Future` containing a tuple with an array of all the entities in the repository and a `PageInfo` object containing pagination-related data.
    public func findByPage(pageNumber: Int) -> Future<([EntityType], PageInfo), JaymeError> {
        let path = self.name + "?page=\(pageNumber)&per_page=\(self.pageSize)"
        var pageInfo: PageInfo?
        let future = self.backend.future(path: path, method: .GET, parameters: nil)
            .andThen {
                pageInfo = $0.1
                return DataParser().dictionaries(from: $0.0)
            }
            .andThen {
                EntityParser<EntityType>().entities(from: $0)
            }
            .map {
                return ($0, pageInfo!)
        }
        return future
    }
    
}
