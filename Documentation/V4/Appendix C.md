# Appendix C: Configure your own logging function

By default, Jayme prints logs using the native `print` function from Swift.

```swift
["Jayme: Request #0 | URL: http://localhost:8080/users | method: GET"]
["Jayme: Response #0 | Success"]
["Jayme: Request #1 | URL: http://localhost:8080/posts | method: GET"]
["Jayme: Response #1 | Success"]
...
```


This function can be replaced with any other function that you want, as long as it matches the signature: `(_ items: [Any], _ separator: String, _ terminator: String) -> ()`

This is useful if you are using third party libraries for logging, like [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack).

There is an easy and convenient way to inject your own logging function, by setting the `loggingFunction` variable from the `Logger.sharedLogger` singleton, by passing in a closure, like this:

```swift
Jayme.Logger.sharedLogger.loggingFunction = { (items: Any..., separator: String, terminator: String) -> () in
    DDLogInfo("\(items)") // replace with any logging function that you need
}
```

Happy logging!
