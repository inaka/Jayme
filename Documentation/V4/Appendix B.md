# Appendix B: Unit-test your repositories

Once you have learned how to [write your own custom functions](Appendix%20A.md) for your repositories, your next step is to keep your code covered by unit-tests.

Any custom function that you write for your repositories can be tested using three kind of tests. Learning how to write these tests may be tough, but once again, once you've climbed the steep hill, this process becomes a piece of cake.

---

### Three Kind Of Tests

When you write a new function in your repository, you should implement these three kind of tests:

1. **Call To Backend:**
  - The call to the backend sends the proper **path**, **HTTP method** and **parameters**.
2. **Success Response Scenarios:**
  - Upon any successful response, your **entities are parsed properly**.
3. **Failure Response Scenarios:**
  - Upon any failure scenario, a **proper error is returned**.

> Notice that the first item always involves **one test**, whereas the second one and the third one **may involve more than one test each**, depending on how many successful and failure scenarios your function expects.

Taking the example from the [Appendix A: Write your own custom functions](Appendix%20A.md), let's add unit-tests to this custom function to cover all the paths.

This is the custom function we want to test:

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

---

### 1. Call To Backend

First, let's write a test that proves that the proper **path**, **HTTP method** and **parameters** are sent to the backend.

In order to do so, you'll need a [mock object](https://en.wikipedia.org/wiki/Mock_object) to simulate a `URLSessionBackend`. You will need two things from this *fake* backend for all of your tests:

* This *fake* backend can be asserted to analyze what arguments have been passed to its `future(path:method:parameters:)` function, in case it's called.
* This *fake* backend doesn't connect to an actual server, but instead returns local *fake* results that we can configure easily.

We'll focus on the second item for this *call to backend* kind of test.

Good news is that these tools were already written when creating the default `Creatable`, `Readable`, `Updatable` and `Deletable` functions' tests. So, you can actually grab the fake backend from [here](https://github.com/inaka/Jayme/blob/master/JaymeTests/TestingBackend.swift). 

If you analyze the `TestingBackend` code, you can realize how it works. This class overrides the `future(path:method:parameters:)` function so that:

- Instead of connecting to an actual server, it stores the passed in arguments in instance variables.
- Instead of waiting for a completion closure from a `URLSessionTask`, it uses the completion block that you set in the `completion` variable, which can be fired whenever you want.

Then, what you need to do is setup your repository (class under test) to use a `TestingBackend` instead of a `URLSessionBackend`.

If you go to the `PostRepository` definition, you have to replace this:

```swift
class PostsRepository: Readable {
    typealias EntityType = Post
    let backend = URLSessionBackend.myAppBackend()
    let name = "posts" 
}
```

with this:

```swift
class PostsRepository: Readable {
    typealias EntityType = Post
    let backend: URLSessionBackend
    let name = "posts"
    
    init(backend: URLSessionBackend = .myAppBackend()) {
        self.backend = backend
    }
}
```

This enables dependency injection for the `backend` variable. Now, you can setup a custom backend if you specify it in the `PostRepository` intializer. Notice that if you don't pass in a backend, by default it uses `.myAppBackend()`, so you don't need to modify your source code.

Now, let's write the first test for our `read(userId:)` function:

```swift
func testReadWithUserIdCallToBackend() {
    let backend = TestingBackend()
    let repository = PostsRepository(backend: backend)
    let _ = repository.read(userId: "123")
    XCTAssertEqual(backend.path, "users/123/posts")
    XCTAssertEqual(backend.method, .GET)
    XCTAssertNil(backend.parameters)
}
```

Nice. This test uses a `TestingBackend` to ensure that all the arguments sent to the `future(path:method:parameters:)` function are correct.

---

###2. Success Response Scenarios

The next test to prepare is one that ensures that, upon a successful response, the method returns a proper `Future` including a `.success` result that contains the entities parsed properly.

This test is a bit more complex than the previous one. First, we have to simulate a successful response which includes a JSON containing the entities in the format that we expect they would arrive from the server. In order to simulate this response, we create a completion closure that we then pass in to the `TestingBackend` instance.

```swift
let simulatedCompletion = { completion in
    let json = [["id": "1", "content": "hello world"],
                ["id": "2", "content": "another post"]]
    let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    completion(.success((data, nil))) // (!)
}
let backend = TestingBackend()
backend.completion = simulatedCompletion
```

> `(!)` notice that in this line, the completion closure is called, sending a `.success` result case, that includes the `(Data?, PageInfo?)` tuple object that the backend works with. In this case, we send the data we've just created from our simulated JSON, and a `nil` pagination information object, as we don't care about pagination here.

Now it's time to complete our test. Since this fake completion closure we just created is asynchronous, we have to work with [expectations](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/04-writing_tests.html) from XCTest.

This is the complete test we need:

