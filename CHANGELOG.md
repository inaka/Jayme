# Change Log

All notable changes to this project will be documented in this file. `Jayme` adheres to [Semantic Versioning](http://semver.org/).

---

### 2.x Releases

- `2.0.x` Releases - [2.0.0](#200) | [2.0.1](#201)

### 1.x Releases

- `1.0.x` Releases - [1.0.1](#101) | [1.0.2](#102) | [1.0.3](#103) | [1.0.4](#104) 

---

## 2.0.1

- Respotory Create Method now sends the ID in the HTTP Parameters instead of doing it in the URL. (Issue [#63](https://github.com/inaka/Jayme/issues/63))
- Results from repositories are now returned on the main thread. (Issue [#55](https://github.com/inaka/Jayme/issues/55))
- Added `PATCH` verb in `HTTPMethodName` enumeration. (Issue [#57](https://github.com/inaka/Jayme/issues/57))

## 2.0.0

#### Repository related changes

- `path` variable has been renamed to `name` in `Repository` protocol declaration. (Issue [#17](https://github.com/inaka/Jayme/issues/17))
- `ServerRepository` has been renamed to `CRUDRepository`. (Issue [#19](https://github.com/inaka/Jayme/issues/19))
- `PagedRepository` no longer conforms to `CRUDRepository` (ex `ServerRepository`); now it conforms directly to `Repository`. (Issue [#20](https://github.com/inaka/Jayme/issues/20))
- `create(…)` and `update(…)` methods in `CRUDRepository` now return `Future<EntityType, JaymeError>` instead of `Future<Void, JaymeError>`, containing the created or updated entity. (Issue [#37](https://github.com/inaka/Jayme/issues/37))
- Convenient parsing functions have been plucked out from `CRUDRepository` (ex `ServerRepository`) and put into new classes named `DataParser` and `EntityParser`.  (Issue [#20](https://github.com/inaka/Jayme/issues/20))

#### Backend related changes

- `ServerBackend` protocol has been renamed to `NSURLSessionBackend`. (Issue [#18](https://github.com/inaka/Jayme/issues/18))
- `ServerBackendConfiguration` has been renamed to `NSURLSessionBackendConfiguration`. (Issue [#18](https://github.com/inaka/Jayme/issues/18))

#### Entity related changes

- `init?(dictionary)` has been replaced by `init(dictionary) throws` in `DictionaryInitializable` protocol. (Issue [#25](https://github.com/inaka/Jayme/issues/25))
- `StringDictionary` typealias has been removed. (Issue [#28](https://github.com/inaka/Jayme/issues/28))
- `Identifier` typealias has been removed. (Issue [#22](https://github.com/inaka/Jayme/issues/22))
- `id` variable in `Identifiable` protocol no longer works with `Identifier`. Now it uses an associated type (`IdentifierType`) for that. (Issue [#22](https://github.com/inaka/Jayme/issues/22))

#### Error handling related changes

- `ServerBackendError` has been renamed to `JaymeError`. (Issue [#21](https://github.com/inaka/Jayme/issues/21))
- `case BadURL` in `JaymeError` (ex `ServerBackendError`) has been renamed to `case BadRequest` and now it also covers a scenario where request parameters can't be parsed into a valid JSON object. (Issue [#49](https://github.com/inaka/Jayme/issues/49))

#### Bug Fixes

- `parameters` are now actually used in `NSURLSessionBackend` (ex `ServerBackend`). (Issue [#49](https://github.com/inaka/Jayme/issues/49))
- `"Content-Type": "application/json"` header is no longer duplicated in requests. (Issue [#50](https://github.com/inaka/Jayme/issues/50))

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
