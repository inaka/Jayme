![Logo](https://raw.githubusercontent.com/inaka/Jayme/master/Assets/logo.png)

***The abstraction layer that eases RESTful interconnections in Swift***

------

[![Build Status](https://api.travis-ci.org/inaka/Jayme.svg)](https://travis-ci.org/inaka/Jayme) [![Codecov](https://codecov.io/gh/inaka/jayme/branch/master/graph/badge.svg)](https://codecov.io/gh/inaka/jayme) [![Cocoapods](https://img.shields.io/cocoapods/v/Jayme.svg)](http://cocoadocs.org/docsets/Jayme) [![Twitter](https://img.shields.io/badge/twitter-@inaka-blue.svg?style=flat)](http://twitter.com/inaka)


## Overview

What's the best place to put your *entities business logic* code? What's the best place to put your *networking* code?

Jayme answers those two existencial questions by defining a straightforward and extendable architecture based on **Repositories** and **Backends**.

It provides a neat API to deal with REST communication, leaving your `ViewControllers` out of that business by abstracting all that logic, thereby allowing them to focus on what they should do rather than on how they should connect to services.

![Jayme's Architecture In A Nutshell](https://raw.githubusercontent.com/inaka/Jayme/master/Assets/architecture-diagram-1.png)

## Migration Guides

- [Jayme 2.0 Migration Guide](https://github.com/inaka/Jayme/blob/master/Documentation/Jayme%202.0%20Migration%20Guide.md)

##Features

- **Protocol-Oriented**
  - Jayme was built following the concepts of [protocol-oriented programming](https://developer.apple.com/videos/play/wwdc2015/408/), encouraging composition over inheritance, whenever possible.
- **Generics**
  - In order to provide high flexibility, generics and associated types are present almost everywhere in the library.
- **Error Handling**
  - Jayme comes with a default list of discrete errors, which are defined in an enumeration named `JaymeError`.
  - Any `case` in `JaymeError` turns out to be useful from the `ViewController` layer's point of view. Cases represent possible, different and meaningful UI scenarios. For instance: a `5xx` server status code is represented by a `case ServerError(statusCode: Int)`.
  - If you need different error definitions, Jayme allows you to use your own Error types, with the aid of associated types.
- **Futures / Results**
  - From experience, we've found out that the [Future Pattern](https://realm.io/news/swift-summit-javier-soto-futures/) is a very convenient way for writing asynchronous code. In consequence, we decided to develop Jayme around that pattern.
  - `Future` and `Result` are two key structures in the library. You need to be familiar with them, since they are exposed on Jayme's public interfaces.
- **Logs**
  - Jayme includes a practical logging mechanism that can be quickly enabled or disabled. It also allows you to set a custom logging function, which proves quite useful if your project uses third party logging libraries, like [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack).
- **Unit Tests**
  - Jayme is 100% unit-tested.
  - Unit tests are easy to implement, and encouraged, for testing your repositories' business logic and your entities' parsing.
- **No Dependencies**
  - Jayme does not leverage any external dependency.
  - However, you can integrate JSON parsing libraries (like [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)) and plug them in easily within `DictionaryInitializable` and `DictionaryRepresentable` implementations in your entities.





## Architecture

Jayme works around the **Repository Pattern**. There are some key concepts that you need to become familiar with before using the library. These concepts can be outlined differently depending on how the pattern is implemented, as there are several ways of working with it.

Below you'll find some brief descriptions of these concepts, based on how Jayme, in particular, implements this pattern:

- A **Repository** is a collection that holds entities of a certain kind and that is capable of filtering and returning entities back based on the needs of your application. 
  - Your *business logic code* will usually live in **repositories**.
- A **Backend** is a middleman that receives concrete requests as input (e.g. a `DELETE` to `/users/123`) and it's in charge of performing networking operations to satisfy those requests, giving results back.
  - Your *networking code* will usually live in **backends**.
- An **Entity** represents a *thing* that is meaningful in your application.
  - Examples of entities are: `User`, `Post`, `Comment`, and so on.

There are other relevant concepts that deserve further explanation, which are described below:

###EntityType

Actually, you will find no definition of `Entity` in the library. Repositories use entities as an associated type (`EntityType`); the only restriction is that any entity you create should conform to these three protocols:

- `Identifiable`
  - To allow the entity to be unequivocally identified via an `id` field.
- `DictionaryInitializable`
  - To allow the entity to be initialized from a dictionary (parsed in).
- `DictionaryRepresentable`
  - To allow the entity to be represented through a dictionary (parsed out).



### Identifiers

Jayme takes a flexible approach regarding identifiers. As of Jayme 2.0, identifiers are not tied to any concrete type; it's up to you to define which kind of identifier each of your entity types will use. 

You could have entities having `Int` ids, other entities having `String`, or all of them having the same identifier type. 

You can also use your own identifier types. This is particularly useful when you have to face complex scenarios. For instance, you might need to deal with *local identifiers* vs. *server identifiers*, and you might encounter several approaches for doing so. It's recommendable then that you take a look at the example project to see a complex identifier implementation (check out `PostIdentifier`).


### Jayme Default Core

Whereas `Repository` and `Backend` definitions are only contracts, Jayme includes some structures based on them, which include default implementations (hence behaviors) that are based on conventions and standards that we normally follow at [Inaka](http://inaka.net/).

These structures are:

- `NSURLSessionBackend`: A *class* that connects to a server using `NSURLSession` mechanisms.
- `CRUDRepository`: A *protocol* that provides elemental CRUD functionality.
- `PagedRepository`: A *protocol* that provides read functionality with pagination.

Normally, you will use these. However, if you need it, you can ignore them and implement your own common behaviors by conforming directly to the base `Repository` and `Backend` contracts, as shown below:

![Jayme's Customization](https://raw.githubusercontent.com/inaka/Jayme/master/Assets/architecture-diagram-2.png)

Next, there's a detailed description of each item mentioned above:

#### NSURLSessionBackend

- This class provides a backend that connects to a server using HTTP REST requests via `NSURLSession`.


- By default, it connects to `localhost:8080`, but you can change the base URL path by passing in a custom `NSURLSessionBackendConfiguration` object to its initializer. 
- You can also set custom HTTP headers to be used in the requests when initializing your own `NSURLSessionBackendConfiguration` instance.
- You can also customize the `NSURLSession` and `HTTPResponseParser` objects that are asked upon `NSURLSessionBackend` initialization. However, we do not recommend you to do this; these last two parameters have been purely added there for unit-testing purposes.
- This layer returns a `Future` that will hold a result containing either:
  - A *tuple* with:
    - An `NSData?` object, containing relevant data relative to the response.
    - A `PageInfo?` object containing pagination-related data (if there is any).
  - Or, a `JaymeError` indicating which error was produced when performing the request.

#### *CRUDRepository*

- This protocol provides convenient CRUD-like functions that are already implemented and ready to be used in any Repository that conforms to it. They are:
  - `findAll()` for fetching all the entities from the repository.
    - Hits `/:name` using the `GET` verb.
  - `findByID(id)` for fetching a specific entity matching a given `id`. 
    - Hits `/:name/:id` using the `GET` verb.
  - `create(entity)` for creating a new entity in the repository.
    - Hits `/:name` with entity's `dictionaryValue` as parameters, using the `POST` verb.
  - `update(entity)` for updating an existing entity with its new values.
    - Hits `/:name/:id` with entity's `dictionaryValue` as parameters, using the `PUT` verb.
  - `delete(entity)` for deleting an existing entity from the repository.
    - Hits `/:name/:id` using the `DELETE` verb.

![CRUDRepository Diagram](https://raw.githubusercontent.com/inaka/Jayme/master/Assets/crud-repository-diagram.png)

- Any repository conforming to `CRUDRepository` will get these default CRUD operations for free. Besides, it can override any of these default implementations, or add his own custom functions based on business rules, as shown in this example:

![PostRepository Diagram](https://raw.githubusercontent.com/inaka/Jayme/master/Assets/post-repository-diagram.png)

#### *PagedRepository*

- This protocol provides convenient functionality for reading entities in a paginated manner. Any of your repositories can conform to it and get this function for free:
  - `findByPage(pageNumber)` for fetching a fixed amount of entities from the repository, corresponding to a certain page number. The amount of entities fetched per page is configured in your concrete repository by providing a `pageSize` property. Besides the array containing entities, you get a `PageInfo` related object as well in return.
- The followed pagination conventions are based on [Grape standards](https://github.com/davidcelis/api-pagination).



## Example

#### Create your first Repository

Let's pretend we want to create a repository that holds users and has basic CRUD functionality.

First, let's create our `User` structure and make it conform to `Identifiable`, `DictionaryInitializable` and `DictionaryRepresentable` to match the generic `EntityType` that the `Repository` contract asks for.

Here you can see how this entity conforms to all these protocols:

```swift
// User.swift

import Foundation
import SwiftyJSON

struct User: Identifiable {
    let id: String
    let name: String
    let email: String
}

extension User: DictionaryInitializable, DictionaryRepresentable {
    
    init(dictionary: [String: AnyObject]) throws {
        let json = JSON(dictionary)
        guard let
            id = json["id"].string,
            name = json["name"].string,
            email = json["email"].string
            else { throw JaymeError.ParsingError }
        self.id = id
        self.name = name
        self.email = email
    }
    
    var dictionaryValue: [String: AnyObject] {
        return [
            "id": self.id,
            "name": self.name,
            "email": self.email
        ]
    }
    
}
```

In this example, we used [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) on purpose to expose how it can be used in cooperation with Jayme and your app to facilitate JSON structure conversions and casts.

Then, let's define the `UserRepository`:

```swift
// UserRepository.swift

import Foundation

class UserRepository: CRUDRepository {

    typealias EntityType = User
    let backend = NSURLSessionBackend()
    let name = "users"
    
}
```

Notice three things here:

- A `typealias` is used for tying the generic `EntityType` to a concrete type (our `User`), hence letting the repository know which kind of entity it works with.
- `BackendType` is tied to `NSURLSessionBackend` in the `CRUDRepository` definition. However, since the latter is a protocol, you need to *instantiate* a `NSURLSessionBackend` in your concrete repository.
- The `name` that we provide usually represents the name that is given for a group of these kind of entities. That name is going to be used for composing a `path` which, at a later stage, the backend is going to hit for basic CRUD operations (e.g. `localhost:8080/users/[:id]`).

**That's it!**

With this basic configuration you're all set to perform CRUD asynchronous operations with your users from anywhere in your app.

```swift
// UsersViewController.swift

class UsersViewController: UIViewController {

	// Fetch users example
	
	func loadUsers() {
        let future = UserRepository().findAll()
        future.start() { result in
            switch result {
            case .Success(let users):
                // You've got your users fetched in this array!
                self.users = users
                self.tableView.reloadData()
            case .Failure(let error):
                // You've got a discrete JaymeError indicating what happened
                self.showAlertControllerForError(error)
            }
        }
    }
    
    // ...
}
```

Do you see how simple and neat the code ended up being in your `ViewController` layer? Well, **that's the main purpose of Jayme.**



#### Add a bit of condiment to your first Repository

Of course, not all the repositories are as trivial as the one we've just created. Jayme will make your life easier when it comes to such basic repository configurations. But, what if we need more complex stuff?

Let's suppose that now we go a step further and we pretend to add a `Post` entity in our app. We also want to add support so that we can fetch all the posts that were created by a certain user.

So, in order to do this, first you need to define your `Post` entity, as following:

```swift
// Post.swift

import Foundation
import SwifyJSON

struct Post: Identifiable {
    let id: String
    let authorID: String
    let content: String
}

extension Post: DictionaryInitializable, DictionaryRepresentable {
    
    init(dictionary: [String: AnyObject]) throws {
        let json = JSON(dictionary)
        guard let
            id = json["id"].string,
            authorID = json["author_id"].string,
            content = json["content"].string
            else { throw JaymeError.ParsingError }
        self.id = id
        self.authorID = authorID
        self.content = content
    }
    
    var dictionaryValue: [String: AnyObject] {
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
class PostRepository: CRUDRepository {
    
    typealias EntityType = Post
    let backend = NSURLSessionBackend()
    let name = "posts"
    
    func findPostsHavingAuthorID(authorID: String) -> Future<[Post], JaymeError> {
        // Considering that server-side documentation states that Posts by AuthorID are found in the "/posts/:authorID" path, we can do this:
        let path = "\(self.name)/\(authorID)"
        return self.backend.futureForPath(path, method: .GET, parameters: nil)
            .andThen { DataParser().dictionariesFromData($0.0) }
            .andThen { EntityParser().entitiesFromDictionaries($0) }
    }
    
}
```

Notice here:

- This function implementation has been pretty much based on the `findAll()` function implemented in an extension of `CRUDRepository`, which you would probably want to take a look at.


- You could consider several ways of approaching this functionality. For example:
  - Passing the whole `User` as a parameter instead of just its `id`
  - Fetching all the posts and then performing a `filter` over the result, instead of hitting a compound path (as shown in the example).
  - Defining, instead, a `findPostsForUser()` method in your `UserRepository`.
  - How you perform your solutions is actually up to you.


- See the usage of `DataParser` and `EntityParser` classes. They include parsing functions that will often be required in your repositories (e.g. converting `NSData` into an array of dictionaries, array of dictionaries into entities, etc.).




#### Set up your own logging function

If you're relying on third party libraries to manage your logs, or if you have your own custom logging implementation, you can inject it so that Jayme uses it for its internal logging.

Doing so is quite simple: You only have to set a different `loggingFunction` in the `Logger.sharedLogger` instance (which by default, uses the native `print`).

Here you have a code sample demonstrating quickly how you can achieve that:

```swift
Jayme.Logger.sharedLogger.loggingFunction = { (items: Any..., separator: String, terminator: String) -> () in
	CustomDebugLog("\(items)")
}
```




#### That's pretty much it! 

We are sure you will have to develop more complex scenarios and face bigger challenges by yourself. So, have fun! We encourage you to share anything interesting that can add more strength and flexibility to the library.



## Example Project

If you still have some hesitations about the usage of this library, there is an `Example` folder inside the repo containing a basic implementation of some repositories integrated with view controllers.

The example needs a local server to work, which you can configure really quickly by doing:

```shell
cd Jayme/Example/Server
python -m SimpleHTTPServer 8080
```



## Setup

- Jayme is available via [cocoapods](http://cocoapods.org/).
  - To install it, add this line to your `Podfile`:
    - `pod 'Jayme'`
  - Remember to add an `import Jayme` statement in any source file of your project that needs to make use of the library.




## Contact Us

For **questions** or **general comments** regarding the use of this library, please use our public [hipchat room](http://inaka.net/hipchat).

If you find any **bug**, a **problem** while using this library, or have **suggestions** that can make it better, please [open an issue](https://github.com/inaka/Jayme/issues/new) in this repo (or a pull request).

You can also check all of our open-source projects at [inaka.github.io](inaka.github.io).