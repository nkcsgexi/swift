// Test that a derivative function configuration record with an out of range
// length is ignored instead of reading past the end of the record.
//
// RUN: %empty-directory(%t)
// RUN: split-file %s %t
// RUN: %target-swift-frontend -emit-module -parse-as-library %t/a.swift -module-name a -emit-module-path %t/a.swiftmodule
// RUN: %{python} %S/Inputs/corrupt_derivative_config_length.py %t/a.swiftmodule 1a9malformedyS2fF
// RUN: %target-swift-frontend -emit-sil -verify -I %t %t/main.swift -o /dev/null

//--- a.swift
import _Differentiation

public func malformed(_ x: Float) -> Float { x }

@derivative(of: malformed)
public func vjpMalformed(_ x: Float) -> (value: Float, pullback: (Float) -> Float) {
  (x, { $0 })
}

public func intact(_ x: Float) -> Float { x }

@derivative(of: intact)
public func vjpIntact(_ x: Float) -> (value: Float, pullback: (Float) -> Float) {
  (x, { $0 })
}

//--- main.swift
import _Differentiation
import a

func testIntact() {
  _ = gradient(at: 1, of: intact)
}

func testMalformed() {
  // expected-error @+2 {{function is not differentiable}}
  // expected-note @+1 {{cannot differentiate functions that have not been marked '@differentiable' and that are defined in other files}}
  _ = gradient(at: 1, of: malformed)
}
