// RUN; %target-typecheck-verify-swift -target %target-swift-5.1-abi-triple

struct MyProps {
  var prop1 : Int {
    get async { }
  }

  var prop2 : Int {
    get throws { }
  }

  var prop3 : Int {
    get async throws { }
  }

  var prop1mut : Int {
    mutating get async { }
  }

  var prop2mut : Int {
    mutating get throws { }
  }

  var prop3mut : Int {
    mutating get async throws { }
  }
}

struct X1 {
  subscript(_ i : Int) -> Int {
      get async {}
    }
}

class X2 {
  subscript(_ i : Int) -> Int {
      get throws {}
    }
}

struct X3 {
  subscript(_ i : Int) -> Int {
      get async throws {}
    }
}

struct BadSubscript1 {
  subscript(_ i : Int) -> Int {
      get async throws {}
      set {} // expected_error {{'set' accessor is not allowed on property with 'get' accessor that is 'async' or 'throws'}}
    }
}

struct BadSubscript2 {
  subscript(_ i : Int) -> Int {
      get throws {}

      // expected_error@+2 {{'set' accessor is not allowed on property with 'get' accessor that is 'async' or 'throws'}}
      // expected_error@+1 {{'set' accessor cannot have specifier 'throws'}}
      set throws {}
    }
}

struct S {
  var prop2 : Int {
    mutating get async throws { 0 }
    nonmutating set {} // expected_error {{'set' accessor is not allowed on property with 'get' accessor that is 'async' or 'throws'}}
  }
}

var prop3 : Bool {
  // expected_error@+2 {{'_read' accessor is not allowed on property with 'get' accessor that is 'async' or 'throws'}}
  // expected_error@+1 {{variable cannot provide both a '_read' accessor and a getter}}
  _read { yield prop3 }

  // expected_note@+2 {{getter defined here}}
  // expected_note@+1 2 {{previous definition of getter here}}
  get throws { false }
  get async { true } // expected_error{{variable already has a getter}}

  get {} // expected_error{{variable already has a getter}}
}

enum E {
  private(set) var prop4 : Double {
    set {} // expected_error {{'set' accessor is not allowed on property with 'get' accessor that is 'async' or 'throws'}}
    get async throws { 1.1 }
    _modify { yield &prop4 } // expected_error {{'_modify' accessor is not allowed on property with 'get' accessor that is 'async' or 'throws'}}
  }
}

protocol P {
  associatedtype T
  var prop1 : T { get async throws }
  var prop2 : T { get async throws set } // expected_error {{'set' accessor is not allowed on property with 'get' accessor that is 'async' or 'throws'}}
  var prop3 : T { get throws set } // expected_error {{'set' accessor is not allowed on property with 'get' accessor that is 'async' or 'throws'}}
  var prop4 : T { get async }
  var prop5 : T { mutating get async throws }
  var prop6 : T { mutating get throws }
  var prop7 : T { mutating get async nonmutating set } // expected_error {{'set' accessor is not allowed on property with 'get' accessor that is 'async' or 'throws'}}
}

///////////////////
// invalid syntax

var bad1 : Int {
  get rethrows { 0 }  // expected_error{{only function declarations may be marked 'rethrows'; did you mean 'throws'?}}

  // expected_error@+1 {{'set' accessor is not allowed on property with 'get' accessor that is 'async' or 'throws'}}
  set rethrows { }   // expected_error{{'set' accessor cannot have specifier 'rethrows'}}
}

var bad2 : Int {
  get reasync { 0 }  // expected_error{{expected '{' to start getter definition}}

  set reasync { }
}

var bad3 : Int {
  _read async { yield 0 } // expected_error{{'_read' accessor cannot have specifier 'async'}}
  set(theValue) async { } // expected_error{{'set' accessor cannot have specifier 'async'}}
}


var bad4 : Int = 0 {
  // expected_error@+4 {{'willSet' accessor cannot have specifier 'throws'}}
  // expected_error@+3 {{'willSet' accessor cannot have specifier 'async'}}
  // expected_error@+2 {{'willSet' accessor cannot have specifier 'rethrows'}}
  // expected_error@+1 {{'willSet' accessor cannot have specifier 'reasync'}}
  willSet(theValue) reasync rethrows async throws {}

  // expected_error@+2 {{expected '{' to start 'didSet' definition}}
  // expected_error@+1 {{'didSet' accessor cannot have specifier 'throws'}}
  didSet throws bogus {}
}

