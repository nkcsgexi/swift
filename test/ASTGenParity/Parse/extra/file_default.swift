// RUN; %target-typecheck-verify-swift -enable-experimental-feature DefaultIsolationPerFile

// REQUIRES; swift_feature_DefaultIsolationPerFile

// REQUIRES; concurrency

default @MainActor
// expected_note@-1:1 {{file-level default isolation previously declared here}}

nonisolated func foo() {}
foo(); default nonisolated; foo()
// expected_error@-1:8 {{invalid redeclaration of file-level default isolation}}

default @diagnose(StrictMemorySafety, as: error)

default @diagnose(StrictMemorySafety, as: warning); default @diagnose(StrictMemorySafety, as: error)

default @diagnose(StrictMemorySafety, as: error) func frog() {}
// expected_error@-1:49 {{consecutive statements on a line must be separated by ';'}}{{49-49=;}}

default func bizarre() {}
// expected_error@-1:9 {{expected '@MainActor', 'nonisolated', '@available', or '@diagnose' after 'default'}}

default foo
// expected_error@-1:9 {{expected '@MainActor', 'nonisolated', '@available', or '@diagnose' after 'default'}}

default `nonisolated`
// expected_error@-1:9 {{expected '@MainActor', 'nonisolated', '@available', or '@diagnose' after 'default'}}

default =
// expected_error@-1:9 {{expected '@MainActor', 'nonisolated', '@available', or '@diagnose' after 'default'}}

default @foo
// expected_error@-1:10 {{cannot find type 'foo' in scope}}
// expected_note@-2:9 {{a file-level default must be '@MainActor', 'nonisolated', '@available', or '@diagnose'}}

// Looking on the next line would risk cascading errors.
default
// expected_error@-1:8 {{expected '@MainActor', 'nonisolated', '@available', or '@diagnose' after 'default'}}
nonisolated func bar() {}

default
// expected_error@-1:8 {{expected '@MainActor', 'nonisolated', '@available', or '@diagnose' after 'default'}}
@available(*, deprecated, message: "no more baz!")
func baz() {}

default
// expected_error@-1:8 {{expected '@MainActor', 'nonisolated', '@available', or '@diagnose' after 'default'}}

// TODO: in the future, consider a more nuanced recovery for ':' in file level default?

default: @MainActor
// expected_error@-1:1 {{'default' label can only appear inside a 'switch' statement}} {{none}}

// An example of why we probably can't just look for '@':
func braceMismatch() {
  switch Bool.random() {
  case true: break
  case false: break
  }} // Accidentally close the switch early...
  default: @MainActor struct Bar {}
  // expected_error@-1:3 {{'default' label can only appear inside a 'switch' statement}} {{none}}

private default @diagnose(StrictMemorySafety, as: error)
// expected_error@-1:1 {{attribute cannot be attached to a file-level default}}

default @inlinable
// expected_error@-1:9 {{'@inlinable' is not a valid file-level default}}
// expected_note@-2:9 {{a file-level default must be '@MainActor', 'nonisolated', '@available', or '@diagnose'}}

default @backDeployed(before: macOS 13.0)
// expected_error@-1:10 {{'@backDeployed' is not a valid file-level default}}
// expected_note@-2:10 {{a file-level default must be '@MainActor', 'nonisolated', '@available', or '@diagnose'}}

default @backDeployed(before: macOS 13.0, iOS 16.0)
// expected_error@-1:10 {{'@backDeployed' is not a valid file-level default}}
// expected_note@-2:10 {{a file-level default must be '@MainActor', 'nonisolated', '@available', or '@diagnose'}}

default @_originallyDefinedIn(module: "Other", macOS 13.0)
// expected_error@-1:10 {{'@_originallyDefinedIn' is not a valid file-level default}}
// expected_note@-2:10 {{a file-level default must be '@MainActor', 'nonisolated', '@available', or '@diagnose'}}

default @_originallyDefinedIn(module: "Other", macOS 13.0, iOS 16.0)
// expected_error@-1:10 {{'@_originallyDefinedIn' is not a valid file-level default}}
// expected_note@-2:10 {{a file-level default must be '@MainActor', 'nonisolated', '@available', or '@diagnose'}}

@globalActor
actor MyActor { // expected_note@:7 {{'MyActor' declared here}}
  static let shared = MyActor()
  default @MyActor
  // expected_error@-1:3 {{declaration is only valid at file scope}}
  // TODO: we don't diagnose nested 'default' misuse since the request doesn't see it.
  // Fixing that would also fix diagnosing in files with only 'default'...
}

