// RUN; %target-typecheck-verify-swift -swift-version 4 -I %S/Inputs -enable-source-import

import imported_enums

// TODO: Implement tuple equality in the library.
// BLOCKED: <rdar://problem/13822406>
func ~= (x: (Int,Int,Int), y: (Int,Int,Int)) -> Bool {
  return true
}

var x:Int

func square(_ x: Int) -> Int { return x*x }

struct A<B> {
  struct C<D> { }
}

switch x {
// Expressions as patterns.
case 0:
  ()
case 1 + 2:
  ()
case square(9):
  ()

// 'var', 'let', and 'inout' patterns.
case var a:
  a = 1
case let a:
  a = 1         // expected_error {{cannot assign}}
case inout a: // expected_error {{'inout' may only be used on parameters}} expected_error {{'is' keyword required to pattern match against type name}}
  a = 1 // expected_error {{cannot find 'a' in scope}}
case var var a: // expected_error {{'var' cannot appear nested inside another 'var' or 'let' pattern}}
  a += 1
case var let a: // expected_error {{'let' cannot appear nested inside another 'var' or 'let' pattern}}
  print(a, terminator: "")
case var (var b): // expected_error {{'var' cannot appear nested inside another 'var'}}
  b += 1
// 'Any' pattern.
case _:
  ()

// patterns are resolved in expression-only positions are errors.
case 1 + (_): // expected_error{{'_' can only appear in a pattern or on the left side of an assignment}}
  ()
}

switch (x,x) {
case (var a, var a): // expected_error {{invalid redeclaration of 'a'}} expected_note {{'a' previously declared here}}
  fallthrough
case _: // expected_warning {{case is already handled by previous patterns; consider removing it}}
  ()
}

var e : Any = 0

switch e { // expected_error {{switch must be exhaustive}} expected_note{{add a default clause}}
// 'is' pattern.
case is Int,
     is A<Int>,
     is A<Int>.C<Int>,
     is (Int, Int),
     is (a: Int, b: Int):
  ()
}

// Enum patterns.
enum Foo { case A, B, C }

func == <T>(_: Voluntary<T>, _: Voluntary<T>) -> Bool { return true }

enum Voluntary<T> : Equatable {
  case Naught
  case Mere(T)
  case Twain(T, T)


  func enumMethod(_ other: Voluntary<T>, foo: Foo) {
    switch self {
    case other:
      ()

    case .Naught,
         .Naught(), // expected_error {{pattern with associated values does not match enum case 'Naught'}}
                    // expected_note@-1 {{remove associated values to make the pattern match}} {{17-19=}}
         .Naught(_), // expected_error{{pattern with associated values does not match enum case 'Naught'}}
                     // expected_note@-1 {{remove associated values to make the pattern match}} {{17-20=}}
         .Naught(_, _): // expected_error{{pattern with associated values does not match enum case 'Naught'}}
                        // expected_note@-1 {{remove associated values to make the pattern match}} {{17-23=}}
      ()

    case .Mere,
         .Mere(), // expected_error{{tuple pattern cannot match values of the non-tuple type 'T'}}
         .Mere(_),
         .Mere(_, _): // expected_error{{tuple pattern cannot match values of the non-tuple type 'T'}}
      ()

    case .Twain(), // expected_error{{tuple pattern has the wrong length for tuple type '(T, T)'}}
         .Twain(_), // expected_warning {{enum case 'Twain' has 2 associated values; matching them as a tuple is deprecated}}
                    // expected_note@-25 {{'Twain' declared here}}
         .Twain(_, _),
         .Twain(_, _, _): // expected_error{{tuple pattern has the wrong length for tuple type '(T, T)'}}
      ()
    }

    switch foo {
    case .Naught: // expected_error{{type 'Foo' has no member 'Naught'}}
      ()
    case .A, .B, .C:
      ()
    }
  }
}

var n : Voluntary<Int> = .Naught
if case let .Naught(value) = n {} // expected_error{{pattern with associated values does not match enum case 'Naught'}}
                                  // expected_note@-1 {{remove associated values to make the pattern match}} {{20-27=}}
if case let .Naught(value1, value2, value3) = n {} // expected_error{{pattern with associated values does not match enum case 'Naught'}}
                                                   // expected_note@-1 {{remove associated values to make the pattern match}} {{20-44=}}


