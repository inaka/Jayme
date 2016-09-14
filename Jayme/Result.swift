// Jayme
// Result.swift
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

/// Represents the result of an asynchronous operation
public enum Result<T, E: Error> {
    
    /// Indicates that the operation has been completed successfully
    /// Wraps the relevant data associated to the operation response
    case success(T)
    
    /// Indicates that the operation could not be completed or has been completed but unsuccessfully
    /// Wraps the relevant error associated to the failure cause
    case failure(E)
    
}
