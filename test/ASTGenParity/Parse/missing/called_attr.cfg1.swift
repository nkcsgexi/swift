// RUN; %target-typecheck-verify-swift -enable-experimental-feature CalledAttribute -verify-additional-prefix supported-
// RUN; %target-typecheck-verify-swift -verify-additional-prefix forbidden-

// REQUIRES; swift_feature_CalledAttribute

typealias FnType = @called(atMostOnce) () -> () // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testInParameter(_: @called(atMostOnce) () -> ()) {} // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testInParameterEscaping(_: @escaping @called(atMostOnce) () -> ()) {} // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testInParameterAutoclosure(_: @autoclosure @called(atMostOnce) () -> ()) {} // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testInParameterExplicitOwnership(_: borrowing @called(atMostOnce) () -> ()) {}
// expected_supported-error@-1 {{'@called(atMostOnce)' cannot be used together with 'borrowing'}}
// expected_forbidden-error@-2 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testInParameterExplicitOwnership(_: inout @called(atMostOnce) () -> ()) {} // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testInParameterConsuming(_: consuming @called(atMostOnce) () -> ()) {} // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}
// expected_forbidden-error@-2 {{'consuming' cannot be applied to nonescaping closure}}

func testInResultPosition(_: () -> @called(atMostOnce) () -> Void) {}
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testInner() {
  let opt: (@called(atMostOnce) () -> ())? = nil
  // expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}
  _ = opt
}

struct Test : ~Copyable {
  let prop: @called(atMostOnce) () -> Void // Ok
  // expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}
}

func testWithConvention(_: @convention(block) @called(atMostOnce) () -> Void) {}
// expected_supported-error@-1 {{'@convention' attribute is not allowed on '@called' types}}
// expected_forbidden-error@-2 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

typealias ExactlyOnceFnType = @called(exactlyOnce) () -> () // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testExactlyOnceInParameter(_: @called(exactlyOnce) () -> ()) {} // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testExactlyOnceInParameterEscaping(_: @escaping @called(exactlyOnce) () -> ()) {} // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testExactlyOnceInParameterAutoclosure(_: @autoclosure @called(exactlyOnce) () -> ()) {} // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testExactlyOnceInParameterExplicitOwnership(_: borrowing @called(exactlyOnce) () -> ()) {}
// expected_supported-error@-1 {{'@called(exactlyOnce)' cannot be used together with 'borrowing'}}
// expected_forbidden-error@-2 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testExactlyOnceInParameterExplicitOwnership(_: inout @called(exactlyOnce) () -> ()) {} // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testExactlyOnceInParameterConsuming(_: consuming @called(exactlyOnce) () -> ()) {} // Ok
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}
// expected_forbidden-error@-2 {{'consuming' cannot be applied to nonescaping closure}}

func testExactlyOnceInResultPosition(_: () -> @called(exactlyOnce) () -> Void) {}
// expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

func testInvalidSemantics(_: @called(twice) () -> Void) {}
// expected_error@-1 {{expected 'exactlyOnce' or 'atMostOnce' as the '@called' execution semantics}}

func testMissingSemantics(_: @called() () -> Void) {}
// expected_error@-1 {{expected 'exactlyOnce' or 'atMostOnce' as the '@called' execution semantics}}

func testInvalidResult() -> @called(atMostOnce) Int {
  // expected_error@-1 {{'@called' only applies to function types}}
}

func testClosure() {
  _ = { @called(atMostOnce) in 42 }
  // expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}
  _ = { @called(atMostOnce) (x: Int, y: String) -> Void in }
  // expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

  _ = { @called(exactlyOnce) in 42 }
  // expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}
  _ = { @called(exactlyOnce) (x: Int, y: String) -> Void in }
  // expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}

  _ = { @called(twice) in }
  // expected_error@-1 {{unknown option 'twice' for attribute 'called'}}

  @called(atMostOnce) func local() {}
  // expected_supported-error@-1 {{'@called(atMostOnce)' attribute cannot be applied to this declaration}}
  // expected_forbidden-error@-2 {{'called(atMostOnce)' attribute is only valid when experimental feature CalledAttribute is enabled}}

  @called(atMostOnce) let x: () -> Void = { }
  // expected_supported-error@-1 {{'@called(atMostOnce)' attribute cannot be applied to this declaration}}
  // expected_forbidden-error@-2 {{'called(atMostOnce)' attribute is only valid when experimental feature CalledAttribute is enabled}}
  _ = x

  @called(exactlyOnce) func exactlyOnceLocal() {}
  // expected_supported-error@-1 {{'@called(exactlyOnce)' attribute cannot be applied to this declaration}}
  // expected_forbidden-error@-2 {{'called(exactlyOnce)' attribute is only valid when experimental feature CalledAttribute is enabled}}
}

func testSendingCaptures() {
  class NS {
    func test() {
      _ = { @called(atMostOnce) [sending self] in
        // expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}
        // expected_forbidden-error@-2 {{expected 'weak', 'unowned', or no specifier in capture list}}
        _ = self
      }
    }
  }

  let ns = NS()
  _ = { @called(atMostOnce) [sending ns] in
    // expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}
    // expected_forbidden-error@-2 {{expected 'weak', 'unowned', or no specifier in capture list}}
    ns
  }
  _ = { @called(atMostOnce) [x = 42, sending ns = NS()] in
    // expected_forbidden-error@-1 {{'@called' attribute is only valid when experimental feature CalledAttribute is enabled}}
    // expected_forbidden-error@-2 {{expected 'weak', 'unowned', or no specifier in capture list}}
    _ = x
    _ = ns
  }
}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/called_attr.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module -enable-experimental-feature CalledAttribute %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_CalledAttribute
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@73:38 {{}} // attr_called_expected_semantics
// expected-error@76:38 {{}} // attr_called_expected_semantics
// expected-error@94:10 {{}} // attr_unknown_option
// ---- end ASTGen parity ----
