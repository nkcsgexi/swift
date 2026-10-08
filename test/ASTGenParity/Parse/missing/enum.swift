// RUN; %target-typecheck-verify-swift -verify-ignore-unrelated

enum Empty {}

enum Boolish {
  case falsy
  case truthy

  init() { self = .falsy }
}

var b = Boolish.falsy
b = .truthy

enum Optionable<T> {
  case Nought
  case Mere(T)
}

var o = Optionable<Int>.Nought
o = .Mere(0)

enum Color { case Red, Green, Grayscale(Int), Blue }

var c = Color.Red
c = .Green
c = .Grayscale(255)
c = .Blue

let partialApplication = Color.Grayscale

// Cases are excluded from non-enums.
case FloatingCase // expected_error{{enum 'case' is not allowed outside of an enum}}

struct SomeStruct {
  case StructCase // expected_error{{enum 'case' is not allowed outside of an enum}}
}

class SomeClass {
  case ClassCase // expected_error{{enum 'case' is not allowed outside of an enum}}
}

enum EnumWithExtension1 {
  case A1
}
extension EnumWithExtension1 {
  case A2 // expected_error{{enum 'case' is not allowed outside of an enum}}
}

// Attributes for enum cases.

enum EnumCaseAttributes {
  @xyz case EmptyAttributes  // expected_error {{unknown attribute 'xyz'}}
}

// Recover when a switch 'case' label is spelled inside an enum (or outside).
enum SwitchEnvy {
  case X: // expected_error{{'case' label can only appear inside a 'switch' statement}}
  case X(Y): // expected_error{{'case' label can only appear inside a 'switch' statement}}
  case X, Y: // expected_error{{'case' label can only appear inside a 'switch' statement}}
  case X where true: // expected_error{{'case' label can only appear inside a 'switch' statement}}
  case X(Y), Z(W): // expected_error{{'case' label can only appear inside a 'switch' statement}}
  case X(Y) where true: // expected_error{{'case' label can only appear inside a 'switch' statement}}
  case 0: // expected_error{{'case' label can only appear inside a 'switch' statement}}
  case _: // expected_error{{'case' label can only appear inside a 'switch' statement}}
  case (_, var x, 0): // expected_error{{'case' label can only appear inside a 'switch' statement}}
}

enum HasMethodsPropertiesAndCtors {
  case TweedleDee
  case TweedleDum

  func method() {}
  func staticMethod() {}

  init() {}

  subscript(x:Int) -> Int {
    return 0
  }

  var property : Int {
    return 0
  }
}

enum ImproperlyHasIVars {
  case Flopsy
  case Mopsy

  var ivar : Int // expected_error{{enums must not contain stored properties}}
}

// We used to crash on this.  rdar://14678675
enum rdar14678675 {
  case U1, // expected_error{{expected identifier after comma in enum 'case' declaration}}
  case U2 
  case U3
}

enum Recovery1 {
  case: // expected_error {{'case' label can only appear inside a 'switch' statement}} expected_error {{expected pattern}}
}
enum Recovery2 {
  case UE1: // expected_error {{'case' label can only appear inside a 'switch' statement}}
}
enum Recovery3 {
  case UE2(Void): // expected_error {{'case' label can only appear inside a 'switch' statement}}
}
enum Recovery4 { // expected_note {{in declaration of 'Recovery4'}}
  case Self Self // expected_error {{keyword 'Self' cannot be used as an identifier here}} expected_note {{if this name is unavoidable, use backticks to escape it}} {{8-12=`Self`}} expected_error {{consecutive declarations on a line must be separated by ';'}} {{12-12=;}} expected_error {{expected declaration}}
}
enum Recovery5 {
  case .UE3 // expected_error {{extraneous '.' in enum 'case' declaration}} {{8-9=}}
  case .UE4, .UE5
  // expected_error@-1{{extraneous '.' in enum 'case' declaration}} {{8-9=}}
  // expected_error@-2{{extraneous '.' in enum 'case' declaration}} {{14-15=}}
}
enum Recovery6 {
  case Snout, _; // expected_error {{keyword '_' cannot be used as an identifier here}} expected_note {{if this name is unavoidable, use backticks to escape it}} {{15-16=`_`}} expected_note {{'_' previously declared here}}
  case _; // expected_error {{keyword '_' cannot be used as an identifier here}} expected_note {{if this name is unavoidable, use backticks to escape it}} {{8-9=`_`}} expected_error {{invalid redeclaration of '_'}}
  case Tusk, // expected_error {{expected identifier after comma in enum 'case' declaration}}
} 

