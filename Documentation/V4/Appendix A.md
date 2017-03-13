# Appendix A: Write your own custom functions

Using the [default CRUD functions](https://github.com/inaka/Jayme/blob/master/README.md#default-behavior) that Jayme provides is useful and convenient. However, it's very likely that you will often need to create your own functions for custom scenarios that are not included in the standards that Jayme works with.

Typical examples of non-standard scenarios are:

- Compound endpoints. For instance: `GET /users/:id/posts`
- Non-standard parsing. For example: A `GET` endpoint which instead of returning a JSON with an array of items, returns a JSON containing a dictionary with an `"items"` key where the items are contained.
- Different pagination standards. For instance: A scrolled-based pagination where instead of getting the pagination info in the `X-Total`, `X-Page` and `X-Per-Page` headers, you get it within the JSON body response, with `next` and `prev` fields that include links to where you can continue fetching items.

In this document, you will learn how to take advantage of [The Future Pattern](https://realm.io/news/swift-summit-javier-soto-futures/) to write your own custom functions in the same way the standard CRUD functions from Jayme are written.

Learning how to write these functions has a steep learning curve, but, once you get the hang of it, you'll see how easy it is to take advantage of the library to design well-architectured codebases while finding Jayme as a very powerful companion for any Swift project that hits RESTful APIs.

---

### Understand how `.read()` works

First, let's try to grasp how this "apparently" simple function works internally:

```swift
/// Fetches the only entity from this repository.
/// Returns a `Future` containing the only entity in the repository, or the relevant `JaymeError` that could occur.
/// Watch out for a `.failure` case with `JaymeError.entityNotFound`.

public func read() -> Future<EntityType, JaymeError> {
    let path = self.name
    return self.backend.future(path: path, method: .GET, parameters: nil)
        .andThen { DataParser().dictionary(from: $0.0) }
        .andThen { EntityParser().entity(from: $0) }
}
```

This function is mean to work for *single-entity repositories*, and it's expected to retrieve the only entity living in the repository, or a `JaymeError.notFound` error case in case there's no entity.

Now, let's analyze it line by line:

##### 1. The function declaration

``` swift
public func read() -> Future<EntityType, JaymeError> {
```
Pay special attention to the **return type**. It's a `Future`. A future represents an operation that doesn't happen immediately, i.e. an asynchronous operation. And futures are generalized: they expect you to specify 2 types they have to work with.

> Explaining how Futures work is out of the scope of this document. If you want further reference on the topic, you can check out [this talk](https://realm.io/news/swift-summit-javier-soto-futures/).

Let's have a quick look at [Future](https://github.com/inaka/Jayme/blob/master/Jayme/Future.swift):

```swift
public struct Future<T, E: Error> { 
   public typealias FutureResultType = Result<T, E>
    // ...
}
```

What you need to know: Futures work very close to another type called `Result`. The generic types `T` and `E: Error` specified in `Future` are, in the end, what the `Result` type is going to use for representing the result of the operation.

So, let's have a quick look at [Result](https://github.com/inaka/Jayme/blob/master/Jayme/Result.swift): 

```swift
/// Represents the result of an asynchronous operation.
public enum Result<T, E: Error> {
    
    /// Indicates that the operation has been completed successfully.
    /// Contains the relevant data associated to the operation response.
    case success(T)
    
    /// Indicates that the operation could not be completed or has been completed but unsuccessfully.
    /// Contains the relevant error associated to the failure cause.
    case failure(E)
    
}
```

What you need to know:

- `T` is the type that represents what you are looking for in the function. If the asynchronous operation completes successfully, you will get a `T`.
- `E` is the type used for representing an error. If the asynchronous operation fails, you will get an `E`. Also, `E` has to conform to the `Error` protocol.

Back to our function: 

```swift
public func read() -> Future<EntityType, JaymeError> {
```

- `T` is `EntityType`. If the operation succeeds, you will get an `EntityType`. Notice that `EntityType` has to be tied to a particular type when defining the repository. In the [README example](https://github.com/inaka/Jayme/blob/master/README.md#example), `EntityType` is a `User`.
- `E` is `JaymeError`. If the operation fails, you will get a `JaymeError`.

That's why, when you call this function, your code will look like this:

```swift
SomeRepository().read().start() { result in
    switch result {
    case .success(let value):
        // value is a T
    case .failure(let error):
        // error is a E
    }
}
```

Or, more specifically:

```swift
UsersRepository().read().start() { result in
    switch result {
    case .success(let user):
        // user is an EntityType, which is a User in UsersRepository
    case .failure(let error):
        // error is a JaymeError
    }
}
```

Now, if you analyze the function declaration of `readAll()`, you'll find:

```swift
public func readAll() -> Future<[EntityType], JaymeError> {
```

Which should make more sense to you now: You will get a result with either a success case with an array of entities `[EntityType]`, or a failure case with a `JaymeError`.

Now you should kind of get the magic formula in your mind on how these function signatures are written depending on what's needed.

##### 2. The call to the backend

Let's analyze this part now:

```swift
self.backend.future(path: path, method: .GET, parameters: nil)
```

If you look what this function returns, you'll find this in `URLSessionBackend`:

```swift
/// Returns a `Future` containing either:
/// - A tuple with possible `NSData` relevant to the HTTP response and a possible `PageInfo` object if there is pagination-related info associated to it.
/// - A `JaymeError` holding the error that occurred.
open func future(path: Path, method: HTTPMethodName, parameters: [AnyHashable: Any]? = nil) -> Future<(Data?, PageInfo?), JaymeError> {
    return self.createFuture(path: path, method: method, parameters: parameters)
}
```

Notice the following facts:

- The return type of this function is `Future <(Data?, PageInfo?), JaymeError>`. 
- What this function do is execute the networking code necessary to build a request, send it to the server, and parse the HTTP response turning it into a possible raw `Data` object. It also parses pagination information that may come in the response's headers. If such pagination info exists, you will get a `PageInfo` object.

Up to here, you got the data from the response. However, you can't return that data as a `Data` object directly from the `read()` function, because it has to return an `EntityType`. Here is when the parsing comes into the scenario. The idea is that your view controllers should never worry about parsing objects from JSONs and all that sauce. Instead, the parsing is done at the repository level, in these functions that we are learning to write.

##### 3. The parsing

Let's move on to the next line:

```swift
    .andThen { DataParser().dictionary(from: $0.0) }
```
You are probably wondering what this line means and how it's supposed to work. Simply put, `.andThen` is a function declared in `Future` that allows you to chain functions that return Futures.

Instead of having to unwrap the `result` as you did in your view controller, specifying what to do in each case, you can use the `.andThen` function and just pass in a transforming function that specifies what to do with the successful case of the asynchronous operation. As for the failure scenarios, they are just forwarded.

Notice that when you pass in a closure by using the braces at the end, Swift puts the arguments in annonymous variables named `$0`, `$1`, `$2`, and so on. What `$0` represents in this line is the `(Data?, PageInfo?)` tuple that is returned inside the `Future` object that we had obtained from the previous line. Since this tuple doesn't have labels, you can access its elements by using `.0` and `.1`. Therefore, `$0.0` contains the `Data?` object, and `$0.1` contains the `PageInfo?` object.

Now, notice how `$0.0` is used. Jayme provides you with elemental classes for extracting raw data into dictionaries or arrays.

If you check out `DataParser`, you'll find:

```swift
open func dictionary(from possibleData: Data?) -> Future<[AnyHashable: Any], JaymeError> { ... }
```

Notice that when you call this function, you're turning your possible `Data` object into a `[AnyHashable: Any]` dictionary, or `JaymeError` if it can't be parsed. Also, notice that the return type is... a Future!

Having this return type as a Future allows you to keep on chaining more operations using the `.andThen` function.

We're almost there. We've got a `Future<[AnyHashable: Any], JaymeError>` so far, but we need to return a `Future<EntityType, JaymeError>` out from our `read()` function.


There's one step left, which is turning this dictionary into an actual entity.

Let's observe the next, and last, line:

```swift
    .andThen { EntityParser().entity(from: $0) }
```

Now you can guess what this function does. The `$0` variable, in this case, corresponds to the `[AnyHashable: Any]` object obtained from the `Future` returned in the previous line.

Just in case, let's take a look at this definition, from `EntityParser`:

```swift
open func entity(from dictionary: [AnyHashable: Any]) -> Future<EntityType, JaymeError> { ... }
```

This function turns `[AnyHashable: Any]` into `EntityType`, while conserving the `Future` structure for chaining operations.

Notice that the only restriction for `EntityType` in `EntityParser` is the following:

```swift
open class EntityParser<EntityType: DictionaryInitializable> {
```

Yes, `EntityType` has to be `DictionaryInitializable` so that it can be initialized from a dictionary.

##### 4. Wrap up

In summary, keep on mind the following piece of code:

```swift
public func read() -> Future<EntityType, JaymeError> { 
// 1. You will get an EntityType if everything goes well

    let path = self.name
    
    return self.backend.future(path: path, method: .GET, parameters: nil)
    // 2. Up to here, you get (Data?, PageInfo?) if everything goes well
    
        .andThen { DataParser().dictionary(from: $0.0) }
        // 3. Up to here, you get [AnyHashable: Any] if everything goes well
        
        .andThen { EntityParser().entity(from: $0) }
        // 4. Finally, you get EntityType if everything goes well
        
        // 5. If something goes bad at any point, you will get a JaymeError
}
```

---

### Write your own function for a compound endpoint

Let's suppose you have set up your `PostsRepository` as following:

```swift
class PostsRepository: Readable {
    typealias EntityType = Post
    let backend = URLSessionBackend.myAppBackend()
    let name = "posts" 
}
```

And let's suppose you're performing `readAll()` and `read(id:)` operations successfully, hitting the endpoints `GET /posts` and `GET /posts/:id` respectively, without much effort.

Now, let's pretend your API allows you to get all the posts for a specific user only, through the `GET /users/:user_id/posts` endpoint. How are you supposed to hit this endpoint?

There is no default way you can do it with Jayme. You need to write your own function that hits that endpoint. Now that you've learned how these functions work internally, you should be good to go and write your own function.

This one is simple. Let's analyze the key points:

- It makes sense for this function to live in the `PostsRepository`, as you expect to get posts from it
- You need to fetch an array of entities, i.e. you expect to get `[EntityType]`
- You need the `user_id` to build the path to hit the endpoint
- You need to use the `GET` HTTP method
- You don't need to send any parameters in the request's body

With those key points in mind, we can create this function:

```swift
extension PostsRepository {

    func read(userId: String) -> Future<[EntityType], JaymeError> {
        let path = "\(users)/\(userId)/\(self.name)"
        return self.backend.future(path: path, method: .GET)
            .andThen { DataParser().dictionaries(from: $0.0) }
            .andThen { EntityParser().entities(from: $0) }
        }

}
```

Pay attention to the usage of `DataParser().dictionaries` and `EntityParser().entities`, which differ to the `DataParser().dictionary` and `EntityParser().entity` that we used in our previous example. This is because in this case you are expecting to read the JSON object as an array, not as a dictionary.

Now, you are ready to use this function in your view controller:

```swift
PostsRepository().read(userId: "123").start() { result in
    switch result {
    case .success(let posts):
        // you got posts from user with id "123"
    case .failure(let error):
        // JaymeError indicating what happened
    }
}
```

This is it! Once you understand how to take advantage of `Future`, `DataParser` and `EntityParser`, writing your own custom functions for hitting compound endpoints becomes a piece of cake.

---

### Write your own parsers

Not every API works the same. Not every API returns your objects of interest at the root level of the JSON response.

For instance, this JSON response is Jayme compliant:

```json
[ {"id": "1", "name": "Paul"},
  {"id": "2", "name": "Kate"},
  {"id": "3", "name": "Grant"} ]
```

But, what if the entities come within an *envelope* in the JSON response, like this:

```json
{ "items": [ {"id": "1", "name": "Paul"},
             {"id": "2", "name": "Kate"},
             {"id": "3", "name": "Grant"} ]
}
```

Here, you need to parse your JSON objects differently. If all the endpoints of your API behave like this, it's convenient that you create your own `DataParser` and `EntityParser` classes that have this structure in mind. Then, you can use those in any CRUD function that you write.

Have in mind that all the default functions declared in `Creatable`, `Readable`, `Updatable` and `Deletable` use the default `DataParser` and `EntityParser` classes. So, if you want to keep on using these default functions, you have to re-write them to use *your* parsers instead.

You may be wondering why aren't `DataParser` and `EntityParser` instances injected when creating a repository? This way, you would be able to still use the default `Creatable`, `Readable`, `Updatable` and `Deletable` functions with your custom parsers by just passing them in. This was a though architectural decision when developing Jayme. See, in most of scenarios where you get the entities within an envelope field, you also get extra information that's useful for parsing, like, for instance, pagination information. Extracting `DataParser` and `EntityParser` into variables at the repository level forces you to define interfaces to define what their functions are supposed to return. In Jayme's `DataParser` and `EntityParser` default classes, these return types only care about the entities. If you need different stuff, this dependency injection would be useless.

---

### This is it

Now that you've learned how to write your custom functions, which is a very powerful tool in the Jayme's world, you're encouraged to move on to the next level and apply unit-tests to any custom function that you write. This is explained in the [Appendix B: Unit-test your repositories](https://github.com/inaka/Jayme/blob/master/Documentation/V4/Appendix%20B.md).