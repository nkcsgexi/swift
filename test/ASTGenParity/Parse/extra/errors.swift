// RUN; %target-typecheck-verify-swift

enum MSV : Error {
  case Foo, Bar, Baz
  case CarriesInt(Int)

  var _domain: String { return "" }
  var _code: Int { return 0 }
}

func opaque_error() -> Error { return MSV.Foo }

func one() {
  do {
    true ? () : throw opaque_error() // expected_error {{expected expression after '? ... :' in ternary expression}}
  } catch _ {
  }

  do {
    
  } catch { // expected_warning {{'catch' block is unreachable because no errors are thrown in 'do' block}}
    let error2 = error
  }

  do {
  } catch where true { // expected_warning {{'catch' block is unreachable because no errors are thrown in 'do' block}}
    let error2 = error
  } catch {
  }
  
  // <rdar://problem/20985280> QoI: improve diagnostic on improper pattern match on type
  do {
    throw opaque_error()
  } catch MSV { // expected_error {{'is' keyword required to pattern match against type name}} {{11-11=is }}
  } catch {
  }

  do {
    throw opaque_error()
  } catch is Error {  // expected_warning {{'is' test is always true}}
  }
  
  func foo() throws {}
  
  do {
#if false
    try foo()
#endif
  } catch {    // don't warn, #if code should be scanned.
  }

  do {
#if compiler(>=10)
    throw opaque_error()
#endif
  } catch {    // don't warn, #if code should be scanned.
  }

  do {
#if false
    throw opaque_error()
#endif
  } catch {    // don't warn, #if code should be scanned.
  }
  
  do {
    throw opaque_error()
  } catch MSV.Foo, MSV.CarriesInt(let num) { // expected_error {{'num' must be bound in every pattern}}
  } catch {
  }
}

func takesAutoclosure(_ fn : @autoclosure () -> Int) {}
func takesThrowingAutoclosure(_ fn : @autoclosure () throws -> Int) {}

func genError() throws -> Int { throw MSV.Foo }
func genNoError() -> Int { return 0 }

func testAutoclosures() throws {
  takesAutoclosure(genError()) // expected_error {{call can throw, but it is not marked with 'try' and it is executed in a non-throwing autoclosure}}
  takesAutoclosure(genNoError())

  try takesAutoclosure(genError()) // expected_error {{call can throw, but it is executed in a non-throwing autoclosure}}
  try takesAutoclosure(genNoError()) // expected_warning {{no calls to throwing functions occur within 'try' expression}}

  takesAutoclosure(try genError()) // expected_error {{call can throw, but it is executed in a non-throwing autoclosure}}
  takesAutoclosure(try genNoError()) // expected_warning {{no calls to throwing functions occur within 'try' expression}}

  takesThrowingAutoclosure(try genError())
  takesThrowingAutoclosure(try genNoError()) // expected_warning {{no calls to throwing functions occur within 'try' expression}}

  try takesThrowingAutoclosure(genError())
  try takesThrowingAutoclosure(genNoError()) // expected_warning {{no calls to throwing functions occur within 'try' expression}}

  takesThrowingAutoclosure(genError()) // expected_error {{call can throw but is not marked with 'try'}}
                                       // expected_note@-1 {{did you mean to use 'try'?}} {{28-28=try }}
                                       // expected_note@-2 {{did you mean to handle error as optional value?}} {{28-28=try? }}
                                       // expected_note@-3 {{did you mean to disable error propagation?}} {{28-28=try! }}
  takesThrowingAutoclosure(genNoError())
}

func illformed() throws {
    do {
      _ = try genError()

    } catch MSV.CarriesInt(let i) where i == genError()) { // expected_error {{call can throw, but errors cannot be thrown out of a catch guard expression}} expected_error {{expected '{'}}
    }
}

func postThrows() -> Int throws { // expected_error{{'throws' may only occur before '->'}}{{19-19=throws }}{{26-33=}}
  return 5
}

func postThrows2() -> throws Int { // expected_error{{'throws' may only occur before '->'}}{{20-20=throws }}{{23-30=}}
  return try postThrows()
}

func postRethrows(_ f: () throws -> Int) -> Int rethrows { // expected_error{{'rethrows' may only occur before '->'}}{{42-42=rethrows }}{{49-58=}}
  return try f()
}

func postRethrows2(_ f: () throws -> Int) -> rethrows Int { // expected_error{{'rethrows' may only occur before '->'}}{{43-43=rethrows }}{{46-55=}}
  return try f()
}

func postThrows3() {
  _ = { () -> Int throws in } // expected_error {{'throws' may only occur before '->'}} {{19-26=}} {{12-12=throws }}
}

