// RUN; %target-typecheck-verify-swift

prefix operator +++ {} // expected_error {{operator should no longer be declared with body}} {{20-23=}}
postfix operator +++ {} // expected_error {{operator should no longer be declared with body}} {{21-24=}}
infix operator +++ {} // expected_error {{operator should no longer be declared with body}} {{19-22=}}
infix operator +++* { // expected_error {{operator should no longer be declared with body; use a precedence group instead}} {{none}}
  associativity right
}
infix operator +++*+ : A { } // expected_error {{operator should no longer be declared with body}} {{25-29=}}


prefix operator +++** : A { }
// expected_error@-1 {{only infix operators may declare a precedence}} {{23-27=}}
// expected_error@-2 {{operator should no longer be declared with body}} {{26-30=}}

prefix operator ++*++ : A
// expected_error@-1 {{only infix operators may declare a precedence}} {{23-26=}}

postfix operator ++*+* : A { }
// expected_error@-1 {{only infix operators may declare a precedence}} {{24-28=}}
// expected_error@-2 {{operator should no longer be declared with body}} {{27-31=}}

postfix operator ++**+ : A
// expected_error@-1 {{only infix operators may declare a precedence}} {{24-27=}}

operator ++*** : A
// expected_error@-1 {{operator must be declared as 'prefix', 'postfix', or 'infix'}}

operator +*+++ { }
// expected_error@-1 {{operator must be declared as 'prefix', 'postfix', or 'infix'}}
// expected_error@-2 {{operator should no longer be declared with body}} {{15-19=}}

operator +*++* : A { }
// expected_error@-1 {{operator must be declared as 'prefix', 'postfix', or 'infix'}}
// expected_error@-2 {{operator should no longer be declared with body}} {{19-23=}}

prefix operator // expected_error {{expected operator name in operator declaration}}

;
prefix operator %%+

prefix operator ??
postfix operator ?? // expected_error {{postfix operator names starting with '?' or '!' are disallowed to avoid collisions with built-in unwrapping operators}}
prefix operator !!
postfix operator !! // expected_error {{postfix operator names starting with '?' or '!' are disallowed to avoid collisions with built-in unwrapping operators}}
postfix operator ?$$
// expected_error@-1 {{postfix operator names starting with '?' or '!' are disallowed}}
// expected_error@-2 {{'$$' is considered an identifier}}

infix operator --aa // expected_error {{'aa' is considered an identifier and must not appear within an operator name}}
infix operator aa--: A // expected_error {{'aa' is considered an identifier and must not appear within an operator name}}
infix operator <<$$@< // expected_error {{'$$' is considered an identifier and must not appear within an operator name}}
infix operator !!@aa // expected_error {{'@' is not allowed in operator names}}
infix operator #++= // expected_error {{'#' is not allowed in operator names}}
infix operator ++=# // expected_error {{'#' is not allowed in operator names}}
infix operator -># // expected_error {{'#' is not allowed in operator names}}

// FIXME: Ideally, we shouldn't emit the «consistent whitespace» diagnostic
// where = cannot possibly mean an assignment.
infix operator =#=
// expected_error@-1 {{'#' is not allowed in operator names}}
// expected_error@-2 {{'=' must have consistent whitespace on both sides}}

infix operator +++=
infix operator *** : A
infix operator --- : ; // expected_error {{expected precedence group name after ':' in operator declaration}}

precedencegroup { // expected_error {{expected identifier after 'precedencegroup'}}
  associativity: right
}
precedencegroup A {
  associativity right // expected_error {{expected colon after attribute name in precedence group}}
}
precedencegroup B {
  precedence 123 // expected_error {{'precedence' is not a valid precedence group attribute}}
}
precedencegroup C {
  associativity: sinister // expected_error {{expected 'none', 'left', or 'right' after 'associativity'}}
}
precedencegroup D {
  assignment: no // expected_error {{expected 'true' or 'false' after 'assignment'}}
}
precedencegroup E {
  higherThan:
} // expected_error {{expected name of related precedence group after 'higherThan'}}
precedencegroup EE {
  higherThan: E,
} // expected_error {{expected name of related precedence group after 'higherThan'}}

