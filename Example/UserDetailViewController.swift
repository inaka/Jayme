// JaymeExample
// UserDetailViewController.swift
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

import UIKit

class UserDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var user: User! {
        didSet {
            self.title = "\(user.name)'s Posts"
            self.loadPosts()
        }
    }

    // MARK: - Private
    
    private var posts = [Post]()
    
    private func loadPosts() {
        let future = PostRepository().findPostsForUser(self.user)
        future.start { result in
            switch result {
            case .Success(let posts):
                self.posts = posts
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            case .Failure(let error):
                self.showAlertControllerForError(error)
            }
        }
    }
    
    private func showAlertControllerForError(error: JaymeError) {
        let message = self.descriptionForError(error)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func descriptionForError(error: JaymeError) -> String {
        switch error {
        case .ServerError(let code):
            return "Server Error (code: \(code))"
        case .Other(let nsError):
            return nsError.localizedDescription
        default:
            return "Unexpected error"
        }
    }
    
}

extension UserDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PostTableViewCell.Identifier) as! PostTableViewCell
        cell.post = self.posts[indexPath.row]
        return cell
    }
    
}
