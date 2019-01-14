//
//  Context.swift
//  Cupholder
//
//  Created by Ilya Mikhaltsou on 1/11/19.
//

import Foundation

enum RegistrationType: Hashable {
    case type(Any.Type)
    case tag(String, for: Any.Type)

    var hashValue: Int {
        get {
            switch self {
            case let .type(type):
                return String(describing: type).hashValue
            case let .tag(tag, for: type):
                return "\(String(describing: type))++\(tag)".hashValue
            }
        }
    }

    static func == (lhs: RegistrationType, rhs: RegistrationType) -> Bool {
        switch (lhs, rhs) {
        case let (.type(lhsType), .type(rhsType)) where lhsType == rhsType:
            return true
        case let (.tag(lhsTag, for: lhsType), .tag(rhsTag, for: rhsType)) where lhsTag == rhsTag && lhsType == rhsType:
            return true
        default:
            return false
        }
    }
}

class Context {
    private var registrations: [RegistrationType: AnyConstructor] = [:]
    private var parentContext: Context? = nil

    init() { }

    init(parent: Context) {
        parentContext = parent
    }

    func register(type: RegistrationType, as constructor: AnyConstructor) {
        registrations[type] = constructor
    }

    func resolve(type: RegistrationType) -> AnyConstructor {
        if let registration = registrations[type] {
            return registration
        } else if let parent = parentContext {
            return ContextHolder.instance.locked {
                return parent.resolve(type: type)
            }
        } else {
            preconditionFailure("Type not found: \(type)")
        }
    }
}

class ContextHolder {
    static var instance: ContextHolder = {
        return ContextHolder()
    }()

    private static let contextThreadDictionaryKey = "ContextHolder++threadDictionary"

    private let _rootContext = Context()
    private var globalAccessLock = NSRecursiveLock()

    func locked<T>(_ closure: () -> T) -> T {
        globalAccessLock.lock()
        defer { globalAccessLock.unlock() }
        return closure()
    }

    var rootContext: Context {
        get {
            return locked {
                return _rootContext
            }
        }
    }

    init() {
        Thread.current.threadDictionary.removeObject(forKey: ContextHolder.contextThreadDictionaryKey)
    }

    private var contextChain: [Context] {
        get {
            if let chain = Thread.current.threadDictionary.object(forKey: ContextHolder.contextThreadDictionaryKey) as? [Context] {
                return chain
            } else {
                let chain: [Context]
                if Thread.current.isMainThread {
                    chain = [rootContext]
                } else {
                    chain = [Context(parent: rootContext)]
                }
                Thread.current.threadDictionary.setObject(chain, forKey: ContextHolder.contextThreadDictionaryKey as NSString)
                return chain
            }
        }
        set {
            Thread.current.threadDictionary.setObject(newValue, forKey: ContextHolder.contextThreadDictionaryKey as NSString)
        }
    }

    var currentContext: Context {
        return contextChain.last!
    }

    func push(context: Context) {
        contextChain.append(context)
    }

    func pop(context: Context) {
        guard let topContext = contextChain.popLast() else {
            fatalError("Internal inconsistency")
        }
        assert(context === topContext, "Internal inconsistency")
    }

    func withContext<T>(_ context: Context, do closure: (Context) -> T) -> T {
        push(context: context)
        defer { pop(context: context) }
        return closure(context)
    }
}
