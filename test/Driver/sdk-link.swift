// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -emit-module -o %t/test.swiftmodule %s
// RUN: %target-build-swift -g -o %t/sdk-link %s
// RUN: %target-codesign %t/sdk-link
// RUN: %target-run %t/sdk-link | %FileCheck %s
// REQUIRES: executable_test

// REQUIRES: objc_interop
// REQUIRES: rdar42247881

import Foundation

// CHECK: {{^}}ABCDEF{{$}}
print(("ABC" as NSString).appending("DEF"))
