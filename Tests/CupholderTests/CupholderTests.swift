//
//  CupholderTests.swift
//  CupholderTests
//
//  Created by Ilya Mikhaltsou on 1/11/19.
//

import XCTest
import CwlPreconditionTesting
@testable import Cupholder

final class CupholderTests: XCTestCase {

    override func setUp() {
        super.setUp()

        //  Reset context
        ContextHolder.instance = ContextHolder()
    }

    func test_basic_inject_unique() {
        // Create unique instances. Each injection should
        // produce independent instances

        Inject<PTest_A>().registration = Constructor(Unique({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Unique({
            return CTest_B_1()
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")

        XCTAssertEqual(a.f(), "A-1-2")
        XCTAssertEqual(b.f(), "B-1-2")

        let a1 = InstanceOf<PTest_A>().inject()
        let b1 = InstanceOf<PTest_B>().inject()

        XCTAssertEqual(a1.f(), "A-1-1")
        XCTAssertEqual(b1.f(), "B-1-1")

        XCTAssertEqual(a1.f(), "A-1-2")
        XCTAssertEqual(b1.f(), "B-1-2")
    }

    func test_basic_inject_shared() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")

        XCTAssertEqual(a.f(), "A-1-2")
        XCTAssertEqual(b.f(), "B-1-2")

        let a1 = InstanceOf<PTest_A>().inject()
        let b1 = InstanceOf<PTest_B>().inject()

        XCTAssertEqual(a1.f(), "A-1-3")
        XCTAssertEqual(b1.f(), "B-1-3")

        XCTAssertEqual(a1.f(), "A-1-4")
        XCTAssertEqual(b1.f(), "B-1-4")
    }

    func test_basic_inject_shared_dispose() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive.
        // Isolate scope to force object disposal

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))

        _ = {
            let a = InstanceOf<PTest_A>().inject()
            let b = InstanceOf<PTest_B>().inject()

            XCTAssertEqual(a.f(), "A-1-1")
            XCTAssertEqual(b.f(), "B-1-1")

            XCTAssertEqual(a.f(), "A-1-2")
            XCTAssertEqual(b.f(), "B-1-2")
        }()

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")

        XCTAssertEqual(a.f(), "A-1-2")
        XCTAssertEqual(b.f(), "B-1-2")
    }

    func test_basic_inject_shared_threads() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive.
        // Ensure instances are shared between threads.

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")

        XCTAssertEqual(a.f(), "A-1-2")
        XCTAssertEqual(b.f(), "B-1-2")

        let expect = expectation(description: "Async completed")
        DispatchQueue(label: "Temp").async {
            let a1 = InstanceOf<PTest_A>().inject()
            let b1 = InstanceOf<PTest_B>().inject()

            XCTAssertEqual(a1.f(), "A-1-3")
            XCTAssertEqual(b1.f(), "B-1-3")

            XCTAssertEqual(a1.f(), "A-1-4")
            XCTAssertEqual(b1.f(), "B-1-4")
            expect.fulfill()
        }
        wait(for: [expect], timeout: 10.0)
    }

