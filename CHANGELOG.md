# Change Log

All notable changes to this project will be documented in this file. `Jayme` adheres to [Semantic Versioning](http://semver.org/).

---

### 2.x Releases

- `2.0.x` Releases - [2.0.0](#200)

### 1.x Releases

- `1.0.x` Releases - [1.0.1](#101) | [1.0.2](#102) | [1.0.3](#103) | [1.0.4](#104) 

---

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
- `ServerBackendError` has been renamed to `JaymeError`. (Issue [#21](https://github.com/inaka/Jayme/issues/21))

#### Entity related changes

- `init?(dictionary)` has been replaced by `init(dictionary) throws` in `DictionaryInitializable` protocol. (Issue [#25](https://github.com/inaka/Jayme/issues/25))
- `StringDictionary` typealias has been removed. (Issue [#28](https://github.com/inaka/Jayme/issues/28))
- `Identifier` typealias has been removed. (Issue [#22](https://github.com/inaka/Jayme/issues/22))
- `id` variable in `Identifiable` protocol no longer works with `Identifier`. Now it uses an associated type (`IdentifierType`) for that. (Issue [#22](https://github.com/inaka/Jayme/issues/22))

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