precedencegroup F {
  higherThan: A, B, C
}


precedencegroup BangBangBang {
  associativity: none
  associativity: left // expected_error{{'associativity' attribute for precedence group declared multiple times}}
}

precedencegroup CaretCaretCaret {
  assignment: true 
  assignment: false // expected_error{{'assignment' attribute for precedence group declared multiple times}}
}

class Foo {
  infix operator ||| // expected_error{{'operator' may only be declared at file scope}}
}

infix operator **<< : UndeclaredPrecedenceGroup
// expected_error@-1 {{unknown precedence group 'UndeclaredPrecedenceGroup'}}

protocol Proto {}
infix operator *<*< : F, Proto
// expected_error@-1 {{consecutive statements on a line must be separated by ';'}}
// expected_error@-2 {{expected expression}}

// https://github.com/apple/swift/issues/60932

// expected_error@+2 {{expected precedence group name after ':' in operator declaration}}
postfix operator ++: // expected_error {{only infix operators may declare a precedence}} {{20-21=}}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/operator_decl.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@3:21 {{}} // deprecated_operator_body
// expected-error@4:22 {{}} // deprecated_operator_body
// expected-error@5:20 {{}} // deprecated_operator_body
// expected-error@6:21 {{}} // deprecated_operator_body_use_group
// expected-error@9:26 {{}} // deprecated_operator_body
// expected-error@12:23 {{}} // precedencegroup_not_infix
// expected-error@12:27 {{}} // deprecated_operator_body
// expected-error@16:23 {{}} // precedencegroup_not_infix
// expected-error@19:24 {{}} // precedencegroup_not_infix
// expected-error@19:28 {{}} // deprecated_operator_body
// expected-error@23:24 {{}} // precedencegroup_not_infix
// expected-error@26:1 {{}} // operator_decl_no_fixity
// expected-error@29:1 {{}} // operator_decl_no_fixity
// expected-error@29:16 {{}} // deprecated_operator_body
// expected-error@33:1 {{}} // operator_decl_no_fixity
// expected-error@33:20 {{}} // deprecated_operator_body
// expected-error@37:16 {{}} // expected_operator_name_after_operator
// expected-error@43:18 {{}} // postfix_operator_name_cannot_start_with_unwrap
// expected-error@45:18 {{}} // postfix_operator_name_cannot_start_with_unwrap
// expected-error@46:18 {{}} // postfix_operator_name_cannot_start_with_unwrap
// expected-error@46:19 {{}} // identifier_within_operator_name
// expected-error@50:18 {{}} // identifier_within_operator_name
// expected-error@51:16 {{}} // identifier_within_operator_name
// expected-error@52:18 {{}} // identifier_within_operator_name
// expected-error@53:18 {{}} // operator_name_invalid_char
// expected-error@54:16 {{}} // operator_name_invalid_char
// expected-error@55:19 {{}} // operator_name_invalid_char
// expected-error@56:18 {{}} // operator_name_invalid_char
// expected-error@60:17 {{}} // operator_name_invalid_char
// expected-error@60:18 {{}} // lex_unary_equal
// expected-error@66:22 {{}} // operator_decl_expected_precedencegroup
// expected-error@68:17 {{}} // expected_precedencegroup_name
// expected-error@72:17 {{}} // expected_precedencegroup_attribute_colon
// expected-error@75:3 {{}} // unknown_precedencegroup_attribute
// expected-error@78:18 {{}} // expected_precedencegroup_associativity
// expected-error@81:15 {{}} // expected_precedencegroup_assignment
// expected-error@85:1 {{}} // expected_precedencegroup_relation
// expected-error@88:1 {{}} // expected_precedencegroup_relation
// expected-error@97:3 {{}} // precedencegroup_attribute_redeclared
// expected-error@102:3 {{}} // precedencegroup_attribute_redeclared
// expected-error@106:9 {{}} // operator_decl_inner_scope
// expected-error@113:24 2 {{}} // expected_expr,statement_same_line_without_semi
// expected-error@120:20 {{}} // precedencegroup_not_infix
// expected-error@172:1 {{}} // operator_decl_expected_precedencegroup
// ---- end ASTGen parity ----
