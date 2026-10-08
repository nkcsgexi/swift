// RUN; %target-typecheck-verify-swift

// TODO: Implement tuple equality in the library.
// BLOCKED: <rdar://problem/13822406>
func ~= (x: (Int,Int), y: (Int,Int)) -> Bool {
  return true
}

func parseError1(x: Int) {
  switch func {} // expected_error {{expected expression in 'switch' statement}} expected_error {{expected identifier in function declaration}}
}

func parseError2(x: Int) {
  switch x // expected_error {{expected '{' after 'switch' subject expression}}
}

func parseError3(x: Int) {
  switch x {
    case // expected_error {{expected pattern}} expected_error {{expected ':' after 'case'}}
  }
}

func parseError4(x: Int) {
  switch x {
  case var z where // expected_error {{expected expression for 'where' guard of 'case'}} expected_error {{expected ':' after 'case'}}
  }
}

func parseError5(x: Int) {
  switch x {
  case let z // expected_error {{expected ':' after 'case'}} expected_warning {{immutable value 'z' was never used}} {{8-13=_}}
  }
}

func parseError6(x: Int) {
  switch x {
  default // expected_error {{expected ':' after 'default'}}
  }
}

var x: Int

switch x {} // expected_error {{'switch' statement body must have at least one 'case' or 'default' block}}

switch x {
case 0:
  x = 0
// Multiple patterns per case
case 1, 2, 3:
  x = 0
// 'where' guard
case _ where x % 2 == 0:
  x = 1
  x = 2
  x = 3
case _ where x % 2 == 0,
     _ where x % 3 == 0:
  x = 1
case 10,
     _ where x % 3 == 0:
  x = 1
case _ where x % 2 == 0,
     20:
  x = 1
case var y where y % 2 == 0:
  x = y + 1
case _ where 0: // expected_error {{integer literal value '0' cannot be used as a boolean; did you mean 'false'?}}
  x = 0
default:
  x = 1
}

// Multiple cases per case block
switch x { // expected_error {{switch must be exhaustive}} expected_note{{add a default clause}}
case 0: // expected_error {{'case' label in a 'switch' must have at least one executable statement}} {{8-8= break}}
case 1, case 2: // expected_error {{extraneous 'case' keyword in pattern}} {{9-14=}}
  x = 0
}

switch x {
case 0: // expected_error{{'case' label in a 'switch' must have at least one executable statement}} {{8-8= break}}
default:
  x = 0
}

switch x { // expected_error {{switch must be exhaustive}} expected_note{{add a default clause}}
case 0:
  x = 0
case 1: // expected_error {{'case' label in a 'switch' must have at least one executable statement}} {{8-8= break}}
}

switch x {
case 0:
  x = 0
default: // expected_error {{'default' label in a 'switch' must have at least one executable statement}} {{9-9= break}}
}

switch x { // expected_error {{switch must be exhaustive}} expected_note{{add a default clause}}
case 0:
  ; // expected_error {{';' statements are not allowed}} {{3-5=}}
case 1:
  x = 0
}



switch x {
  x = 1 // expected_error{{all statements inside a switch must be covered by a 'case' or 'default'}}
default:
  x = 0
case 0: // expected_error{{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}}
  x = 0
case 1:
  x = 0
}

switch x {
default:
  x = 0
default: // expected_error{{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}}
  x = 0
}

switch x { // expected_error{{'switch' statement body must have at least one 'case' or 'default' block}}
  x = 1 // expected_error{{all statements inside a switch must be covered by a 'case' or 'default'}}
}

switch x { // expected_error{{'switch' statement body must have at least one 'case' or 'default' block}}
  x = 1 // expected_error{{all statements inside a switch must be covered by a 'case' or 'default'}}
  x = 2
}

switch x {
default: // expected_error{{'default' label in a 'switch' must have at least one executable statement}} {{9-9= break}}
case 0: // expected_error{{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}}
  x = 0
}

switch x {
default: // expected_error{{'default' label in a 'switch' must have at least one executable statement}} {{9-9= break}}
default: // expected_error{{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}}
  x = 0
}

switch x { // expected_error {{switch must be exhaustive}} expected_note{{add a default clause}}
default where x == 0: // expected_error{{'default' cannot be used with a 'where' guard expression}}
  x = 0
}