switch n {
case Foo.A: // expected_error{{pattern of type 'Foo' cannot match 'Voluntary<Int>'}}
  ()
case Voluntary<Int>.Naught,
     Voluntary<Int>.Naught(), // expected_error {{pattern with associated values does not match enum case 'Naught'}}
                              // expected_note@-1 {{remove associated values to make the pattern match}} {{27-29=}}
     Voluntary<Int>.Naught(_, _), // expected_error{{pattern with associated values does not match enum case 'Naught'}}
                                  // expected_note@-1 {{remove associated values to make the pattern match}} {{27-33=}}
     Voluntary.Naught,
     .Naught:
  ()
case Voluntary<Int>.Mere,
     Voluntary<Int>.Mere(_),
     Voluntary<Int>.Mere(_, _), // expected_error{{tuple pattern cannot match values of the non-tuple type 'Int'}}
     Voluntary.Mere,
     Voluntary.Mere(_),
     .Mere,
     .Mere(_):
  ()
case .Twain,
     .Twain(_), // expected_warning {{enum case 'Twain' has 2 associated values; matching them as a tuple is deprecated}}
                // expected_note@-68 {{'Twain' declared here}}
     .Twain(_, _),
     .Twain(_, _, _): // expected_error{{tuple pattern has the wrong length for tuple type '(Int, Int)'}}
  ()
}

var notAnEnum = 0

switch notAnEnum {
case .Foo: // expected_error{{type 'Int' has no member 'Foo'}}
  ()
}

struct ContainsEnum {
  enum Possible<T> {
    case Naught
    case Mere(T)
    case Twain(T, T)
  }

  func member(_ n: Possible<Int>) {
    switch n { // expected_error {{switch must be exhaustive}}
    // expected_note@-1 {{add missing cases: '.Mere(_)', '.Twain(_, _)'}}
    case ContainsEnum.Possible<Int>.Naught,
         ContainsEnum.Possible.Naught, // expected_warning {{case is already handled by previous patterns; consider removing it}}
         Possible<Int>.Naught, // expected_warning {{case is already handled by previous patterns; consider removing it}}
         Possible.Naught, // expected_warning {{case is already handled by previous patterns; consider removing it}}
         .Naught: // expected_warning {{case is already handled by previous patterns; consider removing it}}
      ()
    }
  }
}

func nonmemberAccessesMemberType(_ n: ContainsEnum.Possible<Int>) {
  switch n { // expected_error {{switch must be exhaustive}}
  // expected_note@-1 {{add missing cases: '.Mere(_)', '.Twain(_, _)'}}
  case ContainsEnum.Possible<Int>.Naught,
       .Naught: // expected_warning {{case is already handled by previous patterns; consider removing it}}
    ()
  }
}

var m : ImportedEnum = .Simple

switch m {
case imported_enums.ImportedEnum.Simple,
     ImportedEnum.Simple, // expected_warning {{case is already handled by previous patterns; consider removing it}}
     .Simple: // expected_warning {{case is already handled by previous patterns; consider removing it}}
  ()
case imported_enums.ImportedEnum.Compound,
     imported_enums.ImportedEnum.Compound(_), // expected_warning {{case is already handled by previous patterns; consider removing it}}
     ImportedEnum.Compound, // expected_warning {{case is already handled by previous patterns; consider removing it}}
     ImportedEnum.Compound(_), // expected_warning {{case is already handled by previous patterns; consider removing it}}
     .Compound, // expected_warning {{case is already handled by previous patterns; consider removing it}}
     .Compound(_): // expected_warning {{case is already handled by previous patterns; consider removing it}}
  ()
}

// Check that single-element tuple payloads work sensibly in patterns.

enum LabeledScalarPayload {
  case Payload(name: Int)
}

var lsp: LabeledScalarPayload = .Payload(name: 0)
func acceptInt(_: Int) {}
func acceptString(_: String) {}

switch lsp {
case .Payload(0):
  ()
case .Payload(name: 0):
  ()
case let .Payload(x):
  acceptInt(x)
  acceptString("\(x)")
case let .Payload(name: x): // expected_warning {{case is already handled by previous patterns; consider removing it}}
  acceptInt(x)
  acceptString("\(x)")
case let .Payload((name: x)): // expected_warning {{case is already handled by previous patterns; consider removing it}}
  acceptInt(x)
  acceptString("\(x)")
case .Payload(let (name: x)): // expected_warning {{case is already handled by previous patterns; consider removing it}}
  acceptInt(x)
  acceptString("\(x)")
case .Payload(let (name: x)): // expected_warning {{case is already handled by previous patterns; consider removing it}}
  acceptInt(x)
  acceptString("\(x)")
case .Payload(let x): // expected_warning {{case is already handled by previous patterns; consider removing it}}
  acceptInt(x)
  acceptString("\(x)")
case .Payload((let x)): // expected_warning {{case is already handled by previous patterns; consider removing it}}
  acceptInt(x)
  acceptString("\(x)")
}

// Property patterns.

struct S {
  static var stat: Int = 0
  var x, y : Int
  var comp : Int {
    return x + y
  }

  func nonProperty() {}
}





// Tuple patterns.

var t = (1, 2, 3)

