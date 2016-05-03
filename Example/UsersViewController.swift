// JaymeExample
// UsersViewController.swift
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

class UsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUsers()
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        self.loadUsers()
    }
    
    // MARK: - Private
    
    private var users = [User]()
    private var selectedUser: User?
    
    private func loadUsers() {
        UserRepository().findAll().start { result in
            switch result {
            case .Success(let users):
                self.users = users
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            case .Failure(let error):
                self.showAlertControllerForError(error)
            }
        }
    }
    
    private func showAlertControllerForError(error: ServerBackendError) {
        let message = self.descriptionForError(error)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func descriptionForError(error: ServerBackendError) -> String {
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

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(UserTableViewCell.Identifier) as! UserTableViewCell
        cell.user = self.userAtIndexPath(indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedUser = self.userAtIndexPath(indexPath)
        self.performSegueWithIdentifier("ShowUserDetail", sender: self)
    }
    
    private func userAtIndexPath(indexPath: NSIndexPath) -> User {
        return self.users[indexPath.row]
    }
    
}

extension UsersViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let controller = segue.destinationViewController as? UserDetailViewController else {
            return
        }
        controller.user = self.selectedUser!
    }
    
}