switch x { // expected_error {{switch must be exhaustive}} expected_note{{add a default clause}}
case 0: // expected_error {{'case' label in a 'switch' must have at least one executable statement}} {{8-8= break}}
}

switch x { // expected_error {{switch must be exhaustive}} expected_note{{add a default clause}}
case 0: // expected_error{{'case' label in a 'switch' must have at least one executable statement}} {{8-8= break}}
case 1:
  x = 0
}

switch x { // expected_error {{switch must be exhaustive}} expected_note{{add a default clause}}
case 0:
  x = 0
case 1: // expected_error{{'case' label in a 'switch' must have at least one executable statement}} {{8-8= break}}
}


case 0: // expected_error{{'case' label can only appear inside a 'switch' statement}}
var y = 0
default: // expected_error{{'default' label can only appear inside a 'switch' statement}}
var z = 1

fallthrough // expected_error{{'fallthrough' is only allowed inside a switch}}

switch x {
case 0:
  fallthrough
case 1:
  fallthrough
default:
  fallthrough // expected_error{{'fallthrough' without a following 'case' or 'default' block}}
}

// Fallthrough can transfer control anywhere within a case and can appear
// multiple times in the same case.
switch x {
case 0:
  if true { fallthrough }
  if false { fallthrough }
  x += 1
default:
  x += 1
}

// Cases cannot contain 'var' bindings if there are multiple matching patterns
// attached to a block. They may however contain other non-binding patterns.

var t = (1, 2)

switch t {
case (var a, 2), (1, _): // expected_error {{'a' must be bound in every pattern}} expected_warning {{variable 'a' was never used; consider replacing with '_' or removing it}}
  ()

case (_, 2), (var a, _): // expected_error {{'a' must be bound in every pattern}} expected_warning {{variable 'a' was never used; consider replacing with '_' or removing it}}
  ()

case (var a, 2), (1, var b): // expected_error {{'a' must be bound in every pattern}} expected_error {{'b' must be bound in every pattern}} expected_warning {{variable 'a' was never used; consider replacing with '_' or removing it}} expected_warning {{variable 'b' was never used; consider replacing with '_' or removing it}}
  ()

case (var a, 2): // expected_error {{'case' label in a 'switch' must have at least one executable statement}} {{17-17= break}} expected_warning {{variable 'a' was never used; consider replacing with '_' or removing it}}
case (1, _):
  ()

case (_, 2): // expected_error {{'case' label in a 'switch' must have at least one executable statement}} {{13-13= break}}
case (1, var a): // expected_warning {{variable 'a' was never used; consider replacing with '_' or removing it}}
  ()

case (var a, 2): // expected_error {{'case' label in a 'switch' must have at least one executable statement}} {{17-17= break}} expected_warning {{variable 'a' was never used; consider replacing with '_' or removing it}}
case (1, var b): // expected_warning {{variable 'b' was never used; consider replacing with '_' or removing it}}
  ()

case (1, let b): // let bindings expected_warning {{immutable value 'b' was never used; consider replacing with '_' or removing it}}
  ()

case (_, 2), (let a, _): // expected_error {{'a' must be bound in every pattern}} expected_warning {{case is already handled by previous patterns; consider removing it}} expected_warning {{immutable value 'a' was never used; consider replacing with '_' or removing it}}
  ()

// OK
case (_, 2), (1, _):
  ()
  
case (_, var a), (_, var a): // expected_warning {{variable 'a' was never used; consider replacing with '_' or removing it}}
  // expected_warning@-1 {{case is already handled by previous patterns; consider removing it}}
  // expected_warning@-2 {{case is already handled by previous patterns; consider removing it}}
  ()
  
case (var a, var b), (var b, var a): // expected_warning {{variable 'a' was never used; consider replacing with '_' or removing it}} expected_warning {{variable 'b' was never used; consider replacing with '_' or removing it}}
  // expected_warning@-1 {{case is already handled by previous patterns; consider removing it}}
  // expected_warning@-2 {{case is already handled by previous patterns; consider removing it}}
  ()

case (_, 2): // expected_error {{'case' label in a 'switch' must have at least one executable statement}} {{13-13= break}}
case (1, _):
  ()
}

