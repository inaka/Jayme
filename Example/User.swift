// JaymeExample
// User.swift
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

struct User: Identifiable {
    let id: Identifier
    let name: String
    let email: String
}

extension User: DictionaryInitializable, DictionaryRepresentable {
    
    init?(dictionary: StringDictionary) {
        guard let
            id = dictionary["id"] as? String,
            name = dictionary["name"] as? String,
            email = dictionary["email"] as? String
            else { return nil }
        self.id = id
        self.name = name
        self.email = email
    }
    
    var dictionaryValue: StringDictionary {
        return [
            "id": self.id,
            "name": self.name,
            "email": self.email
        ]
    }
    
}
