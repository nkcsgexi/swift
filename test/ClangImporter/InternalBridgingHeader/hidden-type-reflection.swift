// Test that reflection field descriptors suppress hidden fields from an
// internal bridging header: the field record has a null type reference and
// null name, preserving the field count to stay aligned with the metadata's
// field offset vector.

// REQUIRES: swift_feature_AbstractStoredPropertyLayout
// REQUIRES: PTRSIZE=64

// RUN: %empty-directory(%t)
// RUN: split-file %s %t

// RUN: %target-swift-frontend \
// RUN:   -internal-import-bridging-header %t/Utility.h \
// RUN:   -enable-experimental-feature AbstractStoredPropertyLayout \
// RUN:   -emit-ir -module-name Library \
// RUN:   -parse-as-library \
// RUN:   %t/Library.swift | %FileCheck %s

//--- Utility.h
typedef struct {
  int value;
} Wrapper;

typedef struct {
  double d;
} BigWrapper;

//--- Library.swift

// S has one hidden field.
public struct S {
  private var w: Wrapper
  public init(value: Int32) {
    w = Wrapper(value: value)
  }
}

// S2 has one hidden field and one visible field.
public struct S2 {
  private var w: Wrapper
  public var x: Int
  public init() {
    w = Wrapper(value: 0)
    x = 0
  }
}

// S3 has two hidden fields.
public struct S3 {
  private var a: Wrapper
  private var b: BigWrapper
  public init() {
    a = Wrapper(value: 0)
    b = BigWrapper(d: 0.0)
  }
}

// Field descriptor for S: 1 field with null type and null name (hidden).
// Each field record is {i32 flags, i32 type_ref, i32 name_ref}.
// Hidden fields have type_ref=0 and name_ref=0.
// CHECK-DAG: @"$s7Library1SVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32 } { {{.*}}, i32 1, i32 2, i32 0, i32 0 }, section "{{[^"]*}}swift5_fieldmd

// Field descriptor for S2: 2 fields. First hidden (0,0), second visible.
// CHECK-DAG: @"$s7Library2S2VMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 } { {{.*}}, i32 2, i32 2, i32 0, i32 0, i32 2, i32 trunc {{.*}} }, section "{{[^"]*}}swift5_fieldmd

// Field descriptor for S3: 2 hidden fields, both with null type and name.
// CHECK-DAG: @"$s7Library2S3VMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32 } { {{.*}}, i32 2, i32 2, i32 0, i32 0, i32 2, i32 0, i32 0 }, section "{{[^"]*}}swift5_fieldmd
