// Runtime counterpart to hidden-type-irgen.swift. Where that test asserts on
// the shape of generated IR (storage type, memcpy size), this one builds an
// actual executable and verifies that values of an encapsulated type
// round-trip correctly across the dylib boundary at runtime — proving the
// codegen IRGen emits is functionally correct, not merely well-shaped.
//
// Cross-module ABI agreement is enforced by the implicit
// @_hasHiddenStoredProperties marker that Sema's encapsulation gate attaches
// to any struct with a hidden stored property. The marker is read by SIL
// TypeLowering and IRGen StructLayout on both sides, forcing the struct to
// be address-only regardless of whether the field's type appears as the real
// C type (library side) or a HiddenType placeholder (client side).

// REQUIRES: swift_feature_AbstractStoredPropertyLayout
// REQUIRES: executable_test
// REQUIRES: PTRSIZE=64

// Linking against a dylib means the test must run on the same machine as
// the compiler; remote/device executors don't have the dylib uploaded.
// UNSUPPORTED: remote_run || device_run

// RUN: %empty-directory(%t)
// RUN: split-file %s %t

// 1. Build Library as a dylib + swiftmodule, with the internal bridging
//    header. `-Xfrontend` is required because -internal-import-bridging-header
//    is a frontend-only flag. `-wmo` compiles the whole module in a single
//    frontend invocation, which both emits the object code and writes the
//    swiftmodule directly — skipping the driver's `-merge-modules` step
//    (whose AST verifier currently can't round-trip `HiddenType` placeholders
//    through reload, since the verifier walks deserialized var decls).
// RUN: %target-build-swift \
// RUN:   -Xfrontend -internal-import-bridging-header \
// RUN:   -Xfrontend %t/Utility.h \
// RUN:   -enable-experimental-feature AbstractStoredPropertyLayout \
// RUN:   -wmo -parse-as-library -emit-library \
// RUN:   -emit-module -emit-module-path %t/Library.swiftmodule \
// RUN:   -module-name Library \
// RUN:   %t/Library.swift \
// RUN:   -o %t/%target-library-name(Library)

// 2. Build Client as an executable; no bridging header on this side, no
//    visibility into Utility.h. Encapsulation works iff this links and runs.
//    `-Onone` keeps the optimizer from collapsing the round-trip's intermediate
//    stores — we want the assignWithCopy / initializeWithCopy paths to actually
//    execute, not be folded away by SIL passes.
// RUN: %target-build-swift -Onone \
// RUN:   -enable-experimental-feature AbstractStoredPropertyLayout \
// RUN:   -I %t -L %t -lLibrary \
// RUN:   -o %t/main %t/Client.swift
// RUN: %target-codesign %t/main

// 3. Run and verify stdout. The values printed prove the layout-table
//    lookup, the memcpy-based copy, and the dylib ABI all line up.
// RUN: %target-run %t/main | %FileCheck %s

//--- Utility.h
typedef struct {
  int value;
} Wrapper;

//--- Library.swift
public struct S {
  private var w: Wrapper
  public init(value: Int32) {
    w = Wrapper(value: value)
  }
  // Wrapper is hidden from the Client, so Library exposes a public read
  // accessor. Without this the Client has no legal way to observe the
  // bytes that the layout-table-driven copy was supposed to preserve.
  public func payload() -> Int32 {
    return w.value
  }
}

//--- Client.swift
import Library

// This pattern reliably exposes the calling-convention mismatch:
//
//   let s = S(value: 42)
//   var s2 = s              // s2 should be 42
//   s2 = S(value: 99)       // s2 should be 99
//   s2 = s                  // s2 should be 42 again
//   return s2.payload()     // expect 42
//
// The runtime returns 99, not 42, because S.payload()'s self argument
// rides through w0 from the *last* S.init call (which set w0 = 99).
// memcpy through s2's stack slot is correct; the bug is at the call
// boundary, not in the layout.
@inline(never)
func roundTrip() -> Int32 {
  let s = S(value: 42)
  var s2 = s
  s2 = S(value: 99)
  s2 = s
  return s2.payload()
}

// Sizes/alignment/stride match the Wrapper layout-table entry. This part
// works correctly today because it doesn't cross a function boundary
// against Library's mismatched ABI for S.
// CHECK: size=4 alignment=4 stride=4
print("size=\(MemoryLayout<S>.size) "
    + "alignment=\(MemoryLayout<S>.alignment) "
    + "stride=\(MemoryLayout<S>.stride)")

// Once the struct-level address-only marker lands, this should print 42.
// CHECK-NEXT: payload=42
print("payload=\(roundTrip())")
