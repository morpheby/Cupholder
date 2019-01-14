//
//  Implementations.swift
//  CupholderTests
//
//  Created by Ilya Mikhaltsou on 1/11/19.
//

import Foundation
import Cupholder

//
// A
//

class CTest_A_1: PTest_A {
    var i = 0
    func f() -> String {
        i += 1
        return "A-1-\(i)"
    }
}

class CTest_A_2: PTest_A {
    var i = 0
    func f() -> String {
        i += 1
        return "A-2-\(i)"
    }
}

class CTest_A_3: PTest_A {
    var i = 0
    func f() -> String {
        i += 1
        return "A-3-\(i)"
    }
}

//
// B
//

class CTest_B_1: PTest_B {
    var i = 0
    func f() -> String {
        i += 1
        return "B-1-\(i)"
    }
}

class CTest_B_2: PTest_B {
    var i = 0
    func f() -> String {
        i += 1
        return "B-2-\(i)"
    }
}

//
// C
//

class CTest_C_Property: PTest_C {
    let a = InstanceOf<PTest_A>().inject()
    let b = InstanceOf<PTest_B>().inject()

    func f() -> PTest_A {
        return a
    }

    func g() -> PTest_B {
        return b
    }
}

class CTest_C_Init: PTest_C {
    let a: PTest_A
    let b: PTest_B

    init(a: PTest_A, b: PTest_B) {
        self.a = a
        self.b = b
    }

    func f() -> PTest_A {
        return a
    }

    func g() -> PTest_B {
        return b
    }
}

class CTest_C_Injector: PTest_C, Injection {
    var injector: Injector!

    lazy var a: PTest_A = injector.instanceOf().inject()
    lazy var b: PTest_B = injector.instanceOf().inject()

    func f() -> PTest_A {
        return a
    }

    func g() -> PTest_B {
        return b
    }
}

class CTest_C_InjectorDynamic: PTest_C, Injection {
    var injector: Injector!

    func f() -> PTest_A {
        return injector.instanceOf().inject()
    }

    func g() -> PTest_B {
        return injector.instanceOf().inject()
    }
}

class CTest_C_Dynamic: PTest_C {
    func f() -> PTest_A {
        return InstanceOf().inject()
    }

    func g() -> PTest_B {
        return InstanceOf().inject()
    }
}

//
// D
//

class CTest_D_Property: PTest_D {
    let a = InstanceOf<PTest_A>().inject()
    let c = InstanceOf<PTest_C>().inject()

    func f() -> PTest_A {
        return a
    }

    func g() -> PTest_C {
        return c
    }
}

class CTest_D_Init_B1: PTest_D {
    let a: PTest_A
    let c: PTest_C

    init(a: PTest_A) {
        self.a = a
        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))
        self.c = InstanceOf().inject()
    }

    func f() -> PTest_A {
        return a
    }

    func g() -> PTest_C {
        return c
    }
}

class CTest_D_Injector_B2: PTest_D, Injection {
    var injector: Injector!

    lazy var a: PTest_A = injector.instanceOf().inject()

    func f() -> PTest_A {
        return a
    }

    func g() -> PTest_C {
        injector.inject().registration = Constructor(Instance<PTest_B>(CTest_B_2()))
        return injector.instanceOf().inject()
    }
}