func patternVarUsedInAnotherPattern(x: Int) {
  switch x {
  case let a, // expected_error {{'a' must be bound in every pattern}}
       value: // expected_error {{cannot find 'value' in scope}}
    break
  }
}

// Fallthroughs can only transfer control into a case label with bindings if the previous case binds a superset of those vars.
switch t {
case (1, 2):
  fallthrough // expected_error {{'fallthrough' from a case which doesn't bind variable 'a'}} expected_error {{'fallthrough' from a case which doesn't bind variable 'b'}}
case (var a, var b): // expected_warning {{variable 'a' was never mutated; consider changing to 'let' constant}} expected_warning {{variable 'b' was never mutated; consider changing to 'let' constant}}
  t = (b, a)
}

switch t { // specifically notice on next line that we shouldn't complain that a is unused - just never mutated
case (var a, let b): // expected_warning {{variable 'a' was never mutated; consider changing to 'let' constant}}
  t = (b, b)
  fallthrough // ok - notice that subset of bound variables falling through is fine
case (2, let a):
  t = (a, a)
}

func patternVarDiffType(x: Int, y: Double) {
  switch (x, y) {
  case (1, let a): // expected_error {{pattern variable bound to type 'Double', fallthrough case bound to type 'Int'}}
    fallthrough
  case (let a, _):
    break
  }
}

func patternVarDiffMutability(x: Int, y: Double) {
  switch x {
  case let a where a < 5, var a where a > 10: // expected_error {{'var' pattern binding must match previous 'let' pattern binding}}{{27-30=let}}
    break
  default:
    break
  }
  switch (x, y) {
  // Would be nice to have a fixit in the following line if we detect that all bindings in the same pattern have the same problem.
  case let (a, b) where a < 5, var (a, b) where a > 10: // expected_error 2{{'var' pattern binding must match previous 'let' pattern binding}}{{none}}
    break
  case (let a, var b) where a < 5, (let a, let b) where a > 10: // expected_error {{'let' pattern binding must match previous 'var' pattern binding}}{{44-47=var}}
    break
  case (let a, let b) where a < 5, (var a, let b) where a > 10, (let a, var b) where a == 8:
    // expected_error@-1 {{'var' pattern binding must match previous 'let' pattern binding}}{{37-40=let}}
    // expected_error@-2 {{'var' pattern binding must match previous 'let' pattern binding}}{{73-76=let}}
    break
  default:
    break
  }
}

func test_label(x : Int) {
Gronk: // expected_error {{switch must be exhaustive}} expected_note{{add a default clause}}
  switch x {
  case 42: return
  }
}

func enumElementSyntaxOnTuple() {
  switch (1, 1) {
  case .Bar: // expected_error {{value of tuple type '(Int, Int)' has no member 'Bar'}}
    break
  default:
    break
  }
}

// https://github.com/apple/swift/issues/42798
enum Whatever { case Thing }
func f0(values: [Whatever]) { // expected_note {{'values' declared here}}
    switch value { // expected_error {{cannot find 'value' in scope; did you mean 'values'?}}
    case .Thing: // Ok. Don't emit diagnostics about enum case not found in type <<error type>>.
        break
    }
}

// https://github.com/apple/swift/issues/43334
// https://github.com/apple/swift/issues/43335
enum Whichever {
  case Thing
  static let title = "title"
  static let alias: Whichever = .Thing
}
func f1(x: String, y: Whichever) {
  switch x {
    case Whichever.title: // Ok. Don't emit diagnostics for static member of enum.
        break
    case Whichever.buzz: // expected_error {{type 'Whichever' has no member 'buzz'}}
        break
    // expected_note @+1 {{overloads for '~=' exist with these partially matching parameter lists: (Substring, String)}}
    case Whichever.alias: // expected_error {{expression pattern of type 'Whichever' cannot match values of type 'String'}}
    // expected_error@-1 {{'case' label in a 'switch' must have at least one executable statement}}
    default:
      break
  }
  switch y {
    case Whichever.Thing: // Ok.
        break
    case Whichever.alias: // Ok. Don't emit diagnostics for static member of enum.
        break
    case Whichever.title: // expected_error {{expression pattern of type 'String' cannot match values of type 'Whichever'}}
        break
  }
  switch y {
    case .alias:
      break
    default:
      break
  }
}