func dupThrows1() throws rethrows -> throws Int throw {}
// expected_error@-1 {{'rethrows' has already been specified}} {{26-35=}}
// expected_error@-2 {{'throws' has already been specified}} {{38-45=}}
// expected_error@-3 {{'throw' has already been specified}} {{49-55=}}

func dupThrows2(_ f: () throws -> rethrows Int) {}
// expected_error@-1 {{'rethrows' has already been specified}} {{35-44=}}

func dupThrows3() {
  _ = { () try throws in }
// expected_error@-1 {{expected throwing specifier; did you mean 'throws'?}} {{12-15=throws}}
// expected_error@-2 {{'throws' has already been specified}} {{16-23=}}

  _ = { () throws -> Int throws in }
// expected_error@-1 {{'throws' has already been specified}} {{26-33=}}
}

func incompleteThrowType() {
  // FIXME: Bad recovery for incomplete function type.
  let _: () throws
  // expected_error @-1 {{consecutive statements on a line must be separated by ';'}}
  // expected_error @-2 {{expected expression}}
}

// rdar://21328447
func fixitThrow0() throw {} // expected_error{{expected throwing specifier; did you mean 'throws'?}} {{20-25=throws}}
func fixitThrow1() throw -> Int {} // expected_error{{expected throwing specifier; did you mean 'throws'?}} {{20-25=throws}}
func fixitThrow2() throws {
  var _: (Int)
  throw MSV.Foo
  var _: (Int) throw -> Int // expected_error{{expected throwing specifier; did you mean 'throws'?}} {{16-21=throws}}
}

let fn: () -> throws Void  // expected_error{{'throws' may only occur before '->'}} {{12-12=throws }} {{15-22=}}

// https://github.com/apple/swift/issues/53979

func fixitTry0<T>(a: T) try where T:ExpressibleByStringLiteral {} // expected_error{{expected throwing specifier; did you mean 'throws'?}} {{25-28=throws}}
func fixitTry1<T>(a: T) try {} // expected_error{{expected throwing specifier; did you mean 'throws'?}} {{25-28=throws}}
func fixitTry2() try {} // expected_error{{expected throwing specifier; did you mean 'throws'?}} {{18-21=throws}}
let fixitTry3 : () try -> Int // expected_error{{expected throwing specifier; did you mean 'throws'?}} {{20-23=throws}}

func fixitAwait0() await { } // expected_error{{expected async specifier; did you mean 'async'?}}{{20-25=async}}
func fixitAwait1() await -> Int { } // expected_error{{expected async specifier; did you mean 'async'?}}{{20-25=async}}
func fixitAwait2() throws await -> Int { } // expected_error{{expected async specifier; did you mean 'async'?}}{{27-32=async}}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/errors.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@15:17 {{}} // expected_expr_after_ternary_colon
// expected-error@68:39 {{}} // extra_var_in_multiple_pattern_list
// expected-error@106:56 {{}} // expected_lbrace_after_catch
// expected-error@110:26 {{}} // async_or_throws_in_wrong_position
// expected-error@114:23 {{}} // async_or_throws_in_wrong_position
// expected-error@118:49 {{}} // async_or_throws_in_wrong_position
// expected-error@122:46 {{}} // async_or_throws_in_wrong_position
// expected-error@127:19 {{}} // async_or_throws_in_wrong_position
// expected-error@130:26 {{}} // duplicate_effects_specifier
// expected-error@130:38 {{}} // duplicate_effects_specifier
// expected-error@130:49 {{}} // duplicate_effects_specifier
// expected-error@135:35 {{}} // duplicate_effects_specifier
// expected-error@139:12 {{}} // throw_in_function_type
// expected-error@139:16 {{}} // duplicate_effects_specifier
// expected-error@143:26 {{}} // duplicate_effects_specifier
// expected-error@149:12 {{}} // statement_same_line_without_semi
// expected-error@149:13 {{}} // expected_expr
// expected-error@155:20 {{}} // throw_in_function_type
// expected-error@156:20 {{}} // throw_in_function_type
// expected-error@160:16 {{}} // throw_in_function_type
// expected-error@163:15 {{}} // async_or_throws_in_wrong_position
// expected-error@167:25 {{}} // throw_in_function_type
// expected-error@168:25 {{}} // throw_in_function_type
// expected-error@169:18 {{}} // throw_in_function_type
// expected-error@170:20 {{}} // throw_in_function_type
// expected-error@172:20 {{}} // await_in_function_type
// expected-error@173:20 {{}} // await_in_function_type
// expected-error@174:27 {{}} // await_in_function_type
// ---- end ASTGen parity ----
