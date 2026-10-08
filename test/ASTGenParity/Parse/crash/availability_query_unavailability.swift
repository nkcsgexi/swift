// RUN; %target-typecheck-verify-swift
// REQUIRES; OS=macosx
// This file is mostly an inverted version of availability_query.swift
if #unavailable(OSX 51) {
}

// Disallow explicit wildcards.
if #unavailable(OSX 51, *) {} // expected_error {{platform wildcard '*' is always implicit in #unavailable}} {{25-26=}}
// Disallow use as an expression.
if (#unavailable(OSX 51)) {}  // expected_error {{#unavailable may only be used as condition of an 'if', 'guard'}}
let x = #unavailable(OSX 51)  // expected_error {{#unavailable may only be used as condition of}}
(#unavailable(OSX 51) ? 1 : 0) // expected_error {{#unavailable may only be used as condition of an}}
if !#unavailable(OSX 52) { // expected_error {{#unavailable may only be used as condition of an}}
}
if let _ = Optional(5), !#unavailable(OSX 52) { // expected_error {{#unavailable may only be used as condition}}
}

if #unavailable(OSX 51) && #unavailable(OSX 52) { // expected_error {{expected ',' joining parts of a multi-clause condition}} {{24-27=,}}
}


if #unavailable { // expected_error {{expected availability condition}}
}

if #unavailable( { // expected_error {{expected platform name}} expected_error {{expected ')'}} expected_note {{to match this opening '('}}
}

if #unavailable() { // expected_error {{expected platform name}}
}

if #unavailable(OSX { // expected_error {{expected ')'}} expected_note {{to match this opening '('}}
}

if #unavailable(OSX) { // expected_error {{expected version number}}
}

if #unavailable(OSX 51 { // expected_error {{expected ')'}} expected_note {{to match this opening '('}}
}

if #unavailable(iDishwasherOS 51) { // expected_warning {{cannot find availability domain 'iDishwasherOS'}}
}

if #unavailable(iDishwasherOS 51) { // expected_warning {{cannot find availability domain 'iDishwasherOS'}}
}

if #unavailable(macos 51) { // expected_warning {{cannot find availability domain 'macos'; did you mean 'macOS'?}} {{17-22=macOS}}
}

if #unavailable(mscos 51) { // expected_warning {{cannot find availability domain 'mscos'; did you mean 'macOS'?}} {{17-22=macOS}}
}

if #unavailable(macoss 51) { // expected_warning {{cannot find availability domain 'macoss'; did you mean 'macOS'?}} {{17-23=macOS}}
}

if #unavailable(mac 51) { // expected_warning {{cannot find availability domain 'mac'; did you mean 'macOS'?}} {{17-20=macOS}}
}

if #unavailable(OSX 51, OSX 52) {  // expected_error {{version for macOS already specified}}
}

if #unavailable(OSX 51, iOS 8.0, *) { }  // expected_error {{platform wildcard '*' is always implicit in #unavailable}} {{34-35=}}
if #unavailable(iOS 8.0) {
}

if #unavailable(iOSApplicationExtension, unavailable) { // expected_error {{'unavailable' can't be combined with shorthand specification 'iOSApplicationExtension'}}
// expected_note@-1 {{did you mean to specify an introduction version?}}
}

// Should this be a valid spelling since `#unvailable(*)` cannot be written?
if #unavailable() { // expected_error {{expected platform name}}
}

if #unavailable(OSX 10 { // expected_error {{expected ')' in availability query}} expected_note {{to match this opening '('}}
}

// Multiple platforms
if #unavailable(OSX 51, iOS 8.0) {
}


if #unavailable(OSX 51, { // expected_error {{expected platform name}} // expected_error {{expected ')'}} expected_note {{to match this opening '('}}
}

if #unavailable(OSX 51, iOS { // expected_error {{expected ')'}} expected_note {{to match this opening '('}}
}

if #unavailable(OSX 51, iOS 8.0, iDishwasherOS 51) { // expected_warning {{cannot find availability domain 'iDishwasherOS'}}
}

if #unavailable(iDishwasherOS 51, OSX 51) { // expected_warning {{cannot find availability domain 'iDishwasherOS'}}
}

