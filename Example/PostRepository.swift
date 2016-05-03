//
//  PostRepository.swift
//  Jayme
//
//  Created by Pablo Villar on 5/3/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import Foundation

class PostRepository: ServerRepository {
    
    typealias EntityType = Post
    let backend = ServerBackend()
    let path = "posts"
    
    func findPostsForUser(user: User) -> Future<[Post], ServerBackendError> {
        return self.findAll().map {
            $0.filter { $0.authorID == user.id }
        }
    }
    
}