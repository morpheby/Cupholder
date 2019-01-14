# Cupholder

A lightweight Dependency Injection framework for Swift.

## Features

* Property injection
* Constructor injection (through factories)
* Fully tested (near 100% test coverage)
* Context-aware dependency resolution
* Simple to use
* Swift 4.2

## How to install

### Cocoa Pods

Coming soon…

### Swift Package Manager

Add the dependency to your project:

```
.package(url: "https://github.com/morpheby/Cupholder.git", from: "1.0.0")
```

### From source

Compile and use as framework.

## Usage

### Register a class to protocol

```
  Inject<MyServiceType>().registration = Constructor(Shared({
      return MyDefaultService()
  }))
```

### Use injection

Option 1: Use property injection with saved context

```
class MyDefaultOtherService: MyOtherServiceType, Injection {
    var injector: Injector!

    lazy var a: MyServiceType = injector.instanceOf().inject()
}
```

Option 2: Use property injection without saving context

```
class MyDefaultOtherService: MyOtherServiceType {
    var a: MyServiceType = InstanceOf<MyServiceType>().inject()
    // Don't use lazy in this case, since it will break DI context
```

Option 3: Use injection from context

```

class MyDefaultOtherService: MyOtherServiceType, Injection {
    var injector: Injector!

    func myType() -> MyServiceType {
        return injector.instanceOf().inject()
    }
}
```

Option 4: Injection from factory

```
class MyDefaultOtherService: MyOtherServiceType, Injection {
    var a: MyServiceType
    
    init(a: MyServiceType) { ... }
}

...

  Inject<MyOtherServiceType>().registration = Constructor(Shared({ injector in
      return MyDefaultOtherService(a: injector.instanceOf().inject())
  }))
```


> Note: You can freely combine those methods as you need

### Update context

You can update current DI context with a custom object (i.e. some shared response from server):

```

class MyDefaultOtherService: MyOtherServiceType, Injection {
    var injector: Injector!

    func invokeSomething() -> MyServiceType {
        let myResponse = something.makeResponse()
        injector.inject().registration = Constructor(Instance<MyResponseType>(myResponse))
        return injector.instanceOf().inject()
    }
}
```

### DI types

Supported types of registration are the following:

* **Unique**:
  Object is created each time an injection is requested
* **Shared**:
  Object is created only if it's currently doesn't already exist in scope (i.e. it is stored as a `weak var`). Otherwise a new
  object is created
* **Singleton**:
  Object is created upon registration and later always reused
* **Lazy Singleton**:
  Object is created upon first use and later always reused
* **Instance**:
  Same as Singleton, only the object is passed itself to the registration (i.e. no factory is provided and the object itself
  bypasses dependency injection)

