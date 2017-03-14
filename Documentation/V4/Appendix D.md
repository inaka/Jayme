![Logo](https://raw.githubusercontent.com/inaka/Jayme/master/Assets/V4/logo.png)

# Appendix D: Authenticate your requests

Most APIs implement authentication mechanisms to make sure certain information is given only to those that are supposed to have access to it.

In this document, you'll learn how to add authentication to Jayme's requests by considering the scenario where you have a login screen to authenticate your users.

---

### Add authentication to certain requests

Usually, there are certain endpoints that don't need authentication, for instance: `GET /status`, `GET /login`, etc.

There is a way to add authentication only to the endpoints that need it. The secret relies in the `URLSessionBackendConfiguration` object that is built when you initialize your custom `URLSessionBackend` instance.

So far, you should have learned how to set up a `URLSessionBackend` with your own configuration, by doing this:

```swift
extension URLSessionBackend {
    class func myAppBackend() -> URLSessionBackend {
        let basePath = "http://your_base_url_path"
        let headers = [HTTPHeader(field: "Accept", value: "application/json"),
                       HTTPHeader(field: "Content-Type", value: "application/json")]
                       // and any header you need to use
        let configuration = URLSessionBackendConfiguration(basePath: basePath, headers: headers)
        return URLSessionBackend(configuration: configuration)
    }
} 
```

What you normally need to add, in order to have authentication, is an extra HTTP header including some kind of token in your requests. Supposing your server uses a [bearer token](http://self-issued.info/docs/draft-ietf-oauth-v2-bearer.html) mechanism to authenticate requests, let's create such header:

```swift
let authenticationHeader = HTTPHeader(field: "Authorization", value: "Bearer \(token)")
```

The thing is that you need to get the `token` value from somewhere. Typically, you will obtain it upon a successful login. Make sure you store that token somehow to use it there when it's needed. Also, make sure to delete any cache as soon as the user logs out.

Now, you can add a condition that checks the authentication token exists, and, if there is one, it adds the appropriate header, as follows:

```swift
extension URLSessionBackend {
    class func myAppBackend() -> URLSessionBackend {
        let basePath = "http://your_base_url_path"
        var headers = [HTTPHeader(field: "Accept", value: "application/json"),
                       HTTPHeader(field: "Content-Type", value: "application/json")]
        if let token = Cache.sharedCache.loginToken {
            headers += [HTTPHeader(field: "Authorization", value: "Bearer \(token)"]     
        }         
        let configuration = URLSessionBackendConfiguration(basePath: basePath, headers: headers)
        return URLSessionBackend(configuration: configuration)
    }
} 
```

---

### Be careful with old references!


Notice that by using this approach, if the user logs out, but your code still has references to previously created repositories, their backends would remain on memory, keeping the authorization header that existed when they were created. Having that in mind, you have to make sure that whenever the user is logged out, any reference to any repository gets deleted. However, if you are creating repositories *on the go*, like this:

```swift
PostsRepository().readAll().start { result in 
   ...
}

PostsRepository().read(id: "123").start { result in
   ...
}

...
```

then you don't have to worry about deleting references.