enum RawTypeEmpty : Int {} // expected_error {{an enum with no cases cannot declare a raw type}} expected_note {{add stubs for conformance}}
// expected_error@-1{{'RawTypeEmpty' declares raw type 'Int', but does not conform to RawRepresentable and conformance could not be synthesized}}

enum Raw : Int {
  case Ankeny, Burnside
}

enum MultiRawType : Int64, Int32 { // expected_error {{multiple enum raw types 'Int64' and 'Int32'}}
  case Couch, Davis
}

protocol RawTypeNotFirstProtocol {}
enum RawTypeNotFirst : RawTypeNotFirstProtocol, Int { // expected_error {{raw type 'Int' must appear first in the enum inheritance clause}} {{24-24=Int, }} {{47-52=}}
  case E
}

enum ExpressibleByRawTypeNotLiteral : Array<Int> { // expected_error {{raw type 'Array<Int>' is not expressible by a string, integer, or floating-point literal}} expected_note {{add stubs for conformance}}
  // expected_error@-1{{'ExpressibleByRawTypeNotLiteral' declares raw type 'Array<Int>', but does not conform to RawRepresentable and conformance could not be synthesized}}
  case Ladd, Elliott, Sixteenth, Harrison
}

enum RawTypeCircularityA : RawTypeCircularityB, ExpressibleByIntegerLiteral { // expected_error {{'RawTypeCircularityA' has a raw type that depends on itself}}
  case Morrison, Belmont, Madison, Hawthorne

  init(integerLiteral value: Int) {
    self = .Morrison
  }
}

enum RawTypeCircularityB : RawTypeCircularityA, ExpressibleByIntegerLiteral { // expected_note {{enum 'RawTypeCircularityB' declared here}} 
  case Willamette, Columbia, Sandy, Multnomah

  init(integerLiteral value: Int) { 
    self = .Willamette
  }
}

struct ExpressibleByFloatLiteralOnly : ExpressibleByFloatLiteral {
    init(floatLiteral: Double) {}
}
enum ExpressibleByRawTypeNotIntegerLiteral : ExpressibleByFloatLiteralOnly { // expected_error {{'ExpressibleByRawTypeNotIntegerLiteral' declares raw type 'ExpressibleByFloatLiteralOnly', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_error {{RawRepresentable conformance cannot be synthesized because raw type 'ExpressibleByFloatLiteralOnly' is not Equatable}} expected_note {{add stubs for conformance}}
  case Everett // expected_error {{enum cases require explicit raw values when the raw type is not expressible by integer or string literal}}
  case Flanders
}

enum RawTypeWithIntValues : Int {
  case Glisan = 17, Hoyt = 219, Irving, Johnson = 97209
}

enum RawTypeWithNegativeValues : Int {
  case Glisan = -17, Hoyt = -219, Irving, Johnson = -97209
  case AutoIncAcrossZero = -1, Zero, One
}

enum RawTypeWithUnicodeScalarValues : UnicodeScalar { // expected_error {{'RawTypeWithUnicodeScalarValues' declares raw type 'UnicodeScalar' (aka 'Unicode.Scalar'), but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case Kearney = "K"
  case Lovejoy // expected_error {{enum cases require explicit raw values when the raw type is not expressible by integer or string literal}}
  case Marshall = "M"
}

enum RawTypeWithCharacterValues : Character { // expected_error {{'RawTypeWithCharacterValues' declares raw type 'Character', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case First = "い"
  case Second // expected_error {{enum cases require explicit raw values when the raw type is not expressible by integer or string literal}}
  case Third = "は"
}

