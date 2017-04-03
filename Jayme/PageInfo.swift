// Jayme
// PageInfo.swift
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

/// Structure for holding pagination-related information.
public struct PageInfo {
    
    /// The current page number.
    public let number: Int
    
    /// The number of items per page.
    public let size: Int
    
    /// The total amount of items.
    public let total: Int
    
    /// Public initializer
    public init(number: Int, size: Int, total: Int) {
        self.number = number
        self.size = size
        self.total = total
    }
    
}

public extension PageInfo {
    
    /// Helper computed property for knowing whether or not there are more items to be fetched.
    public var more: Bool {
        return self.size * self.number < self.total
    }
    
}
