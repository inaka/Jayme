// Jayme
// JaymeError.swift
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

/// Discrete enumeration representing the possible errors that can be produced within the backend and repository layers.
public enum JaymeError: Error {
    
    /* Request could not be built. Can be due to a bad formed URL or non-JSON-parsable parameters
     */
    case badRequest
    
    /* No error was produced, but either no valid response was found or the returned `NSData` object is corrupted or unexpected
     */
    case badResponse
    
    /* Returned `NSData` object could not be parsed as expected
     */
    case parsingError
    
    /* Server returned 404 or 410. Useful as a special case in `.findByID()` requests
     */
    case notFound
    
    /* Server returned any 5xx status code
     Contains the 5xx status code
     */
    case serverError(statusCode: Int)
    
    /* Server returned any other status code that is not contemplated as a special case
     */
    case undefined(statusCode: Int)
    
    /* An error occurred while sending the request (e.g. a timeout or no internet connection)
     Contains the `Error` with the information about it
     */
    case other(Error)
    
}