enum RawTypeWithCharacterValues_Correct : Character {
  case First = "😅" // ok
  case Second = "👩‍👩‍👧‍👦" // ok
  case Third = "👋🏽" // ok
  case Fourth = "\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}" // ok
}

enum RawTypeWithCharacterValues_Error1 : Character { // expected_error {{'RawTypeWithCharacterValues_Error1' declares raw type 'Character', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case First = "abc" // expected_error {{cannot convert value of type 'String' to raw type 'Character'}}
}

enum RawTypeWithStringValues : String {
  case Primrose // okay
  case Quimby = "Lucky Lab"
  case Raleigh // okay
  case Savier = "McMenamin's", Thurman = "Kenny and Zuke's"
}

enum RawValuesWithoutRawType {
  case Upshur = 22 // expected_error {{enum case cannot have a raw value if the enum does not have a raw type}}
}

enum RawTypeWithRepeatValues : Int {
  case Vaughn = 22 // expected_note {{raw value previously used here}}
  case Wilson = 22 // expected_error {{raw value for enum case is not unique}}
}

enum RawTypeWithRepeatValuesString : String {
  case Vaughn = "XYZ" // expected_note {{raw value previously used here}}
  case Wilson = "XYZ" // expected_error {{raw value for enum case is not unique}}
}

enum RawTypeWithRepeatValuesAutoInc1 : String {
  case A = "B" // expected_note {{raw value previously used here}}
  case B // expected_error {{raw value for enum case is not unique}}
}

enum RawTypeWithRepeatValuesAutoInc2 : String {
  case A // expected_note {{raw value previously used here}}
  case B = "A" // expected_error {{raw value for enum case is not unique}}
}

enum RawTypeWithRepeatValuesAutoInc3 : String {
  case A
  case B // expected_note {{raw value previously used here}}
  case C = "B" // expected_error {{raw value for enum case is not unique}}
}

enum NonliteralRawValue : Int {
  case Yeon = 100 + 20 + 3 // expected_error {{raw value for enum case must be a literal}}
}

enum RawTypeWithPayload : Int { // expected_error {{'RawTypeWithPayload' declares raw type 'Int', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{declared raw type 'Int' here}} expected_note {{declared raw type 'Int' here}} expected_note {{add stubs for conformance}}
  case Powell(Int) // expected_error {{enum with raw type cannot have cases with arguments}}
  case Terwilliger(Int) = 17 // expected_error {{enum with raw type cannot have cases with arguments}}
}

enum RawTypeMismatch : Int { // expected_error {{'RawTypeMismatch' declares raw type 'Int', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case Barbur = "foo" // expected_error {{}}
}

enum DuplicateMembers1 {
  case Foo // expected_note {{'Foo' previously declared here}}
  case Foo // expected_error {{invalid redeclaration of 'Foo'}}
}

enum DuplicateMembers2 {
  case Foo, Bar // expected_note {{'Foo' previously declared here}} expected_note {{'Bar' previously declared here}}
  case Foo // expected_error {{invalid redeclaration of 'Foo'}}
  case Bar // expected_error {{invalid redeclaration of 'Bar'}}
}

enum DuplicateMembers3 {
  case Foo // expected_note {{'Foo' previously declared here}}
  case Foo(Int) // expected_error {{invalid redeclaration of 'Foo'}}
}

enum DuplicateMembers4 : Int { // expected_error {{'DuplicateMembers4' declares raw type 'Int', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case Foo = 1 // expected_note {{'Foo' previously declared here}}
  case Foo = 2 // expected_error {{invalid redeclaration of 'Foo'}}
}

enum DuplicateMembers5 : Int { // expected_error {{'DuplicateMembers5' declares raw type 'Int', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case Foo = 1 // expected_note {{'Foo' previously declared here}}
  case Foo = 1 + 1 // expected_error {{invalid redeclaration of 'Foo'}} expected_error {{raw value for enum case must be a literal}}
}

enum DuplicateMembers6 {
  case Foo // expected_note 2{{'Foo' previously declared here}}
  case Foo // expected_error {{invalid redeclaration of 'Foo'}}
  case Foo // expected_error {{invalid redeclaration of 'Foo'}}
}

