// RUN; %target-typecheck-verify-swift -verify-ignore-unrelated
// REQUIRES; swift_swift_parser
// FIXME: Swift parser is not enabled on Linux CI yet.
// REQUIRES; OS=macosx

// rdar://15946844
func test1(inout var x : Int) {}  // expected_warning {{'var' in this position is interpreted as an argument label}} {{18-21=`var`}}
// expected_error @-1 {{'inout' before a parameter name is not allowed, place it before the parameter type instead}} {{12-17=}} {{26-26=inout }}
func test2(inout let x : Int) {}  // expected_warning {{'let' in this position is interpreted as an argument label}} {{18-21=`let`}}
// expected_error @-1 {{'inout' before a parameter name is not allowed, place it before the parameter type instead}} {{12-17=}} {{26-26=inout }}
func test3(f : (inout _ x : Int) -> Void) {} // expected_error {{'inout' before a parameter name is not allowed, place it before the parameter type instead}}

func test3() {
  undeclared_func( // expected_error {{cannot find 'undeclared_func' in scope}}
} // expected_error {{expected expression in list of expressions}}

func runAction() {} // expected_note {{did you mean 'runAction'?}}

// rdar://16601779
func foo() {
  // expected_error@+3 {{argument passed to call that takes no arguments}}
  // expected_error@+2 {{cannot find 'SKAction' in scope}}
  // expected_error@+1 {{expected ',' separator}}
  runAction(SKAction.sequence()

    skview!
    // expected_error @-1 {{cannot find 'skview' in scope}}
}

switch state { // expected_error {{cannot find 'state' in scope}}
  let duration : Int = 0 // expected_error {{all statements inside a switch must be covered by a 'case' or 'default'}}
  case 1:
    break
}

func testNotCoveredCase(x: Int) {
  switch x {
    let y = "foo" // expected_error {{all statements inside a switch must be covered by a 'case' or 'default'}}
    switch y {
      case "bar":
        blah blah // ignored
    }
  case "baz": // expected_error {{expression pattern of type 'String' cannot match values of type 'Int'}}
    break
  case 1:
    break
  default:
    break
  }
}

// rdar://18926814
func test4() {
  let abc = 123
  _ = " >> \( abc } ) << " // expected_error {{expected ',' separator}} {{18-18=,}}  expected_error {{expected expression in list of expressions}}

}

// rdar://problem/18507467
func d(_ b: String -> <T>() -> T) {} // expected_error {{expected type for function result}}


// <rdar://problem/22143680> QoI: terrible diagnostic when trying to form a generic protocol
protocol Animal<Food> {  // expected_error {{an associated type named 'Food' must be declared in the protocol 'Animal' or a protocol it inherits}}
  func feed(_ food: Food) // expected_error {{cannot find type 'Food' in scope}}
}


// https://github.com/apple/swift/issues/43190
// Crash with invalid parameter declaration
do {
  class Starfish {}
  struct Salmon {}
  func f(s Starfish,  // expected_error {{expected ':' following argument label and parameter name}}
            _ ss: Salmon) -> [Int] {}
  func g() { f(Starfish(), Salmon()) }
}

// https://github.com/apple/swift/issues/43591
// Two inout crash compiler

func f1_43591(a : inout inout Int) {}  // expected_error {{parameter may have at most one of the 'inout', 'borrowing', or 'consuming' specifiers}} {{19-25=}}
func f2_43591(inout inout b: Int) {} // expected_error {{inout' before a parameter name is not allowed, place it before the parameter type instead}} {{15-20=}} {{30-30=inout }}
// expected_error@-1 {{parameter may have at most one of the 'inout', 'borrowing', or 'consuming' specifiers}} {{21-27=}}
func f3_43591(let let a: Int) {} // expected_warning {{'let' in this position is interpreted as an argument label}} {{15-18=`let`}}
// expected_error @-1 {{expected ',' separator}} {{22-22=,}}
// expected_error @-2 {{expected ':' following argument label and parameter name}}
// expected_warning @-3 {{extraneous duplicate parameter name; 'let' already has an argument label}} {{15-19=}}
func f4_43591(inout x: inout String) {} // expected_error {{parameter may have at most one of the 'inout', 'borrowing', or 'consuming' specifiers}}
func f5_43591(inout i: inout Int) {} // expected_error {{parameter may have at most one of the 'inout', 'borrowing', or 'consuming' specifiers}} {{15-20=}}

func repeat() {}
// expected_error @-1 {{keyword 'repeat' cannot be used as an identifier here}}
// expected_note @-2 {{if this name is unavoidable, use backticks to escape it}} {{6-12=`repeat`}}

let for = 2
// expected_error @-1 {{keyword 'for' cannot be used as an identifier here}}
// expected_note @-2 {{if this name is unavoidable, use backticks to escape it}} {{5-8=`for`}}

func dog cow() {} // expected_error {{found an unexpected second identifier in function declaration; is there an accidental break?}}
// expected_note@-1 {{join the identifiers together}} {{6-13=dogcow}}
// expected_note@-2 {{join the identifiers together with camel-case}} {{6-13=dogCow}}
func cat Mouse() {} // expected_error {{found an unexpected second identifier in function declaration; is there an accidental break?}}
// expected_note@-1 {{join the identifiers together}} {{6-15=catMouse}}
func friend ship<T>(x: T) {} // expected_error {{found an unexpected second identifier in function declaration; is there an accidental break?}}
// expected_note@-1 {{join the identifiers together}} {{6-17=friendship}}
// expected_note@-2 {{join the identifiers together with camel-case}} {{6-17=friendShip}}
func were
wolf() {} // expected_error {{found an unexpected second identifier in function declaration; is there an accidental break?}}
// expected_note@-1 {{join the identifiers together}} {{-1:6-+0:5=werewolf}}
// expected_note@-2 {{join the identifiers together with camel-case}} {{-1:6-+0:5=wereWolf}}
func hammer
leavings<T>(x: T) {} // expected_error {{found an unexpected second identifier in function declaration; is there an accidental break?}}
// expected_note@-1 {{join the identifiers together}} {{-1:6-+0:9=hammerleavings}}
// expected_note@-2 {{join the identifiers together with camel-case}} {{-1:6-+0:9=hammerLeavings}}

prefix operator %
prefix func %<T>(x: T) -> T { return x } // No error expected - the < is considered an identifier but is peeled off by the parser.

struct Weak<T: class> { // expected_error {{'class' constraint can only appear on protocol declarations}}
  // expected_note@-1 {{did you mean to write an 'AnyObject' constraint?}} {{16-21=AnyObject}}
  weak let value: T // expected_error {{'weak' variable should have optional type 'T?'}} expected_error {{'weak' must not be applied to non-class-bound 'T'; consider adding a protocol conformance that has a class bound}}
}

let x: () = ()
!() // expected_error {{cannot convert value of type '()' to expected argument type 'Bool'}}
!(()) // expected_error {{cannot convert value of type '()' to expected argument type 'Bool'}}
!(x) // expected_error {{cannot convert value of type '()' to expected argument type 'Bool'}}
!x // expected_error {{cannot convert value of type '()' to expected argument type 'Bool'}}

// https://github.com/apple/swift/issues/50734

func f1_50734(@NSApplicationMain x: Int) {} // expected_error {{@NSApplicationMain may only be used on 'class' declarations}}
func f2_50734(@available(iOS, deprecated: 1) x: Int) {} // expected_error {{'@available' attribute cannot be applied to this declaration}}
func f3_50734(@discardableResult x: Int) {} // expected_error {{'@discardableResult' attribute cannot be applied to this declaration}}
func f4_50734(@objcMembers x: String) {} // expected_error {{@objcMembers may only be used on 'class' declarations}}
func f5_50734(@weak x: String) {} // expected_error {{'weak' is a declaration modifier, not an attribute}} expected_error {{'weak' may only be used on 'var' declarations}}

class C_50734<@NSApplicationMain T: AnyObject> {} // expected_error {{@NSApplicationMain may only be used on 'class' declarations}}
func f6_50734<@discardableResult T>(x: T) {} // expected_error {{'@discardableResult' attribute cannot be applied to this declaration}}
enum E_50734<@indirect T> {} // expected_error {{'indirect' is a declaration modifier, not an attribute}} expected_error {{'indirect' modifier cannot be applied to this declaration}}
protocol P {
  @available(macOS, introduced: 10.9) associatedtype Assoc
}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/invalid.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// REQUIRES: OS=macosx
// XFAIL: *
// expected-error@7:12 {{}} // parameter_specifier_as_attr_disallowed
// expected-warning@7:18 {{}} // parameter_let_var_as_attr
// expected-error@9:12 {{}} // parameter_specifier_as_attr_disallowed
// expected-warning@9:18 {{}} // parameter_let_var_as_attr
// expected-error@11:17 {{}} // parameter_specifier_as_attr_disallowed
// expected-error@15:1 {{}} // expected_expr_in_expr_list
// expected-error@24:32 {{}} // expected_separator
// expected-error@31:3 {{}} // stmt_in_switch_not_covered_by_case
// expected-error@38:5 {{}} // stmt_in_switch_not_covered_by_case
// expected-error@55:19 2 {{}} // expected_expr_in_expr_list,expected_separator
// expected-error@60:23 {{}} // expected_type_function_result
// expected-error@74:20 {{}} // expected_parameter_colon
// expected-error@82:25 {{}} // parameter_specifier_repeated
// expected-error@83:15 {{}} // parameter_specifier_as_attr_disallowed
// expected-error@83:21 {{}} // parameter_specifier_repeated
// expected-warning@85:15 2 {{}} // parameter_extraneous_double_up,parameter_let_var_as_attr
// expected-error@85:23 2 {{}} // expected_parameter_colon,expected_separator
// expected-error@89:15 {{}} // parameter_specifier_repeated
// expected-error@90:15 {{}} // parameter_specifier_repeated
// expected-error@92:6 {{}} // keyword_cant_be_identifier
// expected-note@92:6 {{}} // backticks_to_escape
// expected-error@96:5 {{}} // keyword_cant_be_identifier
// expected-note@96:5 {{}} // backticks_to_escape
// expected-error@100:10 {{}} // repeated_identifier
// expected-note@100:10 2 {{}} // join_identifiers,join_identifiers_camel_case
// expected-error@103:10 {{}} // repeated_identifier
// expected-note@103:10 {{}} // join_identifiers
// expected-error@105:13 {{}} // repeated_identifier
// expected-note@105:13 2 {{}} // join_identifiers,join_identifiers_camel_case
// expected-error@109:1 {{}} // repeated_identifier
// expected-note@109:1 2 {{}} // join_identifiers,join_identifiers_camel_case
// expected-error@113:1 {{}} // repeated_identifier
// expected-note@113:1 2 {{}} // join_identifiers,join_identifiers_camel_case
// expected-error@120:16 {{}} // unexpected_class_constraint
// expected-note@120:16 {{}} // suggest_anyobject
// expected-error@137:15 {{}} // cskeyword_not_attribute
// expected-error@141:14 {{}} // cskeyword_not_attribute
// ---- end ASTGen parity ----
