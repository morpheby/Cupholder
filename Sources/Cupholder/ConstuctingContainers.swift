//
//  ConstuctingContainers.swift
//  Cupholder
//
//  Created by Ilya Mikhaltsou on 1/11/19.
//

import Foundation

fileprivate func injectionHelper<T>(_ instance: inout T, in context: Context) {
    if var injection = instance as? Injection {
        injection.injector = Injector(context: context)
        instance = injection as! T
    }
}

fileprivate func factoryWrapper<T>(factory: () -> T, in context: Context) -> T {
    return ContextHolder.instance.withContext(context) { (context) -> T in
        var instance = factory()
        injectionHelper(&instance, in: context)
        return instance
    }
}

public struct Instance<T>: Constructing {
    public typealias ConstructionType = T

    private class ActualWrapper: ActualConstructor<T> {
        var singletonInstance: T

        init(instance: T) {
            singletonInstance = instance
            super.init()
        }

        override func construct(in _: Context) -> T {
            return singletonInstance
        }
    }

    private var wrapper: ActualWrapper

    public init(_ instance: T) {
        wrapper = ActualWrapper(instance: instance)
    }

    public var actual: ActualConstructor<T> {
        return wrapper
    }
}

public struct Singleton<T>: Constructing where T: AnyObject {
    public typealias ConstructionType = T

    private class ActualWrapper: ActualConstructor<T> {
        var singletonInstance: T

        init(instance: T) {
            singletonInstance = instance
            super.init()
        }

        override func construct(in _: Context) -> T {
            return singletonInstance
        }
    }

    private var wrapper: ActualWrapper

    public init(_ factoryClosure: () -> T) {
        let instance = factoryWrapper(factory: { () -> T in
            return factoryClosure()
        }, in: Context(parent: ContextHolder.instance.currentContext))
        wrapper = ActualWrapper(instance: instance)
    }

    public var actual: ActualConstructor<T> {
        return wrapper
    }
}

public struct LazySingleton<T>: Constructing where T: AnyObject {
    public typealias ConstructionType = T

    private class ActualWrapper: ActualConstructor<T> {
        var singletonInstance: T?
        var factory: (() -> T)?

        init(factory: @escaping () -> T) {
            self.factory = factory
            super.init()
        }

        override func construct(in context: Context) -> T {
            if let instance = singletonInstance {
                return instance
            } else if let factory = factory {
                let instance = factoryWrapper(factory: factory, in: context)
                singletonInstance = instance
                self.factory = nil
                return instance
            } else {
                fatalError("Internal inconsistency")
            }
        }
    }

    private var wrapper: ActualWrapper

    public init(_ factoryClosure: @escaping () -> T) {
        wrapper = ActualWrapper(factory: factoryClosure)
    }

    public var actual: ActualConstructor<T> {
        return wrapper
    }
}

public struct Unique<T>: Constructing where T: AnyObject {
    public typealias ConstructionType = T

    private enum Factory {
        case contextless(() -> T)
        case context((Injector) -> T)
    }

    private class ActualWrapper: ActualConstructor<T> {
        var factory: Factory

        init(factory: @escaping () -> T) {
            self.factory = .contextless(factory)
            super.init()
        }

        init(factory: @escaping (Injector) -> T) {
            self.factory = .context(factory)
            super.init()
        }

        override func construct(in context: Context) -> T {
            let instance: T
            switch factory {
            case let .contextless(factory):
                instance = factoryWrapper(factory: factory, in: context)
            case let .context(factory):
                instance = factoryWrapper(factory: {
                     return factory(Injector(context: context))
                }, in: context)
            }
            return instance
        }
    }

    private var wrapper: ActualWrapper

    public init(_ factoryClosure: @escaping () -> T) {
        wrapper = ActualWrapper(factory: factoryClosure)
    }

    public init(_ factoryClosure: @escaping (Injector) -> T) {
        wrapper = ActualWrapper(factory: factoryClosure)
    }

    public var actual: ActualConstructor<T> {
        return wrapper
    }
}

public struct Shared<T>: Constructing where T: AnyObject {
    public typealias ConstructionType = T

    private enum Factory {
        case contextless(() -> T)
        case context((Injector) -> T)
    }

    private class ActualWrapper: ActualConstructor<T> {
        var factory: Factory
        weak var sharedInstance: T?

        init(factory: @escaping () -> T) {
            self.factory = .contextless(factory)
            super.init()
        }

        init(factory: @escaping (Injector) -> T) {
            self.factory = .context(factory)
            super.init()
        }

        override func construct(in context: Context) -> T {
            if let instance = sharedInstance {
                return instance
            } else {
                let instance: T
                switch factory {
                case let .contextless(factory):
                    instance = factoryWrapper(factory: factory, in: context)
                case let .context(factory):
                    instance = factoryWrapper(factory: { () -> T in
                        factory(Injector(context: context))
                    }, in: context)
                }
                sharedInstance = instance
                return instance
            }
        }
    }

    private var wrapper: ActualWrapper

    public init(_ factoryClosure: @escaping () -> T) {
        wrapper = ActualWrapper(factory: factoryClosure)
    }

    public init(_ factoryClosure: @escaping (Injector) -> T) {
        wrapper = ActualWrapper(factory: factoryClosure)
    }

    public var actual: ActualConstructor<T> {
        return wrapper
    }
}