enum DuplicateMembers7 : String { // expected_error {{'DuplicateMembers7' declares raw type 'String', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case Foo // expected_note {{'Foo' previously declared here}}
  case Foo = "Bar" // expected_error {{invalid redeclaration of 'Foo'}}
}

enum DuplicateMembers8 : String { // expected_error {{'DuplicateMembers8' declares raw type 'String', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case Foo // expected_note {{'Foo' previously declared here}}
  // expected_note@-1 {{raw value previously used here}}
  case Foo // expected_error {{invalid redeclaration of 'Foo'}}
  // expected_error@-1 {{raw value for enum case is not unique}}
}

enum DuplicateMembers9 : String { // expected_error {{'DuplicateMembers9' declares raw type 'String', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case Foo = "Foo" // expected_note {{'Foo' previously declared here}}
  // expected_note@-1 {{raw value previously used here}}
  case Foo = "Foo"// expected_error {{invalid redeclaration of 'Foo'}}
  // expected_error@-1 {{raw value for enum case is not unique}}
}

enum DuplicateMembers10 : String {
  case Foo // expected_note {{raw value previously used here}}
  case Bar = "Foo" // expected_error {{raw value for enum case is not unique}}
}

// Refs to duplicated enum cases shouldn't crash the compiler.
// rdar://problem/20922401
func check20922401() -> String {
  let x: DuplicateMembers1 = .Foo 
  switch x {
    case .Foo:
      return "Foo"
  }
}

enum PlaygroundRepresentation : UInt8 {
  case Class = 1
  case Struct = 2
  case Tuple = 3
  case Enum = 4
  case Aggregate = 5
  case Container = 6
  case IDERepr = 7
  case Gap = 8
  case ScopeEntry = 9
  case ScopeExit = 10
  case Error = 11
  case IndexContainer = 12
  case KeyContainer = 13
  case MembershipContainer = 14
  case Unknown = 0xFF

  static func fromByte(byte : UInt8) -> PlaygroundRepresentation {
    let repr = PlaygroundRepresentation(rawValue: byte)
    if repr == .none { return .Unknown } else { return repr! }
  }
}

struct ManyLiteralable : ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, Equatable {
  init(stringLiteral: String) {}
  init(integerLiteral: Int) {}

  init(unicodeScalarLiteral: String) {}
  init(extendedGraphemeClusterLiteral: String) {}
}
func ==(lhs: ManyLiteralable, rhs: ManyLiteralable) -> Bool { return true }

enum ManyLiteralA : ManyLiteralable {
  case A // expected_note {{raw value previously used here}} expected_note {{raw value implicitly auto-incremented from zero}}
  case B = 0 // expected_error {{raw value for enum case is not unique}}
}

enum ManyLiteralB : ManyLiteralable { // expected_error {{'ManyLiteralB' declares raw type 'ManyLiteralable', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case A = "abc"
  case B // expected_error {{enum case must declare a raw value when the preceding raw value is not an integer}}
}

enum ManyLiteralC : ManyLiteralable {
  case A
  case B = "0"
}

enum foo : String { // expected_error {{'foo' declares raw type 'String', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case bar = nil // expected_error {{cannot convert 'nil' to raw type 'String'}}
}

// Static member lookup from instance methods

struct EmptyStruct {}

enum EnumWithStaticMember {
  static let staticVar = EmptyStruct()

  func foo() {
    let _ = staticVar // expected_error {{static member 'staticVar' cannot be used on instance of type 'EnumWithStaticMember'}}
  }
}

// SE-0036:

struct SE0036_Auxiliary {}

enum SE0036 {
  case A
  case B(SE0036_Auxiliary)
  case C(SE0036_Auxiliary)

  static func staticReference() {
    _ = A
    _ = self.A
    _ = SE0036.A
  }

  func staticReferenceInInstanceMethod() {
    _ = A // expected_error {{enum case 'A' cannot be used as an instance member}} {{9-9=SE0036.}}
    _ = self.A // expected_error {{enum case 'A' cannot be used as an instance member}} {{9-13=SE0036}}
    _ = SE0036.A
  }