switch Whatever.Thing {
case .Thing: // expected_error{{'case' label in a 'switch' must have at least one executable statement}} {{13-13= break}}
@unknown case _:
  x = 0
}

switch Whatever.Thing {
case .Thing: // expected_error{{'case' label in a 'switch' must have at least one executable statement}} {{13-13= break}}
@unknown default:
  x = 0
}

switch Whatever.Thing {
case .Thing:
  x = 0
@unknown case _: // expected_error {{'case' label in a 'switch' must have at least one executable statement}} {{17-17= break}}
}

switch Whatever.Thing {
case .Thing:
  x = 0
@unknown default: // expected_error {{'default' label in a 'switch' must have at least one executable statement}} {{18-18= break}}
}


switch Whatever.Thing {
@unknown default:
  x = 0
default: // expected_error{{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}}
  x = 0
case .Thing:
  x = 0
}

switch Whatever.Thing {
default:
  x = 0
@unknown case _: // expected_error{{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}} expected_error {{'@unknown' can only be applied to the last case in a switch}}
  x = 0
case .Thing:
  x = 0
}

switch Whatever.Thing {
default:
  x = 0
@unknown default: // expected_error{{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}}
  x = 0
case .Thing:
  x = 0
}

switch Whatever.Thing { // expected_warning {{switch must be exhaustive}} expected_note{{add missing case: '.Thing'}}
@unknown default where x == 0: // expected_error{{'default' cannot be used with a 'where' guard expression}}
  x = 0
}

switch Whatever.Thing { // expected_warning {{switch must be exhaustive}} expected_note{{add missing case: '.Thing'}}
@unknown case _:
  fallthrough // expected_error{{'fallthrough' without a following 'case' or 'default' block}}
}

switch Whatever.Thing {
@unknown case _: // expected_error {{'@unknown' can only be applied to the last case in a switch}}
  fallthrough
case .Thing:
  break
}

switch Whatever.Thing {
@unknown default:
  fallthrough
case .Thing: // expected_error{{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}}
  break
}

switch Whatever.Thing {
@unknown case _, _: // expected_error {{'@unknown' cannot be applied to multiple patterns}}
  break
}

switch Whatever.Thing {
@unknown case _, _, _: // expected_error {{'@unknown' cannot be applied to multiple patterns}}
  break
}

switch Whatever.Thing { // expected_warning {{switch must be exhaustive}} expected_note{{add missing case: '.Thing'}}
@unknown case let value: // expected_error {{'@unknown' is only supported for catch-all cases ("case _")}}
  _ = value
}

switch (Whatever.Thing, Whatever.Thing) { // expected_warning {{switch must be exhaustive}} expected_note{{add missing case: '(_, _)'}}
@unknown case (_, _): // expected_error {{'@unknown' is only supported for catch-all cases ("case _")}}
  break
}

switch Whatever.Thing { // expected_warning {{switch must be exhaustive}} expected_note{{add missing case: '.Thing'}}
@unknown case is Whatever: // expected_error {{'@unknown' is only supported for catch-all cases ("case _")}}
  // expected_warning@-1 {{'is' test is always true}}
  break
}

switch Whatever.Thing { // expected_warning {{switch must be exhaustive}} expected_note{{add missing case: '.Thing'}}
@unknown case .Thing: // expected_error {{'@unknown' is only supported for catch-all cases ("case _")}}
  break
}

switch Whatever.Thing { // expected_warning {{switch must be exhaustive}} expected_note{{add missing case: '.Thing'}}
@unknown case (_): // okay
  break
}

switch Whatever.Thing { // expected_warning {{switch must be exhaustive}} expected_note{{add missing case: '.Thing'}}
@unknown case _ where x == 0: // expected_error {{'where' cannot be used with '@unknown'}}
  break
}

switch Whatever.Thing { // expected_warning {{switch must be exhaustive}} expected_note{{add missing case: '.Thing'}}
@unknown default where x == 0: // expected_error {{'default' cannot be used with a 'where' guard expression}}
  break
}

switch Whatever.Thing {
case .Thing:
  x = 0
#if true
@unknown case _:
  x = 0
#endif
}

