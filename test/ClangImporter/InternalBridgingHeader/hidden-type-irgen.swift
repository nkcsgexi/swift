// Test that a Client importing a Library compiled with
// -internal-import-bridging-header can allocate, copy, and destroy values
// of types whose stored properties have been encapsulated as HiddenType
// placeholders. The Client never sees Utility.h; IRGen recovers each
// HiddenType's layout via its defining ModuleDecl's HiddenTypeLayouts table
// and lowers value witnesses through memcpy.

// REQUIRES: swift_feature_AbstractStoredPropertyLayout
// REQUIRES: PTRSIZE=64

// RUN: %empty-directory(%t)
// RUN: split-file %s %t

// 1. Build Library.swiftmodule with the internal bridging header. The emitted
//    .swiftmodule carries a HIDDEN_TYPE_LAYOUTS_BLOCK entry for Wrapper and
//    a HiddenType placeholder in the type ref of S.w.
// RUN: %target-swift-frontend \
// RUN:   -internal-import-bridging-header %t/Utility.h \
// RUN:   -enable-experimental-feature AbstractStoredPropertyLayout \
// RUN:   -emit-module -module-name Library \
// RUN:   -parse-as-library \
// RUN:   -o %t/Library.swiftmodule \
// RUN:   %t/Library.swift

// 2. Compile the Client to LLVM IR. The Client has no access to Utility.h,
//    no -import-bridging-header, no -I to the C header. IRGen consumes the
//    HiddenType placeholder via the layout table.
// RUN: %target-swift-frontend \
// RUN:   -enable-experimental-feature AbstractStoredPropertyLayout \
// RUN:   -emit-ir -module-name Client \
// RUN:   -parse-as-library \
// RUN:   -I %t \
// RUN:   %t/Client.swift | %FileCheck --check-prefix=IR %s

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
}

//--- Client.swift
import Library

// The struct's storage materializes as a 4-byte byte-aggregate in the client,
// matching the Wrapper layout-table entry written by Library's serializer.
// IR: %T7Library1SV = type <{ [4 x i8] }>

// IR-LABEL: define {{.*}} @"$s6Client3useyS2iF"
// IR: alloca %T7Library1SV, align 4
// IR: alloca %T7Library1SV, align 4
// IR: call void @llvm.memcpy.{{.*}}(ptr {{[^,]+}}, ptr {{[^,]+}}, i64 4, i1 false)
public func use(_ value: Int) -> Int {
  let s = S(value: Int32(value))
  var s2 = s
  s2 = s
  _ = s2
  return MemoryLayout<S>.size
}

// The Client's IR must not reference Utility.h or the Wrapper symbol — the
// hidden-type substitution + table lookup means no bridging-header path was
// needed during Client compilation.
// IR-NOT: Utility.h
// IR-NOT: SC7Wrapper
