// Jayme
// Compatibility.swift
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

// FIXME: Fix this file for Swift 3.0

/// This file is provided with the aim of providing compatibility between library versions.

/// ServerBackend -> URLSessionBackend
//@available(*, unavailable, renamed : "URLSessionBackend")
//public typealias ServerBackend = URLSessionBackend
//
///// ServerBackendConfiguration -> URLSessionBackendConfiguration
//@available(*, unavailable, renamed : "URLSessionBackendConfiguration")
//public typealias ServerBackendConfiguration = URLSessionBackendConfiguration
//
///// ServerBackendError -> JaymeError
//@available(*, unavailable, renamed : "JaymeError")
//public typealias ServerBackendError = JaymeError
//
///// ServerRepository -> CRUDRepository
//@available(*, unavailable, renamed : "CRUDRepository")
//public typealias ServerRepository = CRUDRepository
//
///// StringDictionary -> [String: AnyObject]
//@available(*, unavailable, renamed: "[String: AnyObject]")
//public typealias StringDictionary = [String: AnyObject]
//
///// ServerPagedRepository -> PagedRepository
//@available(*, unavailable, renamed : "PagedRepository")
//public typealias ServerPagedRepository = PagedRepository
//
///// Identifier -> IdentifierType: CustomStringConvertible
//@available(*, unavailable, message : "Replace `Identifier` with any type that conforms to `CustomStringConvertible`.")
//public typealias Identifier = String