switch x {
case 0:
  break
@garbage case _: // expected_error {{unknown attribute 'garbage'}}
  break
}

switch x {
case 0:
  break
@garbage @moreGarbage default: // expected_error {{unknown attribute 'garbage'}} expected_error {{unknown attribute 'moreGarbage'}}
  break
}

@unknown let _ = 1 // expected_error {{unknown attribute 'unknown'}}

switch x {
case _:
  @unknown let _ = 1 // expected_error {{unknown attribute 'unknown'}}
}

switch Whatever.Thing {
case .Thing:
  break
@unknown(garbage) case _: // expected_error {{unexpected '(' in attribute 'unknown'}}
  break
}
switch Whatever.Thing {
case .Thing:
  break
@unknown // expected_note {{attribute already specified here}}
@unknown // expected_error {{duplicate attribute}}
case _:
  break
}
switch Whatever.Thing { // expected_warning {{switch must be exhaustive}} expected_note {{add missing case: '.Thing'}}
@unknown @garbage(foobar) // expected_error {{unknown attribute 'garbage'}}
case _:
  break
}

switch x { // expected_error {{switch must be exhaustive}}
case 1:
  break
@unknown case _: // expected_note {{remove '@unknown' to handle remaining values}} {{1-10=}}
  break
}

switch x { // expected_error {{switch must be exhaustive}}
@unknown case _: // expected_note {{remove '@unknown' to handle remaining values}} {{1-10=}}
  break
}

switch x { // expected_error {{switch must be exhaustive}}
@unknown default: // expected_note {{remove '@unknown' to handle remaining values}} {{1-10=}}
  break
}

switch Whatever.Thing {
case .Thing:
  break
@unknown case _: // expected_error {{'@unknown' can only be applied to the last case in a switch}}
  break
@unknown case _:
  break
}

switch Whatever.Thing {
case .Thing:
  break
@unknown case _: // expected_error {{'@unknown' can only be applied to the last case in a switch}}
  break
@unknown default:
  break
}

switch Whatever.Thing {
case .Thing:
  break
@unknown default:
  break
@unknown default: // expected_error {{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}}
  break
}

switch Whatever.Thing {
@unknown case _: // expected_error {{'@unknown' can only be applied to the last case in a switch}}
  break
@unknown case _:
  break
}

switch Whatever.Thing {
@unknown case _: // expected_error {{'@unknown' can only be applied to the last case in a switch}}
  break
@unknown default:
  break
}

switch Whatever.Thing {
@unknown default:
  break
@unknown default: // expected_error {{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}}
  break
}


switch x {
@unknown case _: // expected_error {{'@unknown' can only be applied to the last case in a switch}}
  break
@unknown case _:
  break
}

switch x {
@unknown case _: // expected_error {{'@unknown' can only be applied to the last case in a switch}}
  break
@unknown default:
  break
}

switch x {
@unknown default:
  break
@unknown default: // expected_error {{additional 'case' blocks cannot appear after the 'default' block of a 'switch'}}
  break
}

func testReturnBeforeUnknownDefault() {
  switch x { // expected_error {{switch must be exhaustive}}
  case 1:
    return
  @unknown default: // expected_note {{remove '@unknown' to handle remaining values}}
    break
  }
}

func testReturnBeforeIncompleteUnknownDefault() {
  switch x { // expected_error {{switch must be exhaustive}}
  case 1:
    return
  @unknown default // expected_error {{expected ':' after 'default'}}
  // expected_note@-1 {{remove '@unknown' to handle remaining values}}
  }
}

func testReturnBeforeIncompleteUnknownDefault2() {
  switch x { // expected_error {{switch must be exhaustive}} expected_note {{add a default clause}}
  case 1:
    return
  @unknown // expected_error {{unknown attribute 'unknown'}}
  } // expected_error {{expected declaration}}
}

