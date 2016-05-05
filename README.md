![Logo](https://raw.githubusercontent.com/inaka/Jayme/master/Assets/logo.png)

***The abstraction layer that eases RESTful interconnections in Swift***

------

[![Build Status](https://api.travis-ci.org/inaka/Jayme.svg)](https://travis-ci.org/inaka/Jayme) [![codecov](https://codecov.io/gh/inaka/jayme/branch/master/graph/badge.svg)](https://codecov.io/gh/inaka/jayme) [![Platform](https://img.shields.io/cocoapods/p/Jayme.svg?style=flat)](http://cocoadocs.org/docsets/Jayme) [![Twitter](https://img.shields.io/badge/twitter-@inaka-blue.svg?style=flat)](http://twitter.com/inaka)



## Overview

What's the best place to put your *entities business logic* code? What's the best place to put your *networking* code?

Jayme answers those two existencial questions by defining a straightforward and extendable architecture based on **Repositories** and **Backends**.

It provides a neat API for dealing with REST communication, leaving your `ViewControllers` out of that business by abstracting all that logic, thereby allowing them to focus on what they should do rather on how they should connect to services.

![Jayme's Architecture In A Nutshell](https://raw.githubusercontent.com/inaka/Jayme/master/Assets/architecture-diagram-1.png)



##Features

- **Protocol-Oriented**
  - Jayme has been built following the concepts of [protocol-oriented programming](https://developer.apple.com/videos/play/wwdc2015/408/), encouraging composition over inheritance whenever possible. As you will see, most of classes defined in Jayme are actually protocols.
- **Generics**
  - You will see generics almost everywhere in the library. That gives you high flexibility by leaving up to you the decision of choosing which types best fit your needs.
- **Error Handling**
  - With the aid of generics, you can implement and use your own error types.
  - Jayme Standard comes with a default list of discrete errors (defined in `ServerBackendError`) which are useful in the `ViewController` layer. 
  - The idea is that thrown error types should be discrete and grouped by different and meaningful UI scenarios. For instance, you might want to present a *"User not found. Want to invite him?"* dialog box for a specific 404 from a certain `.GET` call, or you might want to present an alert view indicating that the server is not responding properly for any 5xx error.
- **Futures / Results**
  - From experience, we've found out that the [Future Pattern](https://realm.io/news/swift-summit-javier-soto-futures/) is a very convenient way for layouting asynchronous code. Therefore, we decided that it would be *the way to go* for Jayme.
  - `Future` and `Result` appear as two cornerstone structures in Jayme's ecosystem. Make sure you're familiar with them before using the library, as they will always be involved in return types for Repository methods, meaning that they will be present in your `ViewController` layer.
- **Logs**
  - Jayme includes a practical logging mechanism that can be quickly enabled or disabled. It also allows you to set a custom logging function to use, which results very convenient if your project uses third party logging libraries like [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack).
- **Unit Tests**
  - Jayme is 100% unit-tested. This way, we ensure that the library does what it's meant to do.
  - Unit-tests are easy to implement (and, of course, encouraged) in your own repositories, backends and entities. Check out how Jayme unit tests work to see examples. You're going to encounter several fakes that are easy to reuse and adapt to your tests.
- **No Dependencies**
  - Jayme does not leverage any external dependency. We consider simplicity to be a very important concept to keep always in mind.
  - Nonetheless, we highly suggest that you integrate [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) hand in hand with Jayme, to make your life easier when it comes to fill out `init?(dictionary: StringDictionary)` methods for your Entities. You can turn a `dictionary` into a `JSON` object very quickly and parse out the relevant data easily from that point.





## Architecture

Jayme leverages the **Repository Pattern** as its main cornerstone. Its foundation provides 2 protocols to conform to: `Repository` and `Backend`, from which you will base your entities business logic.

![Jayme's Architecture Extended](https://raw.githubusercontent.com/inaka/Jayme/master/Assets/architecture-diagram-2.png)

###Entities

There's no concrete definition of any Entity in Jayme. You define them. The only restriction is that any EntityType you create should conform to these three protocols:

- `Identifiable`
  - To allow the entity to be unequivocally identified via an `id` field.
- `DictionaryInitializable`
  - To allow the entity to be initialized from a dictionary (parsed in).
  - Used in `ServerBackend` by `find` methods.
- `DictionaryRepresentable`
  - The other way around, to allow the entity to be represented with a dictionary (parsed out).
  - Used in `ServerBackend` by `create`, `update` and `delete` methods.

### The Inaka Standard

Jayme comes with a default standard implementation, which is based on the conventions that we normally follow at [Inaka](http://inaka.net/). It involves `ServerBackend`, `ServerRepository` and `ServerPagedRepository`.

You can either leverage these defaults or implement your own repositories and backends by conforming directly to the base `Repository` and `Backend` protocols provided by Jayme's foundation, skipping any of the aforementioned classes.

These default interfaces are briefly described below:

#### ServerBackend

- This class provides a backend that connects to a server using HTTP REST requests via `NSURLSession`.


- By default, it connects to `localhost:8080`, but you can change the base URL path by passing in a custom `ServerBackendConfiguration` object to its initializer. 
- You can also set custom HTTP headers to be used in the requests when initilizing your own `ServerBackendConfiguration` instance.
- You can also customize the `NSURLSession` and `HTTPResponseParser` objects that are asked upon `ServerBackend` initialization. However, doing so is discouraged; these last two parameters have been purely added there for unit-testing purposes.
- This layer returns a `Future` containing a result with either:
  - A tuple with an `NSData?` object, containing relevant data relative to the response, and a `PageInfo?` object containing pagination-related data (if there is any); or...
  - A `ServerBackendError` indicating which error was produced when performing the request.

#### *ServerRepository*

- This protocol provides a Repository with convenient CRUD-like functions that are already implemented and ready to be used in any Repository that conforms to it, such as:
  - `findAll()` for fetching all the Entities from the Repository.
  - `findByID(id)` for fetching a specific Entity matching a given `id`.
  - `create(entity)` for creating a new Entity in the Repository.
  - `update(entity)` for updating an existing Entity with its new values.
  - `delete(entity)` for deleting an existing Entity from the Repository.

#### *ServerPagedRepository*

- This protocol adds pagination-related functionality to the already known `ServerRepository`. The extra function to make use of is:
  - `findByPage(pageNumber)` for fetching a fixed amount of Entities from the Repository, corresponding to a certain page number. The amount of Entities fetched per page is configured in your concrete repository by providing a `pageSize` property.
- The followed pagination conventions have been based on [these standards](https://github.com/davidcelis/api-pagination).

### Your Own Standard

You can create your own repositories and backends without going through Inaka standards, and still preserving Jayme's core architecture.

See how your own repositories and backends can be plugged in directly to the base `Repository` and `Backend` protocols.

![Jayme's Architecture Customization](https://raw.githubusercontent.com/inaka/Jayme/master/Assets/architecture-diagram-3.png)



## Example

#### Creating your first Repository

Let's pretend you want to create a **User** entity that has its corresponding Repository, which will, of course, store Users.

All you have to do is create your Entity and make it conform to `Identifiable`, `DictionaryInitializable` and `DictionaryRepresentable` to match the generic `EntityType` that `ServerRepository` asks for.

Here you can see how this Entity conforms to all these protocols:

```swift
// User.swift

import Foundation
import SwiftyJSON

struct User: Identifiable {
    let id: Identifier
    let name: String
    let email: String
}

extension User: DictionaryInitializable, DictionaryRepresentable {
    
    init?(dictionary: StringDictionary) {
        let json = JSON(dictionary)
        guard let
            id = json["id"].string,
            name = json["name"].string,
            email = json["email"].string
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
```

As already suggested in this document, [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) can be used in cooperation with Jayme and your app to facilitate JSON structure conversions and casts.

Now that you've got your first entity, you just go and create your first repository, as simple as this:

```swift
// UserRepository.swift

import Foundation

class UserRepository: ServerRepository {

    typealias EntityType = User
    let backend = ServerBackend()
    let path = "users"
    
}
```

Notice three things here:

- A `typealias` is used for tying the generic `EntityType` to a concrete type (our `User`), hence letting the repository know which kind of entity it works with.
- Even though the `BackendType` is tied to `ServerBackend` at the `ServerRepository` level; since the latter is a protocol, you still have to instantiate a `ServerBackend` in your concrete repository, which needs to be a class to hold this property value.
- You have to provide the relative path where the backend is going to look for in order to work with `UserRepository`. If you do not alter the default `ServerBackendConfiguration`, the complete path with which the `ServerBackend` will work internally will be `"localhost:8080/users"`, given the relative path that was defined.

**That's it!**

With this basic configuration you're all set to perform CRUD asynchronous operations with your Users from anywhere in your app.

```swift
// UsersViewController.swift

class UsersViewController: UIViewController {

	// Fetching example
	
	func loadUsers() {
        let future = UserRepository().findAll()
        future.start() { result in
            switch result {
            case .Success(let users):
                // You've got your users fetched in this array!
                self.users = users
                self.tableView.reloadData()
            case .Failure(let error):
                // You've got a discrete ServerBackendError indicating what happened
                self.showAlertControllerForError(error)
            }
        }
    }
    
    // ...
}
```

See how **simple and neat** the code ended up being in your `ViewController` layer. That's the main purpose of Jayme.



#### Adding a bit of condiment to your first Repository

Of course not all the repositories are as trivial as the one we've just created. Jayme will make your life really easy when it comes to such basic repository configurations. But, what if we needed more complex stuff?

Let's suppose that now we go a step further and we pretend to add a `Post` entity in our app. We also want to add support such that we can fetch all the Posts that were created by a certain user.

This is where your architecture slightly starts to divert from Jayme basics. Basically, there are two conventional ways of achieving it. Either you:

- Add a `findPostsForUserWithID(userID)` function to your existent `UserRepository`; or...
- Create a `PostRepository` with a `findPostsHavingAuthorID(userID)` function.

The latter is preferred over the former.

So, in order to do this, you first need to define your `Post` entity, as following:

```swift
// Post.swift

import Foundation
import SwifyJSON

struct Post: Identifiable {
    let id: Identifier
    let authorID: Identifier
    let content: String
}

extension Post: DictionaryInitializable, DictionaryRepresentable {
    
    init?(dictionary: StringDictionary) {
        let json = JSON(dictionary)
        guard let
            id = json["id"].string,
            authorID = json["author_id"].string,
            content = json["content"].string
            else { return nil }
        self.id = id
        self.authorID = authorID
        self.content = content
    }
    
    var dictionaryValue: StringDictionary {
        return [
            "id": self.id,
            "author_id": self.authorID,
            "content": self.content
        ]
    }
    
}
```

And then, define your `PostRepository`, which is similar to your basic existent `UserRepository`, but adding an extra function which adds the *condiment* that you need:

```swift
class PostRepository: ServerRepository {
    
    typealias EntityType = Post
    let backend = ServerBackend()
    let path = "posts"
    
    func findPostsHavingAuthorID(authorID: Identifier) -> Future<[Post], ServerBackendError> {
        // Server-side documentation states that Posts by AuthorID are found in the "/posts/:authorID" path
        let path = self.path + "/" + authorID
        return self.backend.futureForPath(path, method: .GET, parameters: nil)
            .andThen { self.parseDataAsArray($0.0) }
            .andThen { self.parseEntitiesFromArray($0) }
    }
    
}
```

Notice here:

- This function implementation has been pretty much based on the `findAll()` function declared in an extension of `ServerRepository`, which you would want to take a look at.


- Depending on how your business rules are defined, and how your server-side contract is, you will perform different actions inside the `findPostsHavingAuthorID` function in order to get the proper posts. You could have wanted to perform a `findAll()` call, and then apply a filter to extract out those posts where `post.authorID` matched the `authorID` passed by parameter, and that could have been still perfectly valid. It's up to you.


- See how useful are the parsing methods defined in one of the `ServerRepository` extensions. You would often encounter yourself calling them for chaining asynchronous operations after a future is returned from a backend with raw data; that's why we decided to let them be `public` and not `private`.




#### Setting up a custom logging function

If you're relying on third party libraries to manage your logs, or if you have your own custom logging implementations, you can inject whatever you have so that Jayme uses it for its internal logging.

Doing so is quite straightforward, all you have to do is to set a different `loggingFunction` in the `Logger.sharedLogger` instance, which by default, uses the native `print`.

Here you have a code sample demonstrating quickly how you can achieve that:

```swift
Jayme.Logger.sharedLogger.loggingFunction = { (items: Any..., separator: String, terminator: String) -> () in
	CustomDebugLog("\(items)")
}
```




#### That's pretty much it! 

We are sure you will have to develop more complex scenarios and have bigger challenges by yourself. So, have fun! We encourage you to share anything interesting that can aport more robustness to the library. Issues and pull requests are very welcome!



## Sample Project

If you still have some hesitations about the usage of this library, there is an `Example` folder inside the repo containing a basic implementation of some repositories integrated with view controllers.

The example needs a local server to work, which you can configure really quick by doing:

```shell
cd Jayme/Example/Server
python -m SimpleHTTPServer 8080
```

Once you have the server running, all you need to do is run Jayme.



## Setup

- Jayme is available via [cocoapods](http://cocoapods.org/).
  - To install it, add this line to your `Podfile`:
    - `pod 'Jayme'`


- Remember to add an `import Jayme` statement in any source file of your project that needs to make use of the library.




## Contact Us

For **questions** or **general comments** regarding the use of this library, please use our public [hipchat room](http://inaka.net/hipchat).

If you find any **bugs** or have a **problem** while using this library, please [open an issue](https://github.com/inaka/Jayme/issues/new) in this repo (or a pull request).

You can also check all of our open-source projects at [inaka.github.io](inaka.github.io).