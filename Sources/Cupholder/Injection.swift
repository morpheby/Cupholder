//
//  Injection.swift
//  Cupholder
//
//  Created by Ilya Mikhaltsou on 1/11/19.
//

import Foundation

/// A helper to perform injection in current context
public struct InstanceOf<T> {
    private var context: Context

    public init() {
        context = ContextHolder.instance.currentContext
    }

    init(context: Context) {
        self.context = context
    }

    public func inject() -> T {
        let constructor: Constructor<T> = context.resolve(type: .type(T.self)).asTyped()
        let childContext = Context(parent: context)
        return constructor.construct(in: childContext)
    }

    public func inject(tag: String) -> T {
        let constructor: Constructor<T> = context.resolve(type: .tag(tag, for: T.self)).asTyped()
        let childContext = Context(parent: context)
        return constructor.construct(in: childContext)
    }
}

public struct Injector {
    private var context: Context

    init(context: Context) {
        self.context = context
    }

    public func instanceOf<T>() -> InstanceOf<T> {
        return InstanceOf(context: context)
    }

    public func inject<T>() -> Inject<T> {
        return Inject(context: context)
    }
}

/// A helper to register types used in dependancy resolution
public struct Inject<T> {
    private var context: Context

    public init() {
        context = ContextHolder.instance.currentContext
    }

    init(context: Context) {
        self.context = context
    }

    public var registration: Constructor<T> {
        get {
            return context.resolve(type: .type(T.self)).asTyped()
        }
        nonmutating set {
            context.register(type: .type(T.self), as: newValue)
        }
    }

    public subscript(tag: String) -> Constructor<T> {
        get {
            return context.resolve(type: .tag(tag, for: T.self)).asTyped()
        }
        nonmutating set {
            context.register(type: .tag(tag, for: T.self), as: newValue)
        }
    }
}

public protocol Injection {
    var injector: Injector! { get set }
}