func testIncompleteArrayLiteral() {
  switch x { // expected_error {{switch must be exhaustive}}
  case 1:
    _ = [1 // expected_error {{expected ']' in container literal expression}} expected_note {{to match this opening '['}}
  @unknown default: // expected_note {{remove '@unknown' to handle remaining values}}
    ()
  }
}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/switch.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@10:10 {{}} // expected_switch_expr
// expected-error@10:15 {{}} // expected_identifier_in_decl
// expected-error@14:11 {{}} // expected_lbrace_after_switch
// expected-error@19:9 2 {{}} // expected_case_colon,expected_pattern
// expected-error@25:19 2 {{}} // expected_case_colon,expected_case_where_expr
// expected-error@31:13 {{}} // expected_case_colon
// expected-error@37:10 {{}} // expected_case_colon
// expected-error@75:1 {{}} // case_stmt_without_body
// expected-error@76:9 {{}} // extra_case_keyword
// expected-error@81:1 {{}} // case_stmt_without_body
// expected-error@89:1 {{}} // case_stmt_without_body
// expected-error@95:1 {{}} // case_stmt_without_body
// expected-error@100:3 {{}} // illegal_semi_stmt
// expected-error@108:3 {{}} // stmt_in_switch_not_covered_by_case
// expected-error@111:1 {{}} // case_after_default
// expected-error@120:1 {{}} // case_after_default
// expected-error@125:3 {{}} // stmt_in_switch_not_covered_by_case
// expected-error@129:3 {{}} // stmt_in_switch_not_covered_by_case
// expected-error@134:1 {{}} // case_stmt_without_body
// expected-error@135:1 {{}} // case_after_default
// expected-error@140:1 {{}} // case_stmt_without_body
// expected-error@141:1 {{}} // case_after_default
// expected-error@146:9 {{}} // default_with_where
// expected-error@151:1 {{}} // case_stmt_without_body
// expected-error@155:1 {{}} // case_stmt_without_body
// expected-error@163:1 {{}} // case_stmt_without_body
// expected-error@167:1 {{}} // case_outside_of_switch
// expected-error@169:1 {{}} // case_outside_of_switch
// expected-error@200:11 {{}} // extra_var_in_multiple_pattern_list
// expected-error@203:19 {{}} // extra_var_in_multiple_pattern_list
// expected-error@206:11 {{}} // extra_var_in_multiple_pattern_list
// expected-error@206:26 {{}} // extra_var_in_multiple_pattern_list
// expected-error@209:1 {{}} // case_stmt_without_body
// expected-error@213:1 {{}} // case_stmt_without_body
// expected-error@217:1 {{}} // case_stmt_without_body
// expected-error@224:19 {{}} // extra_var_in_multiple_pattern_list
// expected-error@241:1 {{}} // case_stmt_without_body
// expected-error@248:12 {{}} // extra_var_in_multiple_pattern_list
// expected-error@340:5 {{}} // case_stmt_without_body
// expected-error@363:1 {{}} // case_stmt_without_body
// expected-error@369:1 {{}} // case_stmt_without_body
// expected-error@377:10 {{}} // case_stmt_without_body
// expected-error@383:10 {{}} // case_stmt_without_body
// expected-error@390:1 {{}} // case_after_default
// expected-error@399:10 {{}} // case_after_default
// expected-error@408:10 {{}} // case_after_default
// expected-error@415:18 {{}} // default_with_where
// expected-error@434:1 {{}} // case_after_default
// expected-error@480:18 {{}} // default_with_where
// expected-error@496:2 {{}} // unknown_attr_name
// expected-error@503:2 {{}} // unknown_attr_name
// expected-error@503:11 {{}} // unknown_attr_name
// expected-error@507:2 {{}} // unknown_attr_name
// expected-error@511:4 {{}} // unknown_attr_name
// expected-error@517:9 {{}} // unexpected_lparen_in_attribute
// expected-note@523:1 {{}} // previous_attribute
// expected-error@524:1 {{}} // duplicate_attribute
// expected-error@529:11 {{}} // unknown_attr_name
// expected-error@574:10 {{}} // case_after_default
// expected-error@595:10 {{}} // case_after_default
// expected-error@617:10 {{}} // case_after_default
// expected-error@634:19 {{}} // expected_case_colon
// expected-error@643:4 {{}} // unknown_attr_name
// expected-error@644:3 {{}} // expected_decl
// expected-note@650:9 {{}} // opening_bracket
// expected-error@650:11 {{}} // expected_rsquare_array_expr
// ---- end ASTGen parity ----
