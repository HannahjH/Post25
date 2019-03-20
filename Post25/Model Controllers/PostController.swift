//
//  PostController.swift
//  Post25
//
//  Created by Hannah Hoff on 3/18/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation

class PostController {
    let baseUrl = URL(string: "https://devmtn-posts.firebaseio.com/posts")
    
    // property that holds the Post objects that you pull and decode from the API...Source of Truth
    var posts: [Post] = []
    
    // method that provides a completion closure
    // Add a Bool reset parameter to the beginning of the fetchPosts function and assign a default value of true. this property will be used to determine whether you should replace the posts property of append posts to the end of it
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void) {
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        // create an unwrapped instance of the baseUrl
        guard let unwrappedUrl = baseUrl else { return }
        
        //Build a [String: String] dictionary literal of the URL Parameters you want to use
        let urlParameters = [
            // request the posts ordered by timestamp to put them in chronological order
            "orderBy": "\"timestamp\"",
            //specify that you want the list to end at the timestamp of the leaset recent Post you have already fetched. Specify that you want the posts at the end of that ordered lsit
            "endAt": "\(queryEndInterval)",
            // specify that you want the last 15 posts
            "limitToLast": "15",
            ]
        
        // Create a constant called queryItems. We need compactMap over the urlParameters, turning them into URLQuertItem's
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        // Create a variable called urlComponents of type URLComponents. Pass in the unwrapped baseURL and true as arguments to the initializer
        var urlComponents = URLComponents(url: unwrappedUrl, resolvingAgainstBaseURL: true)
        
        //set the urlComponents.queryItems to the queryItems we just created from the urlParameters
        urlComponents?.queryItems = queryItems
        
        // Create a urlConstant. Assign it the value returned form urlComponents?.url. This will need to be placed inside a guard statement to unwrap it
        guard let url = urlComponents?.url else { completion(); return }
        
        // create a getterEndpoint constant which takes the unwrapped baseUrl and appends a path extension of "json"
        // append the extension to the url not to the unwrappedURL
        let getterEndpoint = url.appendingPathComponent("json")
        
        // create a URLRequest instance and give it the getterEndpoint (it's very important that you NOT forget to set the request's hhtpMethod and httpBody)
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        // create a URLSessionDataTask instance. This method will make the network call and call the completion closer wit the Data?, URLResponse? and Error?
        // DONT FORGET TO CALL RESUME() AFTER CREATING THE INSTANCE. Do this by putting dataTask.resume() after the let dataTask = URLSession...'s CLOSING brace.
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion()
                return
            }
            
            // unwrap data if there is any. Don't forget to call completion() and return in the else block
            guard let data = data else { completion(); return }
            
            // create an instance of JSONDecoder
            let decoder = JSONDecoder()
            
            /* call decode(from:) on your JSONDecoder instance. you will need to assign the return of this function to a constant named postsDictionary. This function takes in 2 arguments: a type [String:Post (a dictionary with keys being the UUID that they are stroed under on the data bse as you will see by inspecting the json returned from the network request, and values whcih should be actual instances of post)
             */
            do {
                let postDictionary = try decoder.decode([String:Post].self, from: data)
                
                // call compactMap on this dictionary, pulling out the Post from each key-value pair. Assign the new array of posts to a variable named posts
                var posts: [Post] = postDictionary.compactMap({ $0.value })
                
                // sort these posts by timestamp in reverse chronogical order.
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                if reset {
                    // assign the array of sorted posts to self.posts and call the completion()
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
                
            } catch {
                print("\(error) \(error.localizedDescription)")
                completion()
                return
            }
        }
        dataTask.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping () -> Void){
        
        // initialize a Post object with the memberwise initializer
        let post = Post(username: username, text: text)
        var postData: Data
        do {
            
            // create an instance of JSONEncoder
            let encoder = JSONEncoder()
            
            // call encode on your instance of the JSONEncoder, passing in the post as an arguement. You will need to assign the return of this function to the postData variable you created in one of the previous steps
            postData = try encoder.encode(post)
        }catch{
            print("\(error) : \(error.localizedDescription)")
            completion()
            return
        }
        // unwrap your baseUrl
        guard let unwrappedBaseUrl = baseUrl else { completion(); return}
        
        // create a property postEndpoint that will hold the unwrappedbaseUrl with a path extension appended to it
        let postEndpoint = unwrappedBaseUrl.appendingPathExtension("json")
        
        // create an instance of URLRequest and give it the postEndpoint. (DO NOT forget to set the request's hhtpMethod -> "POST" and httpBody -> postData)
        var UrlRequest = URLRequest(url: postEndpoint)
        UrlRequest.httpMethod = "POST"
        UrlRequest.httpBody = postData
        
        // create and run (.RESUME DO NOT FORGET) A UrlSession.shared.dataTask and handle it's results
        let dataTask = URLSession.shared.dataTask(with: UrlRequest) { (data, _, error) in
            if let error = error {
                print(error)
                completion()
                return
            }
            // unwrap the data returned from the dataTask and convert the data to a string
            guard let data = data,
                let responseDataString = String(data: data, encoding: .utf8) else {
                    NSLog("Data is nil. unable to verify if data was able to be put to endpoint.")
                    completion()
                    return
            }
            // if there are no errors, log the success and the response to the console
            NSLog(responseDataString)
            
            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
    }
}
