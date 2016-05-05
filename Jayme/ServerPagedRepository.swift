// Jayme
// ServerPagedRepository.swift
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

/// Adds supplies onto ServerRepository for pagination management, based on Grape conventions (https://github.com/davidcelis/api-pagination)
public protocol ServerPagedRepository: ServerRepository {
    /// Indicates the number of entities to be fetched per page
    var pageSize: Int { get }
}

public extension ServerPagedRepository {
    
    /// Returns a `Future` containing a tuple with an array of all the `Entity` objects in the repository and a PageInfo object with pagination-related data
    public func findByPage(pageNumber pageNumber: Int) -> Future<([EntityType], PageInfo), ServerBackendError> {
        let path = self.path + "?page=\(pageNumber)&per_page=\(self.pageSize)"
        var pageInfo: PageInfo?
        let future = self.backend.futureForPath(path, method: .GET, parameters: nil)
            .andThen {
                pageInfo = $0.1
                return self.parseDataAsArray($0.0)
            }
            .andThen {
                self.parseEntitiesFromArray($0)
            }
            .map {
                return ($0, pageInfo!)
        }
        return future
    }
    
}