default @MyActor
// expected_error@-1:9 {{global actor 'MyActor' is not a valid file-level default}}
// expected_note@-2:9 {{file-level default isolation must be '@MainActor' or 'nonisolated'}}

do {
  default @MainActor // expected_error@:3 {{declaration is only valid at file scope}}
  default: @MainActor // expected_error@:3 {{'default' label can only appear inside a 'switch' statement}}
} // expected_error@:1 {{expected declaration}}

func test() {
  default @MainActor // expected_error@:3 {{declaration is only valid at file scope}}
  default: @MainActor // expected_error@:3 {{'default' label can only appear inside a 'switch' statement}}
} // expected_error@:1 {{expected declaration}}

struct S {
  var x: Int {
    default @MainActor // expected_error@:5 {{declaration is only valid at file scope}}
    default: nonisolated // expected_error@:5 {{'default' label can only appear inside a 'switch' statement}}
  }

  default @MainActor func lion() {}
  // expected_error@-1:3 {{declaration is only valid at file scope}}
  // expected_error@-2:21 {{consecutive declarations on a line must be separated by ';'}}{{21-21=;}}

  default nonisolated subscript(a: Int) -> Bool { false }
  // expected_error@-1:3 {{declaration is only valid at file scope}}
  // expected_error@-2:22 {{consecutive declarations on a line must be separated by ';'}}{{22-22=;}}

  default: func lamb() {}
  // expected_error@-1:10 {{expected '@MainActor', 'nonisolated', '@available', or '@diagnose' after 'default'}}
  // expected_error@-2:11 {{consecutive declarations on a line must be separated by ';'}}{{11-11=;}}

  default: nonisolated func lobster() {}
  // expected_error@-1:10 {{expected '@MainActor', 'nonisolated', '@available', or '@diagnose' after 'default'}}
  // expected_error@-2:11 {{consecutive declarations on a line must be separated by ';'}}{{11-11=;}}
}

do {
  @objc default @MainActor
  // expected_error@-1:9 {{declaration is only valid at file scope}}
  // expected_error@-2:4 {{attribute cannot be attached to a file-level default}}
}

switch 3 {
case 3: print("3")
default nonisolated
// expected_error@-1:9 {{expected ':' after 'default'}}
// expected_error@-2:9 {{cannot find 'nonisolated' in scope}}
}

switch 4 {
case 4: print("4")
default: nonisolated
// expected_error@-1:10 {{cannot find 'nonisolated' in scope}}
}

// TODO: maybe these could be better...

switch 5 {
case 5: print("5");
default @MainActor
// expected_error@-1:9 {{expected ':' after 'default'}}
} // expected_error {{expected declaration}}

switch 6 {
case 6: print("6");
default: @MainActor
} // expected_error {{expected declaration}}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/file_default.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module -enable-experimental-feature DefaultIsolationPerFile %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_DefaultIsolationPerFile
// REQUIRES: swift_feature_ParserASTGen
// REQUIRES: concurrency
// XFAIL: *
// expected-error@18:49 {{}} // statement_same_line_without_semi
// expected-error@21:9 {{}} // file_default_invalid_specifier
// expected-error@24:9 {{}} // file_default_invalid_specifier
// expected-error@27:9 {{}} // file_default_invalid_specifier
// expected-error@30:9 {{}} // file_default_invalid_specifier
// expected-error@38:8 {{}} // file_default_invalid_specifier
// expected-error@42:8 {{}} // file_default_invalid_specifier
// expected-error@47:8 {{}} // file_default_invalid_specifier
// expected-error@52:1 {{}} // case_outside_of_switch
// expected-error@61:3 {{}} // case_outside_of_switch
// expected-error@64:1 {{}} // file_default_rejects_attributes
// expected-error@102:3 {{}} // case_outside_of_switch
// expected-error@103:1 {{}} // expected_decl
// expected-error@107:3 {{}} // case_outside_of_switch
// expected-error@108:1 {{}} // expected_decl
// expected-error@113:5 {{}} // case_outside_of_switch
// expected-error@116:21 {{}} // declaration_same_line_without_semi
// expected-error@120:22 {{}} // declaration_same_line_without_semi
// expected-error@124:10 {{}} // file_default_invalid_specifier
// expected-error@124:11 {{}} // declaration_same_line_without_semi
// expected-error@128:10 {{}} // file_default_invalid_specifier
// expected-error@128:11 {{}} // declaration_same_line_without_semi
// expected-error@134:4 {{}} // file_default_rejects_attributes
// expected-error@141:9 {{}} // expected_case_colon
// expected-error@156:9 {{}} // expected_case_colon
// expected-error@158:1 {{}} // expected_decl
// expected-error@163:1 {{}} // expected_decl
// ---- end ASTGen parity ----
