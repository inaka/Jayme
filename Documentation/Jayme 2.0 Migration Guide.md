# Jayme 2.0 Migration Guide

**Jayme 2.0** is the latest major release of Jayme. As a major release, following Semantic Versioning conventions, 2.0 introduces several API-breaking changes that one should be aware of.

This guide is provided in order to ease the transition of existing applications using Jayme 1.x to the latest APIs, as well as explain the design and structure of new and changed functionality.

---

### Automatically Suggested Changes

There are some compiler migration mechanisms that have been implemented in Jayme 2.0 by leveraging the `@unavailable` attribute in a `Compatibility.swift` file.

***For these changes you only have to follow the compiler suggestions and they should be applied automatically.***

For instance:

* `ServerRepository` has been renamed to `CRUDRepository`. 
  * The compiler will automatically suggest the replacement of `ServerRepository` to `CRUDRepository`.

---

### Manual Changes

However, there are some other changes that would have required overwhelming (if ever possible) mechanisms to be implemented in order to keep automatic suggestions from the compiler. In consequence, we decided not to implement them but to write them down here in a separated list.

⚠️ ***Therefore, it's up to you to perform these changes manually.***

They are listed below:

- `path` variable has been renamed to `name` in `Repository` protocol declaration (related issue: [#17](https://github.com/inaka/Jayme/issues/17)).
  - You have to change every `path` appearance in your Repositories by using `name` instead.
- `init?(dictionary: StringDictionary)` has been replaced by `init(dictionary: [String: AnyObject]) throws` (related issues: [#25](https://github.com/inaka/Jayme/issues/25), [#28](https://github.com/inaka/Jayme/issues/28)).
  - `StringDictionary` → `[String: AnyObject]` replacements should be suggested by the compiler.
  - You have to manually replace your `init?` initializers for every class or struct that conforms to `DictionaryInitializable` by its throwable equivalent.
  - You have to perform `{ throw JaymeError.ParsingError }` whenever you can't initialize a `DictionaryInitializable` object instead of performing `{ return nil }`.

---

For further documentation regarding changes, check out the **[Change Log](../Changelog.md)**.