```swift
func testReadWithUserIdSuccessCallback() {

    self.continueAfterFailure = false // (!)

    let backend = TestingBackend()
    backend.completion = { completion in
    let json = [["id": "1", "content": "hello world"],
                ["id": "2", "content": "another post"]]
        let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        completion(.success((data, nil)))
    }
    
    let expectation = self.expectation(description: "Expected 2 posts to be parsed properly")
    
    let repository = PostsRepository(backend: backend)
    let future = repository.read(userId: "_")
    future.start() { result in
        guard case .success(let posts) = result
            else { XCTFail(); return }
        XCTAssertEqual(posts.count, 2) // (!)
        XCTAssertEqual(posts[0].id, "1")
        XCTAssertEqual(posts[0].content, "hello world")
        XCTAssertEqual(posts[1].id, "2")
        XCTAssertEqual(posts[1].content, "another post")
        expectation.fulfill()
    }
    
    self.waitForExpectations(timeout: 3) { error in
        if let _ = error { XCTFail() }
    }
}
```

> `(!)` Notice that by setting `.continueAfterFailure` to `false`, we can avoid *index out of bounds* crashes and make the test fail gracefully if the array doesn't contain the expected number of items.

There's another successful scenario that can be tested, which is what happens if there are no posts for that user. This alternative will end up in something like:

```swift
func testReadWithUserIdSuccessCallbackNoPosts() {

    self.continueAfterFailure = false

    let backend = TestingBackend()
    backend.completion = { completion in
    let json = []
        let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        completion(.success((data, nil)))
    }
    
    let expectation = self.expectation(description: "Expected an empty array")
    
    let repository = PostsRepository(backend: backend)
    let future = repository.read(userId: "_")
    future.start() { result in
        guard case .success(let posts) = result
            else { XCTFail(); return }
        XCTAssertEqual(posts.count, 0)
        expectation.fulfill()
    }
    
    self.waitForExpectations(timeout: 3) { error in
        if let _ = error { XCTFail() }
    }
}
```

---

### 3. Failure Response Scenarios

Last cases to cover are those where a `.failure` result is expected. There are several scenarios that can lead to that:

- The `user_id` doesn't exist, the server returns a `404` error.
- Any server error
- Bad responses from the server

By using the same simulation logic as before, we can quickly build these three tests.

The `user_id` doesn't exist, the server returns a `404` error. The backend is returning a `JaymeError.notFound` error, we expect our function to return a `.failure` result case, with a `JaymeError.notFound` error:

```swift
func testReadWithUserIdFailureNotFoundCallback() {

    self.backend.completion = { completion in
        let error = JaymeError.notFound
        completion(.failure(error))
    }
    
    let expectation = self.expectation(description: "Expected JaymeError.notFound")
    
    let future = self.repository.read(userId: "_")
    future.start() { result in
        guard 
            case .failure(let error) = result,
            case .notFound = error
            else { XCTFail(); return }
        expectation.fulfill()
    }
    
    self.waitForExpectations(timeout: 3) { error in
        if let _ = error { XCTFail() }
    }
    
}
```

> Notice that you don't need to test how the `URLSessionBackend` parses the `404` status code to a `JaymeError.notFound`. This test is already implemented in [URLSessionBackendTests](https://github.com/inaka/Jayme/blob/master/JaymeTests/URLSessionBackendTests.swift).

The server sends a response that cannot be interpreted by the client. The backend is sending `.success` with corrupted data, we expect our function to return a `.failure` result case, with a `JaymeError.badResponse` error:

```swift
func testReadWithUserIdFailureBadResponseCallback() {

    self.backend.completion = { completion in
        let corruptedData = Data()
        completion(.success((corruptedData, nil)))
    }
    
    let expectation = self.expectation(description: "Expected to get a JaymeError.badResponse")
    
    let future = self.repository.read(userId: "_")
    future.start() { result in
        guard
            case .failure(let error) = result,
            case .badResponse = error
            else { XCTFail(); return }
        expectation.fulfill()
    }
    
    self.waitForExpectations(timeout: 3) { error in
        if let _ = error { XCTFail() }
    }
    
}
```

The server returns a server error. The backend is sending `.failure` with `JaymeError.serverError`, we expect our function to also return a `.failure` result case, with a `JaymeError.serverError`, that matches the same `statusCode` that came from the backend:

```swift
func testReadWithUserIdFailureServerErrorCallback() {

    self.backend.completion = { completion in
        let error = JaymeError.serverError(statusCode: 500)
        completion(.failure(error))
    }
    
    let expectation = self.expectation(description: "Expected JaymeError.notFound")
    
    let future = self.repository.read(userId: "_")
    future.start() { result in
        guard
            case .failure(let error) = result,
            case .serverError(let statusCode) = error
            else { XCTFail(); return }
        XCTAssertEqual(statusCode, 500)
        expectation.fulfill()
    }
    
    self.waitForExpectations(timeout: 3) { error in
        if let _ = error { XCTFail() }
    }
    
}
```

Awesome. Failure scenarios have been covered.

---

### Well Done!

Now, you should be able to unit-test custom functions in your repositories and have your business logic covered.

It's recommended that you take a look at [Jayme's test classes](https://github.com/inaka/Jayme/tree/master/JaymeTests) for further reference. Every default CRUD function has its tests there. Also, you may find yourself having to write your own custom backend implementations, or parsers, or whatnot. Take a look at those test harnesses to understand how these Jayme classes were unit-tested.