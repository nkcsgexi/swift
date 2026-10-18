// Test that a doc comment record with an out of range length is ignored
// instead of reading past the end of the record.
//
// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -module-name comments -emit-module -emit-module-path %t/comments.swiftmodule -emit-module-doc -emit-module-doc-path %t/comments.swiftdoc %s
// RUN: %{python} %S/Inputs/corrupt_doc_comment_length.py %t/comments.swiftdoc malformed_brief_marker
// RUN: %target-swift-ide-test -print-module-comments -module-to-print=comments -source-filename %s -I %t | %FileCheck %s

/// malformed_brief_marker
public func malformed() {}
// CHECK: Func/malformed RawComment=none BriefComment=none DocCommentAsXML=none

/// intact_brief_marker
public func intact() {}
// CHECK: Func/intact RawComment=[/// intact_brief_marker\n] BriefComment=[intact_brief_marker]