var bad5 : Int {
  get bogus rethrows {} // expected_error{{expected '{' to start getter definition}}
}

var bad6 : Int {
  // expected_error@+2{{expected '{' to start getter definition}}
  // expected_error@+1 {{only function declarations may be marked 'rethrows'; did you mean 'throws'?}}
  get rethrows -> Int { 0 }
}

var bad7 : Double {
  get throws async { 3.14 } // expected_error {{'async' must precede 'throws'}}
}

var bad8 : Double {
  get {}
  // expected_error@+2 {{'_modify' accessor cannot have specifier 'async'}}
  // expected_error@+1 {{'_modify' accessor cannot have specifier 'throws'}}
  _modify throws async { yield &bad8 }
}

protocol BadP {
  var prop2 : Int { get bogus rethrows set } // expected_error{{expected 'get', 'yielding borrow', 'borrow', 'set', 'mutate' or 'yielding mutate' in a protocol property}}

  // expected_error@+2 {{only function declarations may be marked 'rethrows'; did you mean 'throws'?}}
  // expected_error@+1 {{expected 'get', 'yielding borrow', 'borrow', 'set', 'mutate' or 'yielding mutate' in a protocol property}}
  var prop3 : Int { get rethrows bogus set }

  // expected_error@+1 {{expected 'get', 'yielding borrow', 'borrow', 'set', 'mutate' or 'yielding mutate' in a protocol property}}
  var prop4 : Int { get reasync bogus set }

  var prop5 : Int { get throws async } // expected_error {{'async' must precede 'throws'}}
}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/effectful_properties.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module -target %target-swift-5.1-abi-triple %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@50:7 {{}} // invalid_accessor_with_effectful_get
// expected-error@60:7 {{}} // invalid_accessor_with_effectful_get
// expected-error@60:11 {{}} // invalid_accessor_specifier
// expected-error@67:17 {{}} // invalid_accessor_with_effectful_get
// expected-error@74:3 2 {{}} // conflicting_accessor,invalid_accessor_with_effectful_get
// expected-note@78:3 3 {{}} // previous_accessor
// expected-error@79:3 {{}} // duplicate_accessor
// expected-error@81:3 {{}} // duplicate_accessor
// expected-error@86:5 {{}} // invalid_accessor_with_effectful_get
// expected-error@88:5 {{}} // invalid_accessor_with_effectful_get
// expected-error@95:36 {{}} // invalid_accessor_with_effectful_get
// expected-error@96:30 {{}} // invalid_accessor_with_effectful_get
// expected-error@100:50 {{}} // invalid_accessor_with_effectful_get
// expected-error@107:7 {{}} // rethrowing_function_type
// expected-error@110:3 {{}} // invalid_accessor_with_effectful_get
// expected-error@110:7 {{}} // invalid_accessor_specifier
// expected-error@114:7 {{}} // expected_lbrace_accessor
// expected-error@120:9 {{}} // invalid_accessor_specifier
// expected-error@121:17 {{}} // invalid_accessor_specifier
// expected-error@130:21 {{}} // invalid_accessor_specifier
// expected-error@130:29 {{}} // invalid_accessor_specifier
// expected-error@130:38 {{}} // invalid_accessor_specifier
// expected-error@130:44 {{}} // invalid_accessor_specifier
// expected-error@134:10 {{}} // invalid_accessor_specifier
// expected-error@134:17 {{}} // expected_lbrace_accessor
// expected-error@138:7 {{}} // expected_lbrace_accessor
// expected-error@144:7 {{}} // rethrowing_function_type
// expected-error@144:16 {{}} // expected_lbrace_accessor
// expected-error@148:14 {{}} // async_after_throws
// expected-error@155:11 {{}} // invalid_accessor_specifier
// expected-error@155:18 {{}} // invalid_accessor_specifier
// expected-error@159:25 {{}} // expected_getreadborrowsetmutate_in_protocol
// expected-error@163:25 {{}} // rethrowing_function_type
// expected-error@163:34 {{}} // expected_getreadborrowsetmutate_in_protocol
// expected-error@166:25 {{}} // expected_getreadborrowsetmutate_in_protocol
// expected-error@168:32 {{}} // async_after_throws
// ---- end ASTGen parity ----