  static func staticReferenceInSwitchInStaticMethod() {
    switch SE0036.A {
    case A: break
    case B(_): break
    case C(let x): _ = x; break
    }
  }

  func staticReferenceInSwitchInInstanceMethod() {
    switch self {
    case A: break // expected_error {{enum case 'A' cannot be used as an instance member}} {{10-10=.}}
    case B(_): break // expected_error {{'_' can only appear in a pattern or on the left side of an assignment}}
    case C(let x): _ = x; break // expected_error {{enum case 'C' cannot be used as an instance member}} {{10-10=.}}
    }
  }

  func explicitReferenceInSwitch() {
    switch SE0036.A {
    case SE0036.A: break
    case SE0036.B(_): break
    case SE0036.C(let x): _ = x; break
    }
  }

  func dotReferenceInSwitchInInstanceMethod() {
    switch self {
    case .A: break
    case .B(_): break
    case .C(let x): _ = x; break
    }
  }

  static func dotReferenceInSwitchInStaticMethod() {
    switch SE0036.A {
    case .A: break
    case .B(_): break
    case .C(let x): _ = x; break
    }
  }

  init() {
    self = .A
    self = A // expected_error {{enum case 'A' cannot be used as an instance member}} {{12-12=SE0036.}}
    self = SE0036.A
    self = .B(SE0036_Auxiliary())
    self = B(SE0036_Auxiliary()) // expected_error {{enum case 'B' cannot be used as an instance member}} {{12-12=SE0036.}}
    self = SE0036.B(SE0036_Auxiliary())
  }
}

enum SE0036_Generic<T> {
  case A(x: T)

  func foo() {
    switch self {
    case A(_): break // expected_error {{'_' can only appear in a pattern or on the left side of an assignment}}
    }

    switch self {
    case .A(let a): print(a)
    }

    switch self {
    case SE0036_Generic.A(let a): print(a)
    }
  }
}

enum switch {} // expected_error {{keyword 'switch' cannot be used as an identifier here}} expected_note {{if this name is unavoidable, use backticks to escape it}} {{6-12=`switch`}}

enum SE0155 {
  case emptyArgs() // expected_warning {{enum element with associated values must have at least one associated value}}
  // expected_note@-1 {{did you mean to remove the empty associated value list?}} {{17-19=}}
  // expected_note@-2 {{did you mean to explicitly add a 'Void' associated value?}} {{18-18=Void}}
}

// https://github.com/apple/swift/issues/53662

enum E_53662 {
  case identifier
  case operator // expected_error {{keyword 'operator' cannot be used as an identifier here}} expected_note {{if this name is unavoidable, use backticks to escape it}} {{8-16=`operator`}}
  case identifier2
}

enum E_53662_var {
  case identifier
  case var // expected_error {{keyword 'var' cannot be used as an identifier here}} expected_note {{if this name is unavoidable, use backticks to escape it}} {{8-11=`var`}}
  case identifier2
}

enum E_53662_underscore {
  case identifier
  case _ // expected_error {{keyword '_' cannot be used as an identifier here}} expected_note {{if this name is unavoidable, use backticks to escape it}} {{8-9=`_`}}
  case identifier2
}

enum E_53662_Comma {
  case a, b, c, func, d // expected_error {{keyword 'func' cannot be used as an identifier here}} expected_note {{if this name is unavoidable, use backticks to escape it}} {{17-21=`func`}}
}

enum E_53662_Newline {
  case identifier1
  case identifier2
  case 
  case identifier // expected_error {{keyword 'case' cannot be used as an identifier here}} expected_note {{if this name is unavoidable, use backticks to escape it}} {{3-7=`case`}}
}

enum E_53662_Newline2 {
  case 
  func foo() {} // expected_error {{keyword 'func' cannot be used as an identifier here}} expected_note {{if this name is unavoidable, use backticks to escape it}} {{3-7=`func`}}
}

enum E_53662_PatternMatching {
  case let .foo(x, y): // expected_error {{'case' label can only appear inside a 'switch' statement}}
}