if #unavailable(OSX 51 || iOS 8.0) {// expected_error {{'||' cannot be used in an availability condition}}
}

// Emit Fix-It removing un-needed >=, for the moment.
if #unavailable(OSX >= 51) { // expected_error {{version comparison not needed}} {{21-24=}}
}

// Bool then #unavailable.
if 1 != 2, #unavailable(iOS 8.0) {}

// Pattern then #unavailable(iOS 8.0) {
if case 42 = 42, #unavailable(iOS 8.0) {}
if let _ = Optional(42), #unavailable(iOS 8.0) {}

// Allow "macOS" as well.
if #unavailable(macOS 51) {
}

// Prevent availability and unavailability being present in the same statement.
if #unavailable(macOS 51), #available(macOS 52, *) { // expected_error {{#available and #unavailable cannot be in the same statement}}
}
if #available(macOS 51, *), #unavailable(macOS 52) { // expected_error {{#available and #unavailable cannot be in the same statement}}
}
if #available(macOS 51, *), #available(macOS 55, *), #unavailable(macOS 53) { // expected_error {{#available and #unavailable cannot be in the same statement}}
}
if #unavailable(macOS 51), #unavailable(macOS 55), #available(macOS 53, *) { // expected_error {{#available and #unavailable cannot be in the same statement}}
}
if case 42 = 42, #available(macOS 51, *), #unavailable(macOS 52) { // expected_error {{#available and #unavailable cannot be in the same statement}}
}
if #available(macOS 51, *), case 42 = 42, #unavailable(macOS 52) { // expected_error {{#available and #unavailable cannot be in the same statement}}
}

// Allow availability and unavailability to mix if they are not in the same statement.
if #unavailable(macOS 51) {
  if #available(macOS 50, *) { }
}
if #available(macOS 50, *) {
  if #unavailable(macOS 51) { }
}

// Diagnose wrong spellings of unavailability
if #available(*) == false { // expected_error {{#available cannot be used as an expression, did you mean to use '#unavailable'?}} {{4-14=#unavailable}} {{18-27=}}
}
if !#available(*) { // expected_error {{#available cannot be used as an expression, did you mean to use '#unavailable'?}} {{4-15=#unavailable}}
} 
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/availability_query_unavailability.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// REQUIRES: OS=macosx
// XFAIL: *
// expected-error@10:5 {{}} // special_condition_outside_if_stmt_guard
// expected-error@11:9 {{}} // special_condition_outside_if_stmt_guard
// expected-error@12:2 {{}} // special_condition_outside_if_stmt_guard
// expected-error@13:5 {{}} // special_condition_outside_if_stmt_guard
// expected-error@15:26 {{}} // special_condition_outside_if_stmt_guard
// expected-error@18:25 {{}} // expected_comma_stmtcondition
// expected-error@22:17 {{}} // avail_query_expected_condition
// expected-note@25:16 {{}} // opening_paren
// expected-error@25:18 2 {{}} // avail_query_expected_platform_name,avail_query_expected_rparen
// expected-error@28:17 {{}} // avail_query_expected_platform_name
// expected-note@31:16 {{}} // opening_paren
// expected-error@31:21 {{}} // avail_query_expected_rparen
// expected-note@37:16 {{}} // opening_paren
// expected-error@37:24 {{}} // avail_query_expected_rparen
// expected-note@65:17 {{}} // avail_query_meant_introduced
// expected-error@65:42 {{}} // avail_query_argument_and_shorthand_mix_not_allowed
// expected-error@70:17 {{}} // avail_query_expected_platform_name
// expected-note@73:16 {{}} // opening_paren
// expected-error@73:24 {{}} // avail_query_expected_rparen
// expected-note@81:16 {{}} // opening_paren
// expected-error@81:25 2 {{}} // avail_query_expected_platform_name,avail_query_expected_rparen
// expected-note@84:16 {{}} // opening_paren
// expected-error@84:29 {{}} // avail_query_expected_rparen
// expected-error@93:24 {{}} // avail_query_disallowed_operator
// expected-error@97:21 {{}} // avail_query_version_comparison_not_needed
// expected-error@134:18 {{}} // false_available_is_called_unavailable
// expected-error@136:4 {{}} // false_available_is_called_unavailable
// ---- end ASTGen parity ----
