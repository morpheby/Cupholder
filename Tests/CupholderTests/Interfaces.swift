//
//  Interfaces.swift
//  CupholderTests
//
//  Created by Ilya Mikhaltsou on 1/11/19.
//

import Foundation

protocol PTest_A {
    func f() -> String
}

protocol PTest_B: class {
    func f() -> String
}

protocol PTest_C {
    func f() -> PTest_A
    func g() -> PTest_B
}

protocol PTest_D {
    func f() -> PTest_A
    func g() -> PTest_C
}
