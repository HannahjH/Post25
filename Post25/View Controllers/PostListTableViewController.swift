//
//  PostListTableViewController.swift
//  Post25
//
//  Created by Hannah Hoff on 3/18/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    
    // Add a postController property to PostListViewController and set it to an instance of PostController
    let postController = PostController()
    // Create a refreshControl property
    var refreshController = UIRefreshControl()

//Mark: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set tableView datasource and delegate
        tableView.delegate = self
        tableView.dataSource = self
        // Set up refresh control for tableView
        tableView.refreshControl = refreshControl
        // Set refreshControl to call the refreshControlPulled functino when user swiped down on the top of the tableView
        UIRefreshControl().addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        // Call the presentNewPost function
        presentNewPostAlert()
    }
    
    @objc func refreshControlPulled() {
        // Make a call to the PostController's fetchPost function
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshController.endRefreshing()
                
            }
        }
    }
    
    func reloadTableView() {
        // Reload the tableView
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.tableView.reloadData()
        }
    }
    // write a presentNewPostAlert function that initializes a UIAlertController
    func presentNewPostAlert() {
        let newPostAlertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        // add a usernameTextField and a messageTextField to the alert controller that the user will use to create their message
        var userNameTextField = UITextField()
        newPostAlertController.addTextField { (usernameTF) in
            usernameTF.placeholder = "Enter username..."
            userNameTextField = usernameTF
        }
        var messageTextField = UITextField()
        newPostAlertController.addTextField { (messageTF) in
            messageTextField.placeholder = "Enter message..."
            messageTextField = messageTF
            
        }
        // Add a Post alert action that guards for username and message text, and uses the postController to add a post with the username and text.
        let postAction = UIAlertAction(title: "Post", style: .default) { (postAction) in
            guard let username = userNameTextField.text, !username.isEmpty,
                let text = messageTextField.text, !text.isEmpty else { return }
            //in the completion handler, be sure to call reloadTableView()
            self.postController.addNewPostWith(username: username, text: text, completion: {
                self.reloadTableView()
            })
        }
        // Create a Cancel alert action, add both alert actions to the alert controller, and then present the alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        newPostAlertController.addAction(postAction)
        newPostAlertController.addAction(cancelAction)
    }
    
    // Write a presentErrorAlert function that initializes a UIALertController that says the user is missing information and should try again. Call the function if the user dones't include text in the usernameTextField of messageTextField
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Missing info", message: "Make sure both text fields are filled out", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return postController.posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        
        //Set the cell.textLabel to the text, and the cell.detailTextLabel to the author and post date
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = post.text
        
        return cell
    }
}
extension PostListTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts(reset: false) {
                //DispatchQueue.main.async {
                    self.reloadTableView()
                    
                //}
            }
        }
    }
}
