//
//  Constructor.swift
//  Cupholder
//
//  Created by Ilya Mikhaltsou on 1/11/19.
//

import Foundation

/// Type-erased contructor
protocol AnyConstructor {
    func asTyped<T>() -> Constructor<T>
}

/// Base class of real constructing objects
public class ActualConstructor<T> {
    init() { }

    func construct(in context: Context) -> T {
        fatalError("Contructor not defined")
    }
}

class TypecastingConstructor<T, U>: ActualConstructor<T> {
    let constructor: ActualConstructor<U>
    init(other: ActualConstructor<U>) {
        constructor = other
        super.init()
    }
    override func construct(in context: Context) -> T {
        let instance = constructor.construct(in: context)
        precondition(instance is T, "Invalid types used: \(U.self) is not convertible to \(T.self)")
        return instance as! T
    }
}

/// The constructible wrapper
public protocol Constructing {
    associatedtype ConstructionType
    var actual: ActualConstructor<ConstructionType> { get }
}

/// Holds constructing objects
public struct Constructor<T>: AnyConstructor {
    func asTyped<U>() -> Constructor<U> {
        assert(U.self == T.self, "Incompatible type registered: Required type \(U.self), Got type \(T.self)")
        return self as! Constructor<U>
    }

    var actual: ActualConstructor<T>

    public init<U>(_ constructor: U) where U: Constructing, U.ConstructionType == T {
        actual = constructor.actual
    }

    public init<U>(_ constructor: U) where U: Constructing, U.ConstructionType: AnyObject {
        actual = TypecastingConstructor(other: constructor.actual)
    }

    func construct(in context: Context) -> T {
        return actual.construct(in: context)
    }
}
