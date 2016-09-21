# Jayme 3.0 Migration Guide

**Jayme 3.0** is the latest major release of Jayme. As a major release, following Semantic Versioning conventions, 3.0 introduces several API-breaking changes that one should be aware of.

This guide is provided in order to ease the transition of existing applications using Jayme 2.x to the latest APIs, as well as explain the design and structure of new and changed functionality.

---

**All of these changes were applied in order to follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) that came up with [Swift 3](https://apple.github.io/swift-evolution/).**

---

### Automatically Suggested Changes

There are some compiler migration mechanisms that have been implemented in Jayme 2.0 by leveraging the `@unavailable` attribute in a `Compatibility.swift` file.

***For these changes you only have to follow the compiler suggestions and they should be applied automatically.***

For instance:

* `NSURLSessionBackend` has been renamed to `URLSessionBackend`. 
  * The compiler will automatically suggest the replacement of `NSURLSessionBackend` to `URLSessionBackend`.

---

### Manual Changes

However, there are some other changes that would have required overwhelming (if ever possible) mechanisms to be implemented in order to keep automatic suggestions from the compiler. In consequence, we decided not to implement them.

⚠️ ***Therefore, it's up to you to perform these changes manually.***

---

For further documentation regarding changes, check out the **[Change Log](../Changelog.md)**.