// Test that a Library encapsulating a *copyable* non-trivial C++ type behind an
// internal bridging header force-emits the type's foreign metadata and a
// public, module-scoped metadata accessor that a client lacking the C++ header
// can bind to. (encap-c-decl step 2: defining-module witness emission.)

// REQUIRES: swift_feature_AbstractStoredPropertyLayout
// REQUIRES: PTRSIZE=64

// RUN: %empty-directory(%t)
// RUN: split-file %s %t

// RUN: %target-swift-frontend \
// RUN:   -internal-import-bridging-header %t/Cxx.h \
// RUN:   -enable-experimental-feature AbstractStoredPropertyLayout \
// RUN:   -cxx-interoperability-mode=default \
// RUN:   -emit-ir -module-name Library \
// RUN:   -parse-as-library \
// RUN:   %t/Library.swift | %FileCheck %s

//--- Cxx.h
struct Holder {
  int *ptr;
  Holder() : ptr(nullptr) {}
  // User-provided copy constructor + destructor make this non-trivial, but it
  // remains copyable -> imported as a copyable, address-only struct -> opaque.
  Holder(const Holder &other) : ptr(other.ptr) {}
  ~Holder() {}
};

//--- Library.swift
public struct W {
  private var h: Holder
  public init() { h = Holder() }
}

// The public, module-scoped, exported (weak_odr) accessor for the hidden C++
// type, forwarding to the type's foreign metadata accessor. The "$s...Ma"
// fragment is the type's ordinary foreign metadata-accessor mangling.
// CHECK: define weak_odr {{.*}}@"__swift_encap_vwt_accessor_Library_$s{{.*}}Ma"

// The forwarder calls the (linkonce_odr / non-exported) foreign accessor.
// CHECK: call {{.*}}@"$s{{.*}}Ma"
