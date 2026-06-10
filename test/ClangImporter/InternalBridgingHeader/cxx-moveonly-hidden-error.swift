// Test that a *move-only* (~Copyable) non-trivial C++ type cannot be
// encapsulated as a hidden stored property behind an internal bridging header:
// the encap-c-decl copyable-only milestone diagnoses it rather than recording a
// layout that would miscompile.

// REQUIRES: swift_feature_AbstractStoredPropertyLayout

// RUN: %empty-directory(%t)
// RUN: split-file %s %t

// RUN: %target-swift-frontend -typecheck -verify -verify-ignore-unrelated \
// RUN:   -internal-import-bridging-header %t/Cxx.h \
// RUN:   -enable-experimental-feature AbstractStoredPropertyLayout \
// RUN:   -cxx-interoperability-mode=default \
// RUN:   -parse-as-library %t/Library.swift

//--- Cxx.h
struct MoveOnly {
  int *ptr;
  MoveOnly() : ptr(nullptr) {}
  MoveOnly(const MoveOnly &) = delete;        // deleted copy -> imported ~Copyable
  MoveOnly(MoveOnly &&other) : ptr(other.ptr) {}
  ~MoveOnly() {}
};

//--- Library.swift
public struct W: ~Copyable { // expected-error {{non-copyable C++ type 'MoveOnly' cannot be encapsulated as a hidden stored property via the internal bridging header}}
  private var h: MoveOnly
  public init() { h = MoveOnly() }
}