prefix operator +++
infix operator +++
prefix func +++(x: (Int,Int,Int)) -> (Int,Int,Int) { return x }
func +++(x: (Int,Int,Int), y: (Int,Int,Int)) -> (Int,Int,Int) {
  return (x.0+y.0, x.1+y.1, x.2+y.2)
}

switch t {
case (_, var a, 3):
  a += 1
case var (_, b, 3):
  b += 1
case var (_, var c, 3): // expected_error{{'var' cannot appear nested inside another 'var'}}
  c += 1
case (1, 2, 3):
  ()

// patterns in expression-only positions are errors.
case +++(_, var d, 3):
// expected_error@-1{{'_' can only appear in a pattern or on the left side of an assignment}}
  ()
case (_, var e, 3) +++ (1, 2, 3):
// expected_error@-1{{'_' can only appear in a pattern or on the left side of an assignment}}
  ()
case (let (_, _, _)) + 1:
// expected_error@-1 {{'_' can only appear in a pattern or on the left side of an assignment}}
  ()
}

// "isa" patterns.

// https://github.com/apple/swift/issues/56139
// Allow subpatterns for "isa" patterns that require conditional
// collection downcasts
do {
  class Base { }
  class Derived : Base { }

  let arr: [Base]

  if case let _ as [Derived] = arr {}
  // expected_warning@-1 {{'let' pattern has no effect; sub-pattern didn't bind any variables}}
  guard case let _ as [Derived] = arr else {}
  // expected_warning@-1 {{'let' pattern has no effect; sub-pattern didn't bind any variables}}
  while case let _ as [Derived] = arr {}
  // expected_warning@-1 {{'let' pattern has no effect; sub-pattern didn't bind any variables}}

  // https://github.com/apple/swift/issues/61850
  for case _ as [Derived] in [arr] {}

  if case is [Derived] = arr {}

  guard case is [Derived] = arr else {}

  while case is [Derived] = arr {}

  for case is [Derived] in [arr] {}

  switch arr {
  case let ds as [Derived]:
    // expected_warning@-1 {{immutable value 'ds' was never used; consider replacing with '_' or removing it}}
    ()
  case is [Derived]:
    ()

  default:
    ()
  }

  let _ = { (arr: [Base]) -> Void in
    switch arr {
    case let ds as [Derived]:
      // expected_warning@-1 {{immutable value 'ds' was never used; consider replacing with '_' or removing it}}
      ()
    default:
      ()
    }
  }
}

// Optional patterns.
let op1 : Int?
let op2 : Int??

switch op1 {
case nil: break
case 1?: break
case _?: break
}

switch op2 {
case nil: break
case _?: break
case (1?)?: break
case (_?)?: break // expected_warning {{case is already handled by previous patterns; consider removing it}}
}



// <rdar://problem/20365753> Bogus diagnostic "refutable pattern match can fail"
let (responseObject: Int?) = op1
// expected_error @-1 {{expected ',' separator}} {{25-25=,}}
// expected_error @-2 {{expected pattern}}
// expected_error @-3 {{cannot convert value of type 'Int?' to specified type '(responseObject: _)'}}

enum E<T> {
  case e(T)
}

// rdar://108738034 - Make sure we don't treat 'E' as a binding, but can treat
// 'y' as a binding
func testNonBinding1(_ x: E<Int>) -> Int {
  if case let E<Int>.e(y) = x { y } else { 0 }
}

func testNonBinding2(_ e: E<Int>) -> Int {
  switch e {
  case let E<Int>.e(y):
    y
  }
}

// In this case, 'y' should be an identifier, but 'z' is a binding.
func testNonBinding3(_ x: (Int, Int), y: [Int]) -> Int {
  if case let (y[0], z) = x { z } else { 0 }
}

func testNonBinding4(_ x: (Int, Int), y: [Int]) -> Int {
  switch x {
  case let (y[0], z):
    z
  default:
    0
  }
}

func testNonBinding5(_ x: Int, y: [Int]) {
  // We treat 'z' here as a binding, which is invalid.
  if case let y[z] = x {} // expected_error {{pattern variable binding cannot appear in an expression}}
}

func testNonBinding6(y: [Int], z: Int) -> Int {
  switch 0 {
  // We treat 'z' here as a binding, which is invalid.
  case let y[z]: // expected_error {{pattern variable binding cannot appear in an expression}}
    z
  case y[z]: // This is fine
    0
  default:
    0
  }
}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/matching_patterns.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module -swift-version 4 %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@35:10 {{}} // var_pattern_in_var
// expected-error@37:10 {{}} // var_pattern_in_var
// expected-error@39:11 {{}} // var_pattern_in_var
// expected-error@273:14 {{}} // var_pattern_in_var
// expected-error@361:25 2 {{}} // expected_pattern,expected_separator
// ---- end ASTGen parity ----
