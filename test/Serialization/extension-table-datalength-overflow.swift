// Regression test: a type with enough extensions that its serialized
// extension-table entry exceeds 65535 bytes must still round-trip. The on-disk
// dataLength field was 16 bits, so a large entry was silently truncated and the
// tail extensions were dropped from the module with no diagnostic.
//
// For Outer.Inner in module ManyExtLib the entry stores the 28-byte mangled
// base name ($s10ManyExtLib5OuterV5InnerV), so each of the N entries costs
// 36 bytes (4 offset + 4 nameData + 28 name). 3000 entries => 108000 bytes,
// ~1.65x past the old uint16 limit. Members from extensions in the truncated
// tail (e.g. f2000, f3000) must still be visible to a client.

// RUN: %empty-directory(%t)
// RUN: %{python} %S/Inputs/many_extensions.py 3000 > %t/lib.swift
// RUN: %target-swift-frontend -emit-module -module-name ManyExtLib -o %t/ManyExtLib.swiftmodule %t/lib.swift
// RUN: %target-swift-frontend -typecheck -I %t %s

import ManyExtLib

func use(_ x: Outer.Inner) -> Int {
  return x.f2000() + x.f3000()
}