    func test_nested_inject_unique() {
        // Create unique instances. Each injection should
        // produce independent instances

        Inject<PTest_A>().registration = Constructor(Unique({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Unique({
            return CTest_B_1()
        }))

        Inject<PTest_C>().registration = Constructor(Unique({
            return CTest_C_Property()
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()
        let c = InstanceOf<PTest_C>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")
        XCTAssertEqual(c.f().f(), "A-1-1")
        XCTAssertEqual(c.g().f(), "B-1-1")

        XCTAssertEqual(a.f(), "A-1-2")
        XCTAssertEqual(b.f(), "B-1-2")
        XCTAssertEqual(c.f().f(), "A-1-2")
        XCTAssertEqual(c.g().f(), "B-1-2")
    }

    func test_nested_inject_shared() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))

        Inject<PTest_C>().registration = Constructor(Shared({
            return CTest_C_Property()
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()
        let c = InstanceOf<PTest_C>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")
        XCTAssertEqual(c.f().f(), "A-1-2")
        XCTAssertEqual(c.g().f(), "B-1-2")

        XCTAssertEqual(a.f(), "A-1-3")
        XCTAssertEqual(b.f(), "B-1-3")
        XCTAssertEqual(c.f().f(), "A-1-4")
        XCTAssertEqual(c.g().f(), "B-1-4")
    }

    func test_nested_inject_shared_init() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))

        Inject<PTest_C>().registration = Constructor(Shared({ injector in
            return CTest_C_Init(a: injector.instanceOf().inject(), b: injector.instanceOf().inject())
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()
        let c = InstanceOf<PTest_C>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")
        XCTAssertEqual(c.f().f(), "A-1-2")
        XCTAssertEqual(c.g().f(), "B-1-2")

        XCTAssertEqual(a.f(), "A-1-3")
        XCTAssertEqual(b.f(), "B-1-3")
        XCTAssertEqual(c.f().f(), "A-1-4")
        XCTAssertEqual(c.g().f(), "B-1-4")
    }

    func test_nested_inject_shared_injector() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))

        Inject<PTest_C>().registration = Constructor(Shared({ injector in
            return CTest_C_Injector()
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()
        let c = InstanceOf<PTest_C>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")
        XCTAssertEqual(c.f().f(), "A-1-2")
        XCTAssertEqual(c.g().f(), "B-1-2")

        XCTAssertEqual(a.f(), "A-1-3")
        XCTAssertEqual(b.f(), "B-1-3")
        XCTAssertEqual(c.f().f(), "A-1-4")
        XCTAssertEqual(c.g().f(), "B-1-4")
    }

    func test_nested_inject_shared_injectordynamic() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))

        Inject<PTest_C>().registration = Constructor(Shared({ injector in
            return CTest_C_InjectorDynamic()
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()
        let c = InstanceOf<PTest_C>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")
        XCTAssertEqual(c.f().f(), "A-1-2")
        XCTAssertEqual(c.g().f(), "B-1-2")

        XCTAssertEqual(a.f(), "A-1-3")
        XCTAssertEqual(b.f(), "B-1-3")
        XCTAssertEqual(c.f().f(), "A-1-4")
        XCTAssertEqual(c.g().f(), "B-1-4")
    }

    func test_nested_inject_shared_injectordynamic_override() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))

        Inject<PTest_C>().registration = Constructor(Shared({ injector in
            return CTest_C_InjectorDynamic()
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_2()
        }))

        let c = InstanceOf<PTest_C>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")
        XCTAssertEqual(c.f().f(), "A-1-2")
        XCTAssertEqual(c.g().f(), "B-2-1")

        XCTAssertEqual(a.f(), "A-1-3")
        XCTAssertEqual(b.f(), "B-1-2")
        XCTAssertEqual(c.f().f(), "A-1-4")
        XCTAssertEqual(c.g().f(), "B-2-1")

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_2()
        }))

        XCTAssertEqual(a.f(), "A-1-5")
        XCTAssertEqual(b.f(), "B-1-3")
        XCTAssertEqual(c.f().f(), "A-2-1")
        XCTAssertEqual(c.g().f(), "B-2-1")

