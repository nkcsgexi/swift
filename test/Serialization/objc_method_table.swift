// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -emit-module -disable-objc-attr-requires-foundation-module -o %t %S/Inputs/objc_method_decls.swift
// RUN: %llvm-bcanalyzer %t/objc_method_decls.swiftmodule | %FileCheck %s
// RUN: %target-swift-frontend -typecheck -disable-objc-attr-requires-foundation-module -I %t %s -verify -verify-ignore-unrelated

// A method table record with an out of range owner name length is ignored
// instead of reading past the end of the record.
// RUN: %empty-directory(%t/malformed)
// RUN: cp %t/objc_method_decls.swiftmodule %t/malformed/
// RUN: %{python} %S/Inputs/corrupt_objc_method_owner_length.py %t/malformed/objc_method_decls.swiftmodule initWithInt:
// RUN: not %target-swift-frontend -typecheck -disable-objc-attr-requires-foundation-module -I %t/malformed %s 2>&1 | %FileCheck --check-prefix=MALFORMED --implicit-check-not="error: initializer 'init(int:)'" %s
// MALFORMED: error: method 'a1()' with Objective-C selector 'a1' conflicts with method 'f1()'
// MALFORMED: error: setter for 'foo' with Objective-C selector 'setFoo:' conflicts with method 'f3'
// MALFORMED: error: subscript getter with Objective-C selector 'objectAtIndexedSubscript:' conflicts with method 'f4'

// REQUIRES: objc_interop

import objc_method_decls

class B : A {
  @objc func a1() { } // expected-error{{method 'a1()' with Objective-C selector 'a1' conflicts with method 'f1()' from superclass 'A' with the same Objective-C selector}}

  @objc init(int: Int) { // expected-error{{initializer 'init(int:)' with Objective-C selector 'initWithInt:' conflicts with method 'f2' from superclass 'A' with the same Objective-C selector}}
    self.foo = int 
    super.init()
  }

  @objc var foo: Int // expected-error{{setter for 'foo' with Objective-C selector 'setFoo:' conflicts with method 'f3' from superclass 'A' with the same Objective-C selector}}

  @objc subscript (i: Int) -> AnyObject {
    get { return self } // expected-error{{subscript getter with Objective-C selector 'objectAtIndexedSubscript:' conflicts with method 'f4' from superclass 'A' with the same Objective-C selector}}
    set { }
  }
}

// Make sure the OBJC_METHODS table is present.
// CHECK: OBJC_METHODS
