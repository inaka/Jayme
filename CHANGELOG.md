# Change Log

All notable changes to this project will be documented in this file. `Jayme` adheres to [Semantic Versioning](http://semver.org/).

---

### 2.x Releases

- `2.0.x` Releases - [2.0.0](#200)

### 1.x Releases

- `1.0.x` Releases - [1.0.1](#101) | [1.0.2](#102) | [1.0.3](#103) | [1.0.4](#104) 

---

## 2.0.0

- `path` variable has been renamed to `name` in `Repository` protocol declaration. (Issue [#17](https://github.com/inaka/Jayme/issues/17))
- `ServerBackend` protocol has been renamed to `NSURLSessionBackend`. (Issue [#18](https://github.com/inaka/Jayme/issues/18))
- `ServerBackendConfiguration` has been renamed to `NSURLSessionBackendConfiguration`. (Issue [#18](https://github.com/inaka/Jayme/issues/18))
- `ServerBackendError` has been renamed to `JaymeError`. (Issue [#21](https://github.com/inaka/Jayme/issues/21))
- `ServerRepository` has been renamed to `CRUDRepository`. (Issue [#19](https://github.com/inaka/Jayme/issues/19))
- `StringDictionary` typealias has been removed. (Issue [#28](https://github.com/inaka/Jayme/issues/28))
- `init?(dictionary)` has been replaced by `init(dictionary) throws` in `DictionaryInitializable` protocol. (Issue [#25](https://github.com/inaka/Jayme/issues/25))

---

## 1.0.4

- Added support for custom logging function injection.
- Fixed access level related issues.

## 1.0.3

- Lowered deployment target to `8.0` since `9.3` was unnecessary.

## 1.0.2

- Moved documentation assets into a separated folder.
- Changed images references in README file; using absolute paths now in order to make them work in cocoapods documentation.

## 1.0.1

- Released on March 3rd, 2016.