        XCTAssertEqual(a.f(), "A-1-6")
        XCTAssertEqual(b.f(), "B-1-4")
        XCTAssertEqual(c.f().f(), "A-2-1")
        XCTAssertEqual(c.g().f(), "B-2-1")
    }

    func test_nested_inject_shared_instance_dynamic() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))

        Inject<PTest_C>().registration = Constructor(Shared({ injector in
            return CTest_C_InjectorDynamic()
        }))

        Inject<PTest_D>().registration = Constructor(Shared({ injector in
            return CTest_D_Property()
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()
        let c = InstanceOf<PTest_C>().inject()
        let d = InstanceOf<PTest_D>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")
        XCTAssertEqual(c.f().f(), "A-1-2")
        XCTAssertEqual(c.g().f(), "B-1-2")
        XCTAssertEqual(d.f().f(), "A-1-3")
        XCTAssertEqual(d.g().f().f(), "A-1-4")
        XCTAssertEqual(d.g().g().f(), "B-1-3")
    }

    func test_nested_inject_shared_instance_dynamic_object_override() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_2()
        }))

        Inject<PTest_C>().registration = Constructor(Unique({ injector in
            return CTest_C_InjectorDynamic()
        }))

        Inject<PTest_D>().registration = Constructor(Shared({ injector in
            return CTest_D_Init_B1(a: injector.instanceOf().inject())
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()
        let c = InstanceOf<PTest_C>().inject()
        let d = InstanceOf<PTest_D>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-2-1")
        XCTAssertEqual(c.f().f(), "A-1-2")
        XCTAssertEqual(c.g().f(), "B-2-2")
        XCTAssertEqual(d.f().f(), "A-1-3")
        XCTAssertEqual(d.g().f().f(), "A-1-4")
        XCTAssertEqual(d.g().g().f(), "B-1-1")
        XCTAssertEqual(c.f().f(), "A-1-5")
        XCTAssertEqual(c.g().f(), "B-2-3")
    }

    func test_nested_inject_shared_instance_dynamic_object_live() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_B_1()
        }))

        Inject<PTest_C>().registration = Constructor(Unique({ injector in
            return CTest_C_InjectorDynamic()
        }))

        Inject<PTest_D>().registration = Constructor(Shared({ injector in
            return CTest_D_Injector_B2()
        }))

        let a = InstanceOf<PTest_A>().inject()
        let b = InstanceOf<PTest_B>().inject()
        let c = InstanceOf<PTest_C>().inject()
        let d = InstanceOf<PTest_D>().inject()

        XCTAssertEqual(a.f(), "A-1-1")
        XCTAssertEqual(b.f(), "B-1-1")
        XCTAssertEqual(c.f().f(), "A-1-2")
        XCTAssertEqual(c.g().f(), "B-1-2")
        XCTAssertEqual(d.f().f(), "A-1-3")
        XCTAssertEqual(d.g().f().f(), "A-1-4")
        XCTAssertEqual(d.g().g().f(), "B-2-1")
        XCTAssertEqual(c.f().f(), "A-1-5")
        XCTAssertEqual(c.g().f(), "B-1-3")
    }

    func test_basic_inject_wrongtype() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_B>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        _ = InstanceOf<PTest_A>().inject()

        var testPoint1 = false
        let exception = catchBadInstruction {
            _ = InstanceOf<PTest_B>().inject()
            testPoint1 = true
        }
        XCTAssertFalse(testPoint1, "Invalid type should have been detected")
        XCTAssertNotNil(exception, "Test didn't run")
    }

    func test_basic_inject_notype() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        _ = InstanceOf<PTest_A>().inject()

        var testPoint1 = false
        let exception = catchBadInstruction {
            _ = InstanceOf<PTest_B>().inject()
            testPoint1 = true
        }
        XCTAssertFalse(testPoint1, "No such type should have been detected")
        XCTAssertNotNil(exception, "Test didn't run")
    }

    func test_basic_inject_by_tag() {
        // Create scope-shared instances. Each injection should
        // reuse the same instance, while at least one is alive

        Inject<PTest_A>().registration = Constructor(Shared({
            return CTest_A_1()
        }))

        Inject<PTest_A>()["my_tag1"] = Constructor(Shared({
            return CTest_A_2()
        }))

        Inject<PTest_A>()["my_tag2"] = Constructor(Shared({
            return CTest_A_3()
        }))

        let a1 = InstanceOf<PTest_A>().inject()
        let a2 = InstanceOf<PTest_A>().inject(tag: "my_tag1")
        let a3 = InstanceOf<PTest_A>().inject(tag: "my_tag2")

        XCTAssertEqual(a1.f(), "A-1-1")
        XCTAssertEqual(a2.f(), "A-2-1")
        XCTAssertEqual(a3.f(), "A-3-1")
    }

    func test_basic_inject_singleton() {
        // Create unique instances. Each injection should
        // produce independent instances

        var t_a: PTest_A? = nil
        var t_b: PTest_B? = nil

        Inject<PTest_A>().registration = Constructor(Singleton({ () -> CTest_A_1 in
            let t = CTest_A_1()
            t_a = t
            return t
        }))

        Inject<PTest_B>().registration = Constructor(Singleton({ () -> CTest_B_1 in
            let t = CTest_B_1()
            t_b = t
            return t
        }))

        XCTAssertNotNil(t_a)
        XCTAssertNotNil(t_b)

        _ = {
            let a = InstanceOf<PTest_A>().inject()
            let b = InstanceOf<PTest_B>().inject()

            XCTAssertEqual(a.f(), "A-1-1")
            XCTAssertEqual(b.f(), "B-1-1")

            XCTAssertEqual(a.f(), "A-1-2")
            XCTAssertEqual(b.f(), "B-1-2")
        }()

        let a1 = InstanceOf<PTest_A>().inject()
        let b1 = InstanceOf<PTest_B>().inject()

        XCTAssertEqual(a1.f(), "A-1-3")
        XCTAssertEqual(b1.f(), "B-1-3")

        XCTAssertEqual(a1.f(), "A-1-4")
        XCTAssertEqual(b1.f(), "B-1-4")
    }

    func test_basic_inject_lazysingleton() {
        // Create unique instances. Each injection should
        // produce independent instances

        var t_a: PTest_A? = nil
        var t_b: PTest_B? = nil

        Inject<PTest_A>().registration = Constructor(LazySingleton({ () -> CTest_A_1 in
            let t = CTest_A_1()
            t_a = t
            return t
        }))

        Inject<PTest_B>().registration = Constructor(LazySingleton({ () -> CTest_B_1 in
            let t = CTest_B_1()
            t_b = t
            return t
        }))

        XCTAssertNil(t_a)
        XCTAssertNil(t_b)

        _ = {
            let a = InstanceOf<PTest_A>().inject()
            let b = InstanceOf<PTest_B>().inject()

            XCTAssertEqual(a.f(), "A-1-1")
            XCTAssertEqual(b.f(), "B-1-1")

            XCTAssertEqual(a.f(), "A-1-2")
            XCTAssertEqual(b.f(), "B-1-2")
        }()

        let a1 = InstanceOf<PTest_A>().inject()
        let b1 = InstanceOf<PTest_B>().inject()

        XCTAssertEqual(a1.f(), "A-1-3")
        XCTAssertEqual(b1.f(), "B-1-3")

        XCTAssertEqual(a1.f(), "A-1-4")
        XCTAssertEqual(b1.f(), "B-1-4")
    }

    static var allTests = [
        ("test_basic_inject_unique", test_basic_inject_unique),
        ("test_basic_inject_shared", test_basic_inject_shared),
        ("test_basic_inject_shared_dispose", test_basic_inject_shared_dispose),
        ("test_basic_inject_shared_threads", test_basic_inject_shared_threads),
        ("test_nested_inject_unique", test_nested_inject_unique),
        ("test_nested_inject_shared", test_nested_inject_shared),
        ("test_nested_inject_shared_init", test_nested_inject_shared_init),
        ("test_nested_inject_shared_injector", test_nested_inject_shared_injector),
        ("test_nested_inject_shared_injectordynamic", test_nested_inject_shared_injectordynamic),
        ("test_nested_inject_shared_injectordynamic_override", test_nested_inject_shared_injectordynamic_override),
        ("test_nested_inject_shared_instance_dynamic", test_nested_inject_shared_instance_dynamic),
        ("test_nested_inject_shared_instance_dynamic_object_override", test_nested_inject_shared_instance_dynamic_object_override),
        ("test_nested_inject_shared_instance_dynamic_object_live", test_nested_inject_shared_instance_dynamic_object_live),
        ("test_basic_inject_wrongtype", test_basic_inject_wrongtype),
        ("test_basic_inject_notype", test_basic_inject_notype),
        ("test_basic_inject_by_tag", test_basic_inject_by_tag),
        ("test_basic_inject_singleton", test_basic_inject_singleton),
        ("test_basic_inject_lazysingleton", test_basic_inject_lazysingleton),
    ]
}
