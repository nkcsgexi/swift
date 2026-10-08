// RUN; %target-swift-frontend -emit-module -o %t/A.swiftmodule %S/../Inputs/empty.swift -user-module-version 1.0
// RUN; %target-typecheck-verify-swift -I %t/ -D CONDITION_1

postfix operator ++
postfix func ++ (_: Int) -> Int { 0 }

struct OneResult {}
struct TwoResult {}

protocol MyProto {
    func optionalMethod() -> [Int]?
}
struct MyStruct {
    var optionalMember: MyProto? { nil }
    func methodOne() -> OneResult { OneResult() }
    func methodTwo() -> TwoResult { TwoResult() }
}

func globalFunc<T>(_ arg: T) -> T { arg }

func testBasic(baseExpr: MyStruct) {
    baseExpr
#if CONDITION_1
      .methodOne() // expected_warning {{result of call to 'methodOne()' is unused}}
#else
      .methodTwo()
#endif
}

MyStruct()
#if CONDITION_1
  .methodOne() // expected_warning {{result of call to 'methodOne()' is unused}}
#else
  .methodTwo()
#endif


func testInvalidContent(baseExpr: MyStruct, otherExpr: Int) {
  baseExpr      // expected_warning {{expression of type 'MyStruct' is unused}}
#if CONDITION_1
    { $0 + 1  } // expected_error {{closure expression is unused}}
#endif

  baseExpr      // expected_warning {{expression of type 'MyStruct' is unused}}
#if CONDITION_1
    + otherExpr // expected_error {{unary operator cannot be separated from its operand}}
                // expected_warning@-1 {{result of operator '+' is unused}}
#endif

  baseExpr
#if CONDITION_1
    .methodOne() // expected_warning {{result of call to 'methodOne()' is unused}}

  print("debug") // expected_error {{unexpected tokens in '#if' expression body}}
#endif
}

func testExprKind(baseExpr: MyStruct, idx: Int) {
  baseExpr
#if CONDITION_1
  .optionalMember?.optionalMethod()![idx]++ // expected_warning {{result of operator '++' is unused}}
#else
  .otherMethod(arg) {
    //...
  }
#endif

  baseExpr
#if CONDITION_1
  .methodOne() + 12 // expected_error {{unexpected tokens in '#if' expression body}}
                    // expected_warning@-1 {{result of call to 'methodOne()' is unused}}
#endif
}

func emptyElse(baseExpr: MyStruct) {
  baseExpr
#if CONDITION_1
    .methodOne() // expected_warning {{result of call to 'methodOne()' is unused}}
#elseif CONDITION_2
    // OK. Do nothing.
#endif

  baseExpr
#if CONDITION_1
    .methodOne() // expected_warning {{result of call to 'methodOne()' is unused}}
#elseif CONDITION_2
  return         // expected_error {{unexpected tokens in '#if' expression body}}
#endif
}

func consecutiveIfConfig(baseExpr: MyStruct) {
    baseExpr
#if CONDITION_1
  .methodOne()
#endif
#if CONDITION_2
  .methodTwo()
#endif
  .unknownMethod() // expected_error {{value of type 'OneResult' has no member 'unknownMethod'}}
}

func nestedIfConfig(baseExpr: MyStruct) {
  baseExpr
#if CONDITION_1
  #if CONDITION_2
    .methodOne()
  #endif
  #if CONDITION_1
    .methodTwo() // expected_warning {{result of call to 'methodTwo()' is unused}}
  #endif
#else
  .unknownMethod1()
  #if CONDITION_2
    .unknownMethod2()
  #endif
#endif
}

func ifconfigExprInExpr(baseExpr: MyStruct) {
  globalFunc( // expected_warning {{result of call to 'globalFunc' is unused}}
    baseExpr
#if CONDITION_1
      .methodOne()
#else
      .methodTwo()
#endif
  )
}

func canImportVersioned() {
#if canImport(A, _version: 2)
  let a = 1
#endif

#if canImport(A, _version: 2.2)
  let a = 1
#endif
  
#if canImport(A, _version: 2.2.2)
  let a = 1
#endif
  
#if canImport(A, _version: 2.2.2.2)
  let a = 1
#endif

#if canImport(A, _version: 2.2.2.2.2)
  let a = 1
#endif

#if canImport(A, _version: 2.2.2.2.2.2) // expected_warning {{trailing components of version '2.2.2.2.2' are ignored}}
  let a = 1
#endif

#if canImport(B, _underlyingVersion: 4) // TODO(ParserValidation): expected_warning *{{cannot find module 'B' for canImport check; the directive will evaluate to false}}
  let a = 1
#endif

#if canImport(B, _underlyingVersion: 2.200) // TODO(ParserValidation): expected_warning *{{cannot find module 'B' for canImport check; the directive will evaluate to false}}
  let a = 1
#endif
  
#if canImport(B, _underlyingVersion: 2.200.1) // TODO(ParserValidation): expected_warning *{{cannot find module 'B' for canImport check; the directive will evaluate to false}}
  let a = 1
#endif
  
#if canImport(B, _underlyingVersion: 2.200.1.3) // TODO(ParserValidation): expected_warning *{{cannot find module 'B' for canImport check; the directive will evaluate to false}}
  let a = 1
#endif

#if canImport(A, unknown: 2.2) // expected_error {{second parameter of 'canImport' should be labeled as _version or _underlyingVersion}}
  let a = 1
#endif
  

#if canImport(A,)
  let a = 1
#endif
  
#if canImport(A, 2.2) // expected_error {{second parameter of 'canImport' should be labeled as _version or _underlyingVersion}}
  let a = 1
#endif

#if canImport(A, 2.2, 1.1) // expected_error {{'canImport' can take only two parameters}}
  let a = 1
#endif
  
// expected_error@+1{{'canImport' version check has invalid version ''}}
#if canImport(A, _version:) // expected_error {{expected expression in list of expressions}}
  let a = 1
#endif

#if canImport(A, _version: "") // expected_error {{'canImport' version check has invalid version '""'}}
  let a = 1
#endif
  
#if canImport(A, _version: >=2.2) // expected_error {{'canImport' version check has invalid version '>=2.2'}}
  let a = 1
#endif

// expected_error@+1{{'canImport' version check has invalid version '20A301'}}
#if canImport(A, _version: 20A301) // expected_error {{'A' is not a valid digit in integer literal}}
  let a = 1
#endif

#if canImport(A, _version: "20A301") // expected_error {{'canImport' version check has invalid version '"20A301"'}}
  let a = 1
#endif
}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/ifconfig_expr.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module -D CONDITION_1 %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@46:5 {{}} // expected_prefix_operator
// expected-error@54:3 {{}} // expr_postfix_ifconfig_unexpectedtoken
// expected-error@70:16 {{}} // expr_postfix_ifconfig_unexpectedtoken
// expected-error@87:3 {{}} // expr_postfix_ifconfig_unexpectedtoken
// expected-error@189:27 {{}} // expected_expr_in_expr_list
// expected-error@202:30 {{}} // lex_invalid_digit_in_int_literal
// ---- end ASTGen parity ----
