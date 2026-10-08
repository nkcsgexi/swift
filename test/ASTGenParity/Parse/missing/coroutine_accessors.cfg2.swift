// RUN; %target-typecheck-verify-swift -verify-ignore-unrelated \
// RUN;     -verify-additional-prefix enabled- \
// RUN;     -enable-experimental-feature CoroutineAccessors \
// RUN;     -debug-diagnostic-names
// RUN; %target-typecheck-verify-swift -verify-ignore-unrelated \
// RUN;     -verify-additional-prefix disabled- \
// RUN;     -debug-diagnostic-names

// REQUIRES; swift_feature_CoroutineAccessors

var _i: Int = 0

// Order of accessor kinds:
// readers:
// - get
// - unsafeAddress
// - _read
// - read
// - yielding borrow
// writers:
// - set
// - unsafeMutableAddress
// - _modify
// - modify
// - yielding mutate

// =============================================================================
// Multiple reads
// =============================================================================

// If feature is disabled, this looks like an implicit
// getter that starts with an expression referring to
// symbols `yielding` and `borrow`
var iyb: Int {
  yielding borrow { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
}

var ir: Int {
  read { // expected_enabled-warning{{old_coroutine_accessor}}
    // expected_disabled-error@-1{{cannot_find_in_scope}}
    fatalError()
  }
}

// enabled: conflicting accessors
// disabled: implicit getter
var iybr: Int {
  yielding borrow { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  read { // expected_enabled-warning{{old_coroutine_accessor}}
         // expected_enabled-error@-1{{duplicate_accessor}}
         // expected_enabled-note@-5{{previous_accessor}}
         // expected_disabled-error@-3{{expected_accessor_kw}}
    fatalError()
  }
}

// enabled: conflicting accessors
// disabled: implicit getter
var iryb: Int {
  read {  // expected_enabled-warning{{old_coroutine_accessor}}
    // expected_disabled-error@-1{{cannot_find_in_scope}}
    fatalError()
  }
  yielding borrow { // expected_enabled-error{{duplicate_accessor}}
      // expected_enabled-note@-5{{previous_accessor}}
      // expected_disabled-error@-2{{cannot_find_in_scope}}
      // expected_disabled-error@-3{{cannot_find_in_scope}}
      // expected_disabled-error@-4{{statement_same_line_without_semi}}
    fatalError()
  }
}

// enabled: conflicting accessors
// disabled: implicit getter.
var ir_r: Int {
  read {  // expected_enabled-warning{{old_coroutine_accessor}}
          // expected_enabled-error@-1{{variable cannot provide both a 'yielding borrow' accessor and a '_read' accessor}}
          // expected_disabled-error@-2{{cannot_find_in_scope}}
    fatalError()
  }
  _read { // expected_disabled-error{{cannot_find_in_scope}}
         // expected_enabled-note@-1{{previous_accessor}}
    fatalError()
  }
}

// enabled: conflicting accessors
var igr: Int {
  get {
    1
  }
  read { // expected_enabled-warning{{old_coroutine_accessor}}
         // expected_enabled-error@-1{{variable cannot provide both a 'yielding borrow' accessor and a getter}}
         // expected_enabled-note@-5{{previous_accessor}}
         // expected_disabled-error@-3{{expected_accessor_kw}}
    yield _i
  }
}

// =============================================================================
// One read, one write.
// =============================================================================

// enabled: ok
// disabled: bad keyword
var igm: Int {
  get {
    0
  }
  yielding mutate { // expected_disabled-error{{'yielding mutate' accessor is only valid when experimental feature coroutine accessors is enabled}}
    yield &_i
  }
}

// enabled: ok
// disabled: implicit getter
var img: Int {
  yielding mutate { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  get {
    0
  }
}

// enabled: ok
// disabled: bad keyword
var iuam: Int {
  unsafeAddress {
    UnsafePointer<Int>(bitPattern: 0x0)!
  }
  yielding mutate { // expected_disabled-error{{'yielding mutate' accessor is only valid when experimental feature coroutine accessors is enabled}}
    yield &_i
  }
}

// enabled: ok
// disabled: bad keyword
var imua: Int {
  yielding mutate { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  unsafeAddress {
    UnsafePointer<Int>(bitPattern: 0x0)!
  }
}

// enabled: ok
// disabled: bad keyword
var i_rm: Int {
  _read {
    yield _i
  }
  yielding mutate { // expected_disabled-error{{'yielding mutate' accessor is only valid when experimental feature coroutine accessors is enabled}}
    yield &_i
  }
}

// enabled: ok
// disabled: implicit getter.
var im_r: Int {
  yielding mutate { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  _read {
    fatalError()
  }
}

// enabled: ok
// disabled: implicit getter
var irm: Int {
  yielding borrow { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  yielding mutate { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
}

// enabled: ok
// disabled: implicit getter.
var imr: Int {
  yielding mutate { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  yielding borrow { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
}

// enabled: ok
// disabled: implicit getter
var irs: Int {
  yielding borrow { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  set {
  }
}

// enabled: ok
// disabled: bad keyword
var isr: Int {
  set {
  }
  yielding borrow { // expected_disabled-error{{'yielding borrow' accessor is only valid when experimental feature coroutine accessors is enabled}}
    fatalError()
  }
}

// enabled: ok
// disabled: implicit getter.
var iruma: Int {
  yielding borrow { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  unsafeMutableAddress {
    UnsafeMutablePointer<Int>(bitPattern: 0x0)!
  }
}

// enabled: ok
// disabled: implicit getter.
var iumar: Int {
  yielding borrow { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  unsafeMutableAddress {
    UnsafeMutablePointer<Int>(bitPattern: 0x0)!
  }
}

// enabled: ok
// disabled: implicit getter
var ir_m: Int {
  yielding borrow { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  _modify {
    fatalError()
  }
}

// enabled: ok
// disabled: bad keyword
var i_mr: Int {
  _modify {
    fatalError()
  }
  yielding borrow { // expected_disabled-error{{'yielding borrow' accessor is only valid when experimental feature coroutine accessors is enabled}}
    fatalError()
  }
}

// =============================================================================
// Multiple mutating only.
// =============================================================================

// enabled: need a reader.
// disabled: implicit getter.
var ims: Int {
  yielding mutate { // expected_disabled-error{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  set { // expected_error{{variable with a setter must also have a getter, addressor, or 'yielding borrow' accessor}}
  }
}

// enabled: need a reader
// disabled: bad keyword
var ism: Int {
  set { // expected_error{{variable with a setter must also have a getter, addressor, or 'yielding borrow' accessor}}
    fatalError()
  }
  yielding mutate {// expected_disabled-error{{'yielding mutate' accessor is only valid when experimental feature coroutine accessors is enabled}}
    fatalError()
  }
}

// enabled: need a reader.
// disabled: implicit getter.
var imuma: Int {
  yielding mutate { // expected_error{{variable with a 'yielding mutate' accessor must also have a getter, addressor, or 'yielding borrow' accessor}}
                   // expected_disabled-error@-1{{accessor_requires_coroutine_accessors}}

    fatalError()
  }
  unsafeMutableAddress {
    UnsafeMutablePointer<Int>(bitPattern: 0x0)!
  }
}

// enabled: need a reader
// disabled: bad keyword
var iumam: Int {
  unsafeMutableAddress {
    fatalError()
  }
  yielding mutate { // expected_error{{variable with a 'yielding mutate' accessor must also have a getter, addressor, or 'yielding borrow' accessor}}
           // expected_disabled-error@-1{{'yielding mutate' accessor is only valid when experimental feature coroutine accessors is enabled}}
    fatalError()
  }
}

// enabled: conflicting accessors.  need a reader.
// disabled: implicit getter.
var im_m: Int {
  yielding mutate { // expected_error{{variable cannot provide both a 'yielding mutate' accessor and a '_modify' accessor}}
                    // expected_note@+4{{'_modify' accessor defined here}}
                    // expected_disabled-error@-2{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  _modify { // expected_error{{variable with a '_modify' accessor must also have a getter, addressor, or 'yielding borrow' accessor}}
    fatalError()
  }
}

// enabled: need a reader.
// disabled: implicit getter.
var i_mm: Int {
  _modify { // expected_error{{variable with a '_modify' accessor must also have a getter, addressor, or 'yielding borrow' accessor}}
    fatalError()
  }
  yielding mutate { // expected_disabled-error{{'yielding mutate' accessor is only valid when experimental feature coroutine accessors is enabled}}
            // expected_error@-1{{variable cannot provide both a 'yielding mutate' accessor and a '_modify' accessor}}
            // expected_note@-5{{previous_accessor}}
    fatalError()
  }
}

// enabled: need a reader.
// disabled: implicit getter.
var imm: Int {
  yielding mutate { // expected_error{{variable with a 'yielding mutate' accessor must also have a getter, addressor, or 'yielding borrow' accessor}}
                    // expected_disabled-error@-1{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  yielding mutate { // expected_error{{variable already has a 'yielding mutate' accessor}}
                    // expected_note@-5{{previous_accessor}}
                    // expected_disabled-error@-2{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
}

// =============================================================================
// Multiple
// =============================================================================

// enabled: ok
// disabled: bad keyword
var i_rm_m: Int {
  _read {
    yield _i
  }
  yielding mutate { // expected_disabled-error{{'yielding mutate' accessor is only valid when experimental feature coroutine accessors is enabled}}
           // expected_error@-1{{variable cannot provide both a 'yielding mutate' accessor and a '_modify' accessor}}
    yield &_i
  }
  _modify { // expected_note{{previous_accessor}}
    yield &_i
  }
}

// enabled: ok
// disabled: implicit getter
var ir_rm_m: Int {
  yielding borrow { // expected_error{{variable cannot provide both a 'yielding borrow' accessor and a '_read' accessor}}
        // expected_disabled-error@-1{{accessor_requires_coroutine_accessors}}

    fatalError()
  }
  _read { // expected_note{{previous_accessor}}
    fatalError()
  }
  yielding mutate { // expected_error{{variable cannot provide both a 'yielding mutate' accessor and a '_modify' accessor}}
         // expected_disabled-error@-1{{accessor_requires_coroutine_accessors}}
    fatalError()
  }
  _modify { // expected_note{{previous_accessor}}
    fatalError()
  }
}

// =============================================================================
// Protocol Requirements
// =============================================================================

protocol P {
  var goodP: Int { yielding borrow set } //expected_disabled-error{{accessor_requires_coroutine_accessors}}

  // enabled: ok
  // disabled: implicit getter.
  var alsoGoodP: Int { yielding borrow yielding mutate } //expected_disabled-error{{accessor_requires_coroutine_accessors}}
                                                    //expected_disabled-error@-1{{accessor_requires_coroutine_accessors}}

  subscript(goodS goodS: Int) -> Int { yielding borrow set } //expected_disabled-error{{accessor_requires_coroutine_accessors}}

  subscript(alsoGoodS alsoGoodS: Int) -> Int { yielding borrow yielding mutate }  //expected_disabled-error{{accessor_requires_coroutine_accessors}}
                                                    //expected_disabled-error@-1{{accessor_requires_coroutine_accessors}}

}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/coroutine_accessors.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@35:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@50:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@53:3 {{}} // expected_accessor_kw
// expected-error@68:11 {{}} // statement_same_line_without_semi
// expected-error@96:3 {{}} // expected_accessor_kw
// expected-error@114:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@122:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@136:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@144:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@158:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@166:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@177:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@180:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@188:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@191:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@199:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@211:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@219:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@230:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@241:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@255:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@267:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@270:3 {{}} // missing_reading_accessor
// expected-error@277:3 {{}} // missing_reading_accessor
// expected-error@280:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@288:12 {{}} // missing_reading_accessor
// expected-error@288:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@304:12 {{}} // missing_reading_accessor
// expected-error@304:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@313:12 {{}} // conflicting_accessor
// expected-error@313:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@318:3 {{}} // missing_reading_accessor
// expected-note@318:3 {{}} // previous_accessor
// expected-error@326:3 {{}} // missing_reading_accessor
// expected-note@326:3 {{}} // previous_accessor
// expected-error@329:12 {{}} // conflicting_accessor
// expected-error@329:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@339:12 {{}} // missing_reading_accessor
// expected-note@339:12 {{}} // previous_accessor
// expected-error@339:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@343:12 {{}} // duplicate_accessor
// expected-error@343:19 {{}} // accessor_requires_coroutine_accessors
// expected-error@360:12 {{}} // conflicting_accessor
// expected-error@360:19 {{}} // accessor_requires_coroutine_accessors
// expected-note@364:3 {{}} // previous_accessor
// expected-error@372:12 {{}} // conflicting_accessor
// expected-error@372:19 {{}} // accessor_requires_coroutine_accessors
// expected-note@377:3 {{}} // previous_accessor
// expected-error@380:12 {{}} // conflicting_accessor
// expected-error@380:19 {{}} // accessor_requires_coroutine_accessors
// expected-note@384:3 {{}} // previous_accessor
// expected-error@394:36 {{}} // accessor_requires_coroutine_accessors
// expected-error@398:40 {{}} // accessor_requires_coroutine_accessors
// expected-error@398:56 {{}} // accessor_requires_coroutine_accessors
// expected-error@401:56 {{}} // accessor_requires_coroutine_accessors
// expected-error@403:64 {{}} // accessor_requires_coroutine_accessors
// expected-error@403:80 {{}} // accessor_requires_coroutine_accessors
// ---- end ASTGen parity ----
