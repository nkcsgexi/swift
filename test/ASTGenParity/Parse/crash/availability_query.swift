// RUN; %target-typecheck-verify-swift

// REQUIRES; OS=macosx

if #available(OSX 51, *) {
}

// Disallow use as an expression.
if (#available(OSX 51, *)) {}  // expected_error {{#available may only be used as condition of an 'if', 'guard'}}

let x = #available(OSX 51, *)  // expected_error {{#available may only be used as condition of}}

(#available(OSX 51, *) ? 1 : 0) // expected_error {{#available may only be used as condition of an}}

if !#available(OSX 52, *) { // expected_error {{#available cannot be used as an expression, did you mean to use '#unavailable'?}} {{4-15=#unavailable}}
}
if let _ = Optional(5), !#available(OSX 52, *) { // expected_error {{#available cannot be used as an expression, did you mean to use '#unavailable'?}} {{25-36=#unavailable}}
}

if #available(OSX 51, *) && #available(OSX 52, *) { // expected_error {{expected ',' joining parts of a multi-clause condition}} {{25-28=,}}
}


if #available { // expected_error {{expected availability condition}}
}

if #available( { // expected_error {{expected platform name}} expected_error {{expected ')'}} expected_note {{to match this opening '('}}
}

if #available() { // expected_error {{expected platform name}}
}

if #available(OSX { // expected_error {{expected ')'}} expected_note {{to match this opening '('}}
}

if #available(OSX) { // expected_error {{expected version number}}
}

if #available(OSX 0) { // expected_warning {{expected version number; this is an error in the Swift 6 language mode}}
}

if #available(OSX 0.0) { // expected_warning {{expected version number; this is an error in the Swift 6 language mode}}
}

if #available(OSX 51 { // expected_error {{expected ')'}} expected_note {{to match this opening '('}}
}

if #available(iDishwasherOS 0) { // expected_warning {{expected version number; this is an error in the Swift 6 language mode}}
}

if #available(iDishwasherOS 51) { // expected_warning {{cannot find availability domain 'iDishwasherOS'}}
// expected_error@-1 {{condition required for target platform}}
}

if #available(iDishwasherOS 51, *) { // expected_warning {{cannot find availability domain 'iDishwasherOS'}}
}

if #available(macos 51, *) { // expected_warning {{cannot find availability domain 'macos'; did you mean 'macOS'?}} {{15-20=macOS}}
}

if #available(mscos 51, *) { // expected_warning {{cannot find availability domain 'mscos'; did you mean 'macOS'?}} {{15-20=macOS}}
}

if #available(macoss 51, *) { // expected_warning {{cannot find availability domain 'macoss'; did you mean 'macOS'?}} {{15-21=macOS}}
}

if #available(mac 51, *) { // expected_warning {{cannot find availability domain 'mac'; did you mean 'macOS'?}} {{15-18=macOS}}
}

if #available(OSX 51, OSX 52, *) {  // expected_error {{version for macOS already specified}}
}

if #available(OSX 52) { }  // expected_error {{must handle potential future platforms with '*'}} {{21-21=, *}}

if #available(OSX 51, iOS 8.0) { }  // expected_error {{must handle potential future platforms with '*'}} {{30-30=, *}}

if #available(iOS 8.0, *) {
}

if #available(iOSApplicationExtension, unavailable) { // expected_error {{'unavailable' can't be combined with shorthand specification 'iOSApplicationExtension'}}
// expected_error@-1 {{condition required for target platform}}
// expected_note@-2 {{did you mean to specify an introduction version?}}
}
	
// Want to make sure we can parse this. Perhaps we should not let this validate, though.
if #available(*) {
}

if #available(* { // expected_error {{expected ')' in availability query}} expected_note {{to match this opening '('}}
}

// Multiple platforms
if #available(OSX 51, iOS 8.0, *) {
}


if #available(OSX 51, { // expected_error {{expected platform name}} // expected_error {{expected ')'}} expected_note {{to match this opening '('}}
}

if #available(OSX 51,) { // expected_error {{expected platform name}}
}

if #available(OSX 51, iOS { // expected_error {{expected ')'}} expected_note {{to match this opening '('}}
}

if #available(OSX 51, iOS 8.0, iDishwasherOS 51) { // expected_warning {{cannot find availability domain 'iDishwasherOS'}}
// expected_error@-1 {{must handle potential future platforms with '*'}}
}

if #available(iDishwasherOS 51, OSX 51) { // expected_warning {{cannot find availability domain 'iDishwasherOS'}}
// expected_error@-1 {{must handle potential future platforms with '*'}}
}

if #available(OSX 51 || iOS 8.0) {// expected_error {{'||' cannot be used in an availability condition}}
}

// Emit Fix-It removing un-needed >=, for the moment.

if #available(OSX >= 51, *) { // expected_error {{version comparison not needed}} {{19-22=}}
}

// Bool then #available.
if 1 != 2, #available(iOS 8.0, *) {}

// Pattern then #available(iOS 8.0, *) {
if case 42 = 42, #available(iOS 8.0, *) {}
if let _ = Optional(42), #available(iOS 8.0, *) {}

// Allow "macOS" as well.
if #available(macOS 51, *) {
}

// FIXME: This is weird, but it's already accepted. It should probably be diagnosed.
if #available(*, macOS 51) {
}

// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/availability_query.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// REQUIRES: OS=macosx
// XFAIL: *
// expected-error@9:5 {{}} // special_condition_outside_if_stmt_guard
// expected-error@11:9 {{}} // special_condition_outside_if_stmt_guard
// expected-error@13:2 {{}} // special_condition_outside_if_stmt_guard
// expected-error@15:4 {{}} // false_available_is_called_unavailable
// expected-error@17:25 {{}} // false_available_is_called_unavailable
// expected-error@20:26 {{}} // expected_comma_stmtcondition
// expected-error@24:15 {{}} // avail_query_expected_condition
// expected-note@27:14 {{}} // opening_paren
// expected-error@27:16 2 {{}} // avail_query_expected_platform_name,avail_query_expected_rparen
// expected-error@30:15 {{}} // avail_query_expected_platform_name
// expected-note@33:14 {{}} // opening_paren
// expected-error@33:19 {{}} // avail_query_expected_rparen
// expected-warning@39:19 {{}} // avail_query_expected_version_number
// expected-warning@42:19 {{}} // avail_query_expected_version_number
// expected-note@45:14 {{}} // opening_paren
// expected-error@45:22 {{}} // avail_query_expected_rparen
// expected-warning@48:29 {{}} // avail_query_expected_version_number
// expected-note@80:15 {{}} // avail_query_meant_introduced
// expected-error@80:40 {{}} // avail_query_argument_and_shorthand_mix_not_allowed
// expected-note@89:14 {{}} // opening_paren
// expected-error@89:17 {{}} // avail_query_expected_rparen
// expected-note@97:14 {{}} // opening_paren
// expected-error@97:23 2 {{}} // avail_query_expected_platform_name,avail_query_expected_rparen
// expected-error@100:22 {{}} // avail_query_expected_platform_name
// expected-note@103:14 {{}} // opening_paren
// expected-error@103:27 {{}} // avail_query_expected_rparen
// expected-error@114:22 {{}} // avail_query_disallowed_operator
// expected-error@119:19 {{}} // avail_query_version_comparison_not_needed
// ---- end ASTGen parity ----