enum CasesWithMissingElement: Int {
  // expected_error@-1 {{'CasesWithMissingElement' declares raw type 'Int', but does not conform to RawRepresentable and conformance could not be synthesized}}
  // expected_note@-2 {{add stubs for conformance}}

  case a = "hello", // expected_error{{expected identifier after comma in enum 'case' declaration}}
  // expected_error@-1 {{cannot convert value of type 'String' to raw type 'Int'}}

  case b = "hello", // expected_error{{expected identifier after comma in enum 'case' declaration}}
  // expected_error@-1 {{cannot convert value of type 'String' to raw type 'Int'}}
}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/enum.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@33:1 {{}} // disallowed_enum_element
// expected-error@36:3 {{}} // disallowed_enum_element
// expected-error@40:3 {{}} // disallowed_enum_element
// expected-error@47:3 {{}} // disallowed_enum_element
// expected-error@58:3 {{}} // case_outside_of_switch
// expected-error@59:3 {{}} // case_outside_of_switch
// expected-error@60:3 {{}} // case_outside_of_switch
// expected-error@61:3 {{}} // case_outside_of_switch
// expected-error@62:3 {{}} // case_outside_of_switch
// expected-error@63:3 {{}} // case_outside_of_switch
// expected-error@64:3 {{}} // case_outside_of_switch
// expected-error@65:3 {{}} // case_outside_of_switch
// expected-error@66:3 {{}} // case_outside_of_switch
// expected-error@96:11 {{}} // expected_identifier_after_case_comma
// expected-error@102:3 {{}} // case_outside_of_switch
// expected-error@102:7 {{}} // expected_pattern
// expected-error@105:3 {{}} // case_outside_of_switch
// expected-error@108:3 {{}} // case_outside_of_switch
// expected-note@110:6 {{}} // note_in_decl_of
// expected-error@111:8 {{}} // keyword_cant_be_identifier
// expected-note@111:8 {{}} // backticks_to_escape
// expected-error@111:12 {{}} // declaration_same_line_without_semi
// expected-error@111:13 {{}} // expected_decl
// expected-error@114:8 {{}} // enum_case_dot_prefix
// expected-error@115:8 {{}} // enum_case_dot_prefix
// expected-error@115:14 {{}} // enum_case_dot_prefix
// expected-error@120:15 {{}} // keyword_cant_be_identifier
// expected-note@120:15 {{}} // backticks_to_escape
// expected-error@121:8 {{}} // keyword_cant_be_identifier
// expected-note@121:8 {{}} // backticks_to_escape
// expected-error@122:13 {{}} // expected_identifier_after_case_comma
// expected-error@240:15 {{}} // nonliteral_enum_case_raw_value
// expected-error@275:14 {{}} // nonliteral_enum_case_raw_value
// expected-error@470:6 {{}} // keyword_cant_be_identifier
// expected-note@470:6 {{}} // backticks_to_escape
// expected-warning@473:17 {{}} // enum_element_empty_arglist_swift4
// expected-note@473:17 2 {{}} // enum_element_empty_arglist_add_void,enum_element_empty_arglist_delete
// expected-error@482:8 {{}} // keyword_cant_be_identifier
// expected-note@482:8 {{}} // backticks_to_escape
// expected-error@488:8 {{}} // keyword_cant_be_identifier
// expected-note@488:8 {{}} // backticks_to_escape
// expected-error@494:8 {{}} // keyword_cant_be_identifier
// expected-note@494:8 {{}} // backticks_to_escape
// expected-error@499:17 {{}} // keyword_cant_be_identifier
// expected-note@499:17 {{}} // backticks_to_escape
// expected-error@506:3 {{}} // keyword_cant_be_identifier
// expected-note@506:3 {{}} // backticks_to_escape
// expected-error@511:3 {{}} // keyword_cant_be_identifier
// expected-note@511:3 {{}} // backticks_to_escape
// expected-error@515:3 {{}} // case_outside_of_switch
// expected-error@522:20 {{}} // expected_identifier_after_case_comma
// expected-error@525:20 {{}} // expected_identifier_after_case_comma
// ---- end ASTGen parity ----
