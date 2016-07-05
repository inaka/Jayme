// Jayme
// Logger.swift
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

/// Class for managing internal logging
public class Logger {
    
    /// Singleton shared instance
    public static let sharedLogger = Logger()
    
    /// Switch for enabling or disabling Jayme's logs
    public var enableLogs = true
    
    /// Function to be used for logging; defaulted to `print`
    public var loggingFunction: (items: Any..., separator: String, terminator: String) -> () = print
    
    // MARK: - Private
    
    internal var requestCounter = 0
    internal func log(items: Any..., separator: String = " ", terminator: String = "\n") {
        if self.enableLogs {
            self.loggingFunction(items: items, separator: separator, terminator: terminator)
        }
    }
    
}
