// RUN; %target-typecheck-verify-swift -sdk %clang-importer-sdk -module-name main -I %S/Inputs -parse -verify-additional-prefix legacy-
// RUN; %target-typecheck-verify-swift -sdk %clang-importer-sdk -module-name main -I %S/Inputs -parse -verify-additional-prefix new- -enable-experimental-feature ParserASTGen

// Make sure the lack of the experimental flag disables the feature:
// RUN; not %target-typecheck-verify-swift -sdk %clang-importer-sdk -module-name main -I %S/Inputs 2>/dev/null

// expected_warning@<unknown> * {{libc not found for }}

// REQUIRES; swift_feature_ParserASTGen

// ModuleSelectorImports
import struct ModuleSelectorTestingKit::A

import struct _::A
// expected_error@-1 {{'_' cannot be used as an identifier here}}
// expected_legacy-note@-2 {{if this name is unavoidable, use backticks to escape it}} {{15-16=`_`}}

import struct ModuleSelectorTestingKit::Submodule::A
// expected_legacy-error@-1 {{module selector cannot specify a submodule}} {{41-52=}} expected_new-error@-1 {{unexpected code 'Submodule::' in import}}

import struct ModuleSelectorTestingKit.Submodule::A
// expected_legacy-error@-1 {{module selector cannot specify a submodule}} expected_new-error@-1 {{submodule cannot be imported using module selector}}
// expected_legacy-note@-2 {{replace '::' with '.'}} {{49-51=.}} expected_new-note@-2 {{replace '::' with '.'}} {{49-51=}} {{49-49=.}}

import ctypes::bits
// expected_legacy-error@-1 {{module selector cannot specify a submodule}} expected_new-error@-1 {{submodule cannot be imported using module selector}}
// expected_legacy-note@-2 {{replace '::' with '.'}} {{14-16=.}} expected_new-note@-2 {{replace '::' with '.'}} {{14-16=}} {{14-14=.}}


// ModuleSelectorCorrectCode
extension ModuleSelectorTestingKit::A {}

extension A: @retroactive Swift::Equatable {
  @_implements(Swift::Equatable, ==(_:_:))
  public static func equals(_: ModuleSelectorTestingKit::A, _: ModuleSelectorTestingKit::A) -> Swift::Bool {
    Swift::fatalError()
  }

  // FIXME: Add tests with autodiff @_differentiable(jvp:vjp:) and
  // @_derivative(of:)

  @_dynamicReplacement(for: ModuleSelectorTestingKit::negate())
  mutating func myNegate() {
    let fn: (Swift::Int, Swift::Int) -> Swift::Int = (Swift::+)

    let magnitude: Int.Swift::Magnitude = main::magnitude

    if Swift::Bool.Swift::random() {
      self.ModuleSelectorTestingKit::negate()
    } else {
      self = ModuleSelectorTestingKit::A(value: .Swift::min)
      self = A.ModuleSelectorTestingKit::init(value: .min)
    }

    self.main::myNegate()

    Swift::fatalError()
  }

  // FIXME: Can we test @convention(witness_method:)?
}


extension ModuleSelectorIncorrectAttrNames {
  // An attribute with a module selector *must* be a custom attribute and should be parsed as such.
  @main::available(macOS 10.15, *) var use1: String { "foo" }
  // expected_legacy-error@-1 {{expected ',' separator}} expected_new-error@-1 {{unexpected code '10.15, *' in attribute}}

  @main::available var use2

  @main::available(foo: bar) var use3

  func builderUser2(@main::MyBuilder fn: () -> Void) {}
}

// Repeat this test case at top level to make sure we correctly skip attribute
// module selectors when looking ahead to distinguish declarations from
// expressions.
@main::available(macOS 10.15, *) var use1: String { "foo" }
// expected_legacy-error@-1 {{expected ',' separator}} expected_new-error@-1 {{unexpected code '10.15, *' in attribute}}


// ModuleSelectorWhitespace
_ = Swift::print

_ = Swift:: print

_ = Swift ::print

_ = Swift :: print

_ = Swift::
print
// expected_legacy-error@-2 {{expected identifier after module selector}} expected_new-error@-2 {{expected identifier}}
// expected_legacy-note@-3 {{remove extraneous whitespace after '::'}} {{12-+1:1=}} expected_new-note@-3 {{insert identifier}} {{12-12=<#identifier#>}}

_ = Swift
::print

_ = Swift ::
print
// expected_legacy-error@-2 {{expected identifier after module selector}} expected_new-error@-2 {{expected identifier}}
// expected_legacy-note@-3 {{remove extraneous whitespace after '::'}} {{13-+1:1=}} expected_new-note@-3 {{insert identifier}} {{13-13=<#identifier#>}}

_ = Swift
:: print

_ = Swift
::
print
// expected_legacy-error@-2 {{expected identifier after module selector}} expected_new-error@-2 {{expected identifier}}
// expected_legacy-note@-3 {{remove extraneous whitespace after '::'}} {{3-+1:1=}} expected_new-note@-3 {{insert identifier}} {{3-3=<#identifier#>}}


// ModuleSelectorIncorrectFuncSignature
func main::decl1() {}
// expected_legacy-error@-1 {{expected '(' in argument list of function declaration}} {{none}} expected_new-error@-1 {{unexpected code '::decl1' before parameter clause}}
// expected_legacy-error@-2 {{consecutive statements on a line must be separated by ';'}} {{10-10=;}}
// expected_legacy-error@-3 {{expected module name in module selector}} {{none}}

func decl1(
  main::p1: Swift::A
// expected_legacy-error@-2 {{expected parameter name followed by ':'}} {{none}} expected_new-error@-1 {{unexpected code '::p1' in parameter}}
) {}

// Round-tripping failures:
func decl1(
  main::p1: ::A
// expected_legacy-error@-2 {{expected parameter name followed by ':'}} {{none}} expected_new-error@-1 {{unexpected code '::p1' in parameter}}
// expected_new-error@-2 {{expected module name in module selector}}
// expected_new-note@-3 {{insert module name}} {{13-13=<#identifier#>}}
) {}

func decl1(
  main::p1: Swift::
// expected_legacy-error@-2 {{expected parameter name followed by ':'}} {{none}} expected_new-error@-1 {{unexpected code '::p1' in parameter}}
// expected_new-error@-2 {{expected identifier in type}}
// expected_new-note@-3 {{insert identifier}} {{20-20=<#identifier#>}}
) {}

func decl1(
  main::label p2: Swift::inout A
// expected_legacy-error@-2 {{expected parameter name followed by ':'}} {{none}} expected_new-error@-1 {{unexpected code '::label p2' in parameter}}
// expected_new-error@-2 {{expected ',' in parameter}}
// expected_new-note@-3 {{insert ','}} {{31-32=}} {{32-32=, }}
// expected_new-error@-4 {{expected identifier and ':' in parameter}}
// expected_new-note@-5 {{insert identifier and ':'}} {{32-32=<#identifier#>}}
) {}

func decl1(
  label main::p3: @Swift::escaping () -> A
// expected_legacy-error@-1 {{expected parameter name followed by ':'}} {{none}} expected_new-error@-1 {{unexpected code '::p3' in parameter}}
// expected_legacy-error@-2 {{expected ',' separator}} {{13-13=,}}
// expected_legacy-error@-3 {{expected ':' following argument label and parameter name}} {{none}}
) {}


func testModuleSelectorIncorrectBindingDecls() {
  let main::decl1a = "a"
  // expected_new-error@-1 {{expected '=' in variable}}
  // expected_legacy-error@-2 {{consecutive statements on a line must be separated by ';'}} {{11-11=;}} expected_new-note@-2 {{insert '='}} {{11-11= = }}
  // expected_error@-3 {{expected module name in module selector}}
  // expected_new-note@-4 {{insert module name}} {{11-11=<#identifier#>}}

  // Found by mutation testing:
  let let::decl1a = "a"
  // expected_legacy-error@-1 {{'let' cannot appear nested inside another 'var' or 'let' pattern}} expected_new-error@-1 {{expected pattern in value binding pattern}}
  // expected_legacy-error@-2 {{expected pattern}} expected_new-note@-2 {{insert pattern}} {{10-10=<#pattern#> }}
  // expected_new-error@-3 {{expected '=' in variable}}
  // expected_new-note@-4 {{insert '='}} {{10-10== }}
  // expected_new-error@-5 {{expected module name in module selector}}
  // expected_new-note@-6 {{insert module name}} {{10-10=<#identifier#>}}

  var main::decl1b = "b"
  // expected_new-error@-1 {{expected '=' in variable}}
  // expected_legacy-error@-2 {{consecutive statements on a line must be separated by ';'}} {{11-11=;}} expected_new-note@-2 {{insert '='}} {{11-11= = }}
  // expected_error@-3 {{expected module name in module selector}}
  // expected_new-note@-4 {{insert module name}} {{11-11=<#identifier#>}}

  let (main::decl1c, Swift::decl1d) = ("c", "d")
  // expected_legacy-error@-1 {{expected ',' separator}} {{12-12=,}} expected_new-error@-1 {{unexpected code '::decl1c, Swift::decl1d' in tuple pattern}}
  // expected_legacy-error@-2 {{expected pattern}}

  if let (main::decl1e, Swift::decl1f) = Optional(("e", "f")) {}
  // expected_legacy-error@-1 {{expected ',' separator}} {{15-15=,}} expected_new-error@-1 {{unexpected code '::decl1e, Swift::decl1f' in tuple}}
  // expected_legacy-error@-2 {{expected module name in module selector}}

  guard let (main::decl1g, Swift::decl1h) = Optional(("g", "h")) else { return }
  // expected_legacy-error@-1 {{expected ',' separator}} {{18-18=,}} expected_new-error@-1 {{unexpected code '::decl1g, Swift::decl1h' in tuple}}
  // expected_legacy-error@-2 {{expected module name in module selector}}

  switch Optional(main::decl1g) {
  case Optional.some(let Swift::decl1i):
    // expected_legacy-error@-1 {{expected ',' separator}} {{31-31=,}} expected_new-error@-1 {{unexpected code '::decl1i' in function call}}
    // expected_legacy-error@-2 {{expected module name in module selector}}
    break
  case .none:
    break
  }

  switch Optional(main::decl1g) {
  case let Optional.some(Swift::decl1j):
    // expected_legacy-error@-1 {{expected ',' separator}} {{31-31=,}} expected_new-error@-1 {{unexpected code '::decl1j' in function call}}
    // expected_legacy-error@-2 {{expected module name in module selector}}
    break
  case .none:
    break
  }

  switch Optional(main::decl1g) {
  case let Swift::decl1k?:
    // expected_legacy-error@-1 {{expected ':' after 'case'}} {{none}} expected_new-error@-1 {{unexpected code '::decl1k?' in switch case}}
    // expected_legacy-error@-2 {{expected module name in module selector}}
    // expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} {{26-26=;}}
    // expected_legacy-error@-4 {{expected expression}}
    break
  case .none:
    break
  }

  for main::decl1l in "lll" {}
  // expected_legacy-error@-1 {{expected 'in' after for-each pattern}} {{none}} expected_new-error@-1 {{unexpected code '::decl1l' in 'for' statement}}
  // expected_legacy-error@-2 {{expected module name in module selector}} {{none}}
  // expected_legacy-error@-3 {{expected '{' to start the body of for-each loop}}
}


// ModuleSelectorIncorrectClosureDecls
// This gets radically misinterpreted as two statements followed by some invalid code.
"lll".forEach { [Swift::magnitude]
  main::elem in print(elem)
  // expected_legacy-error@-1 {{expected expression}} expected_new-error@-1 {{unexpected code 'in print(elem)' in closure}}
  // expected_legacy-error@-2 {{consecutive statements on a line must be separated by ';'}} {{13-13=;}}
}

"lll".forEach { (main::elem) in print(elem) }
// expected_legacy-error@-1 {{expected parameter name followed by ':'}} {{none}} expected_new-error@-1 {{unexpected code '::elem' in parameter clause}}
// expected_legacy-error@-2 {{expected ',' separator}} {{22-22=,}}

"lll".forEach { (main::elem) -> Void in print(elem) }
// expected_legacy-error@-1 {{expected parameter name followed by ':'}} {{none}} expected_new-error@-1 {{unexpected code '::elem' in parameter clause}}
// expected_legacy-error@-2 {{expected ',' separator}} {{22-22=,}}

"lll".forEach { (main::elem: Character) -> Void in print(elem) }
// expected_legacy-error@-1 {{expected parameter name followed by ':'}} expected_new-error@-1 {{unexpected code '::elem: Character' in parameter clause}}
// expected_legacy-error@-2 {{expected ',' separator}} {{22-22=,}}


// ModuleSelectorIncorrectTypeDecls
enum main::decl2 {}
// expected_legacy-error@-1 {{expected '{' in enum}} expected_new-error@-1 {{unexpected code '::decl2' in enum}}
enum decl2_substitute {
  // expected_legacy-note@-1 {{in declaration of 'decl2_substitute'}}
  case Swift::decl2a
  // expected_legacy-error@-1 {{expected declaration}} expected_new-error@-1 {{unexpected code '::decl2a' in enum}}
  // expected_legacy-error@-2 {{consecutive declarations on a line must be separated by ';'}} {{13-13=;}}
}

struct main::decl3 {}
// expected_legacy-error@-1 {{expected '{' in struct}} expected_new-error@-1 {{unexpected code '::decl3' in struct}}

class main::decl4<Swift::T> {}
// expected_legacy-error@-1 {{expected '{' in class}} expected_new-error@-1 {{unexpected code '::decl4<Swift::T>' in class}}

typealias main::decl5 = Swift::Bool
// expected_legacy-error@-1 {{expected '=' in type alias declaration}} expected_new-error@-1 {{unexpected code '::decl5' in typealias declaration}}

protocol main::decl6 {}
// expected_legacy-error@-1 {{expected '{' in protocol type}} expected_new-error@-1 {{unexpected code '::decl6' in protocol}}
protocol decl6_substitute {
  // expected_legacy-note@-1 {{in declaration of 'decl6_substitute'}}
  associatedtype Swift::decl6a
  // expected_legacy-error@-1 {{expected declaration}} expected_new-error@-1 {{unexpected code '::decl6a' in protocol}}
  // expected_legacy-error@-2 {{consecutive declarations on a line must be separated by ';'}} {{23-23=;}}
}


// ModuleSelectorIncorrectGlobalVarDecls
let main::decl7 = 7
// expected_legacy-error@-1 {{consecutive statements on a line must be separated by ';'}} {{9-9=;}} expected_new-error@-1 {{expected '=' in variable}}
// expected_new-note@-2 {{insert '='}} {{9-9= = }}
// expected_error@-3 {{expected module name in module selector}}
// expected_new-note@-4 {{insert module name}} {{9-9=<#identifier#>}}

var main::decl8 = 8 {
// expected_legacy-error@-1 {{consecutive statements on a line must be separated by ';'}} {{9-9=;}} expected_new-error@-1 {{expected '=' in variable}}
// expected_new-note@-2 {{insert '='}} {{9-9= = }}
// expected_error@-3 {{expected module name in module selector}}
// expected_new-note@-4 {{insert module name}} {{9-9=<#identifier#>}}
// expected_legacy-error@-5 {{consecutive statements on a line must be separated by ';'}} {{20-20=;}}
// expected_legacy-error@-6 {{top-level statement cannot begin with a closure expression}}
  willSet(Swift::newValue) {}
  // expected_new-error@-1 {{unexpected code '::newValue' in accessor}}
  didSet(Foo::oldValue) {}
  // expected_new-error@-1 {{unexpected code '::oldValue' in accessor}}
}

var decl8_willSet = 8 {
  willSet(Swift::newValue) {}
// expected_legacy-error@-1 {{expected ')' after willSet parameter name}} expected_new-error@-1 {{unexpected code '::newValue' in accessor}}
// expected_legacy-note@-2 {{to match this opening '('}}
// expected_legacy-error@-3 {{expected '{' to start 'willSet' definition}}
  didSet(Foo::oldValue) {}
// expected_new-error@-1 {{unexpected code '::oldValue' in accessor}}
}

var decl8_didSet = 8 {
  willSet(newValue) {}
  didSet(Foo::oldValue) {}
  // expected_legacy-error@-1 {{expected ')' after didSet parameter name}} expected_new-error@-1 {{unexpected code '::oldValue' in accessor}}
  // expected_legacy-note@-2 {{to match this opening '('}}
  // expected_legacy-error@-3 {{expected '{' to start 'didSet' definition}}
}


// ModuleSelectorIncorrectNestedDecls
struct Parent {
  // expected_legacy-note@-1 {{in declaration of 'Parent'}}

  func main::decl1() {}
  // expected_legacy-error@-1 {{expected '(' in argument list of function declaration}} expected_new-error@-1 {{unexpected code '::decl1' before parameter clause}}
  // expected_legacy-error@-2 {{consecutive declarations on a line must be separated by ';'}} {{12-12=;}}
  // expected_legacy-error@-3 {{expected declaration}}

  enum main::decl2 {}
  // expected_legacy-error@-1 {{expected '{' in enum}} expected_new-error@-1 {{unexpected code '::decl2' in enum}}

  enum decl2_substitute {
    // expected_legacy-note@-1 {{in declaration of 'decl2_substitute'}}
    case Swift::decl2a
    // expected_legacy-error@-1 {{consecutive declarations on a line must be separated by ';'}} {{15-15=;}}  expected_new-error@-1 {{unexpected code '::decl2a' in enum}}
    // expected_legacy-error@-2 {{expected declaration}}
  }

  struct main::decl3 {}
// expected_legacy-error@-1 {{expected '{' in struct}} expected_new-error@-1 {{unexpected code '::decl3' in struct}}

  class main::decl4 {}
// expected_legacy-error@-1 {{expected '{' in class}} expected_new-error@-1 {{unexpected code '::decl4' in class}}

  typealias main::decl5 = Swift::Bool
// expected_legacy-error@-1 {{expected '=' in type alias declaration}} expected_new-error@-1 {{unexpected code '::decl5' in typealias declaration}}
}


// ModuleSelectorMacroDecls
struct CreatesDeclExpectation {
  #main::myMacro()
}


// ModuleSelectorIncorrectRuntimeBaseAttr
@_swift_native_objc_runtime_base(main::BaseClass)
// expected_legacy-error@-1 {{expected ')' in '_swift_native_objc_runtime_base' attribute}} FIXME: Should be diagnosed in ASTGen
// expected_legacy-error@-2 {{expected declaration}}
class C1 {}


// ModuleSelectorOperatorDecls
infix operator <<<<< : Swift::AdditionPrecedence
// expected_legacy-error@-1 {{consecutive statements on a line must be separated by ';'}} {{29-29=;}} expected_new-error@-1 {{consecutive statements on a line must be separated by newline or ';'}}
// expected_new-note@-2 {{insert newline}} {{29-29=\n}}
// expected_new-note@-3 {{insert ';'}} {{29-29=;}}
// expected_error@-4 {{expected module name in module selector}}
// expected_new-note@-5 {{insert module name}} {{29-29=<#identifier#>}}

precedencegroup main::PG1 {}
// expected_legacy-error@-1 {{expected '{' after name of precedence group}} expected_new-error@-1 {{unexpected code '::PG1' in precedencegroup}}
precedencegroup PG1_substitute {
  higherThan: Swift::AdditionPrecedence
// expected_legacy-error@-1 {{expected operator attribute identifier in precedence group body}} expected_new-error@-1 {{unexpected code '::AdditionPrecedence' in precedencegroup}}
}


// ModuleSelectorIllFormedModuleNames
var a: ::Int
// expected_error@-1 {{expected module name in module selector}}
// expected_new-note@-2 {{insert module name}} {{8-8=<#identifier#>}}

var b: (::Int)
// expected_error@-1 {{expected module name in module selector}}
// expected_new-note@-2 {{insert module name}} {{9-9=<#identifier#>}}

var c: *::Int
// expected_legacy-error@-1 {{expected type}} expected_new-error@-1 {{expected type in type annotation}}
// expected_new-note@-2 {{insert type}} {{8-8=<#type#>}}
// expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} expected_new-error@-3 {{unexpected code '*::Int' in source file}}
// expected_legacy-error@-4 {{expected module name in module selector}}

var d: _::Int
// expected_error@-1 {{'_' cannot be used as an identifier here}}
// expected_legacy-note@-2 {{if this name is unavoidable, use backticks to escape it}} {{8-9=`_`}}

var e: Self::Int
// expected_error@-1 {{keyword 'Self' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{8-12=`Self`}}

var f: self::Int
// expected_error@-1 {{keyword 'self' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{8-12=`self`}}

var g: inout::Int
// expected_new-error@-1 {{expected type in type annotation}}
// expected_new-note@-2 {{insert type}} {{8-8=<#type#>}}
// expected_new-error@-3 {{expected pattern in variable}}
// expected_new-note@-4 {{insert pattern}} {{13-13=<#pattern#> }}
// expected_new-error@-5 {{expected '=' in variable}}
// expected_new-note@-6 {{insert '='}} {{13-13== }}
// expected_legacy-error@-7 {{expected module name in module selector}} expected_new-error@-7 {{expected module name in module selector}}
// expected_new-note@-8 {{insert module name}} {{13-13=<#identifier#>}}

var h: Any::Int
// expected_error@-1 {{keyword 'Any' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{8-11=`Any`}}

var aArray: [::Int]
// expected_error@-1 {{expected module name in module selector}}
// expected_new-note@-2 {{insert module name}} {{14-14=<#identifier#>}}

var bArray: [(::Int)]
// expected_error@-1 {{expected module name in module selector}}
// expected_new-note@-2 {{insert module name}} {{15-15=<#identifier#>}}

var cArray: [*::Int]
// expected_legacy-error@-1 {{expected element type}} expected_new-error@-1 {{expected type in array type}}
// expected_new-note@-2 {{insert type}} {{14-14=<#type#>}}
// expected_legacy-error@-3 {{expected ']' in array type}}
// expected_legacy-note@-4 {{to match this opening '['}}
// expected_legacy-error@-5 {{consecutive statements on a line must be separated by ';'}} {{14-14=;}} expected_new-error@-5 {{unexpected code '*::Int' in array type}}
// expected_legacy-error@-6 {{expected module name in module selector}}
// expected_legacy-error@-7 {{consecutive statements on a line must be separated by ';'}} {{20-20=;}}
// expected_legacy-error@-8 {{expected expression}}

var dArray: [_::Int]
// expected_error@-1 {{'_' cannot be used as an identifier here}}
// expected_legacy-note@-2 {{if this name is unavoidable, use backticks to escape it}} {{14-15=`_`}}

var eArray: [Self::Int]
// expected_error@-1 {{keyword 'Self' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{14-18=`Self`}}

var fArray: [self::Int]
// expected_error@-1 {{keyword 'self' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{14-18=`self`}}

var gArray: [inout::Int]
// expected_new-error@-1 {{expected type and ']' to end array type}}
// expected_new-note@-2 {{insert type and ']'}} {{14-14=<#type#>}} {{14-14=]}}
// expected_new-error@-3 {{expected pattern in variable}}
// expected_new-note@-4 {{insert pattern}} {{19-19=<#pattern#> }}
// expected_new-error@-5 {{expected '=' in variable}}
// expected_new-note@-6 {{insert '='}} {{19-19== }}
// expected_error@-7 {{expected module name in module selector}}
// expected_new-note@-8 {{insert module name}} {{19-19=<#identifier#>}}
// expected_new-error@-9 {{unexpected code ']' in source file}}

var hArray: [Any::Int]
// expected_error@-1 {{keyword 'Any' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{14-17=`Any`}}

var aIndex: String.::Index
// expected_error@-1 {{expected module name in module selector}}
// expected_new-note@-2 {{insert module name}} {{20-20=<#identifier#>}}

// FIXME: This gets interpreted as a single `.*` operator; may not be ideal.
var cIndex: String.*::Index
// expected_legacy-error@-1 {{consecutive statements on a line must be separated by ';'}} {{19-19=;}}
// expected_legacy-error@-2 {{expected expression after unary operator}} expected_new-error@-2 {{unexpected code '.*::Index' in source file}}
// expected_legacy-error@-3 {{expected module name in module selector}}

var dIndex: String._::Index
// expected_error@-1 {{'_' cannot be used as an identifier here}}
// expected_legacy-note@-2 {{if this name is unavoidable, use backticks to escape it}} {{20-21=`_`}}

var eIndex: String.Self::Index
// expected_error@-1 {{keyword 'Self' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{20-24=`Self`}}

var fIndex: String.self::Index
// expected_error@-1 {{keyword 'self' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{20-24=`self`}}

var gIndex: String.inout::Index
// expected_legacy-error@-1 {{expected identifier in dotted type}} expected_new-error@-1 {{expected '=' in variable}}
// expected_new-note@-2 {{insert '='}} {{25-25= = }}
// expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} {{20-20=;}}
// expected_legacy-error@-4 {{expected expression}} expected_new-error@-4 {{expected module name in module selector}}
// expected_new-note@-5 {{insert module name}} {{25-25=<#identifier#>}}

var hIndex: String.Any::Index
// expected_error@-1 {{keyword 'Any' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{20-23=`Any`}}

func inExpr() {
  ::print()
// expected_error@-1 {{expected module name in module selector}}
// expected_new-note@-2 {{insert module name}} {{-1:16-+0:3=}} {{-1:16-16=\n  <#identifier#>}}
}

func inExpr() {
  (::print())
// expected_error@-1 {{expected module name in module selector}}
// expected_new-note@-2 {{insert module name}} {{4-4=<#identifier#>}}
}

func inExpr() {
  *::print()
// expected_legacy-error@-1 {{expected module name in module selector}} expected_new-error@-1 {{unexpected code '*::print()' in function}}
}

func inExpr() {
  _::print()
// expected_error@-1 {{'_' cannot be used as an identifier here}}
// expected_legacy-note@-2 {{if this name is unavoidable, use backticks to escape it}} {{3-4=`_`}}
}

func inExpr() {
  Self::print()
// expected_error@-1 {{keyword 'Self' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{3-7=`Self`}}
}

func inExpr() {
  self::print()
// expected_error@-1 {{keyword 'self' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{3-7=`self`}}
}

func inExpr() {
  inout::print()
// expected_legacy-error@-1 {{expected expression}} expected_new-error@-1 {{expected pattern in variable}}
// expected_new-note@-2 {{insert pattern}} {{8-8=<#pattern#> }}
// expected_new-error@-3 {{expected '=' in variable}}
// expected_new-note@-4 {{insert '='}} {{8-8== }}
// expected_new-error@-5 {{expected module name in module selector}}
// expected_new-note@-6 {{insert module name}} {{8-8=<#identifier#>}}
}

func inExpr() {
  Any::print()
// expected_error@-1 {{keyword 'Any' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{3-6=`Any`}}
}

func inExpr() {
  _ = 1.::magnitude
// expected_error@-1 {{expected module name in module selector}}
// expected_new-note@-2 {{insert module name}} {{9-9=<#identifier#>}}
}

func inExpr() {
  _ = (1.::magnitude)
// expected_error@-1 {{expected module name in module selector}}
// expected_new-note@-2 {{insert module name}} {{10-10=<#identifier#>}}
}

// FIXME: This gets interpreted as a single `.*` operator; may not be ideal.
func inExpr() {
  _ = 1.*::magnitude
// expected_new-error@-1 {{consecutive statements on a line must be separated by newline or ';'}}
// expected_new-note@-2 {{insert newline}} {{10-10=\n  }}
// expected_new-note@-3 {{insert ';'}} {{10-10=;}}
// expected_error@-4 {{expected module name in module selector}}
// expected_new-note@-5 {{insert module name}} {{10-10=<#identifier#>}}
}

func inExpr() {
  _ = 1._::magnitude
// expected_error@-1 {{'_' cannot be used as an identifier here}}
// expected_legacy-note@-2 {{if this name is unavoidable, use backticks to escape it}} {{9-10=`_`}}
}

func inExpr() {
  _ = 1.Self::magnitude
// expected_error@-1 {{keyword 'Self' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{9-13=`Self`}}
}

func inExpr() {
  _ = 1.self::magnitude
// expected_error@-1 {{keyword 'self' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{9-13=`self`}}
}

func inExpr() {
  _ = 1.inout::magnitude
// expected_legacy-error@-1 {{consecutive statements on a line must be separated by ';'}} {{14-14=;}} expected_new-error@-1 {{consecutive statements on a line must be separated by newline or ';'}}
// expected_new-note@-2 {{insert newline}} {{14-14=\n  }}
// expected_new-note@-3 {{insert ';'}} {{14-14=;}}
// expected_error@-4 {{expected module name in module selector}}
// expected_new-note@-5 {{insert module name}} {{14-14=<#identifier#>}}
}

func inExpr() {
  _ = 1.Any::magnitude
// expected_error@-1 {{keyword 'Any' cannot be used as an identifier here}}
// expected_note@-2 {{if this name is unavoidable, use backticks to escape it}} {{9-12=`Any`}}
}


// ModuleSelectorAttrs
@_spi(main::Private)
// expected_legacy-error@-1 {{expected ')' in '_spi' attribute}} {{none}} FIXME: 'main::Private' should be diagnosed in ASTGen
// expected_legacy-error@-2 {{expected declaration}}
public struct BadImplementsAttr: CustomStringConvertible {}

@_implements(main::CustomStringConvertible, Swift::description)
// expected_legacy-error@-1 {{expected ')' in '_implements' attribute}} FIXME: 'Swift::description' should be diagnosed in ASTGen
// expected_legacy-note@-2 {{to match this opening '('}}
// expected_legacy-error@-3 {{expected declaration}}
public var stringValue: String { fatalError() }

@_specialize(target: main::fn(), spi: Swift::Private, where T == Swift::Int)
// expected_legacy-error@-1 {{missing ',' in '_specialize' attribute}} {{none}} FIXME: 'main::fn()' should be diagnosed in ASTGen
// expected_legacy-error@-2 {{missing ',' in '_specialize' attribute}} {{none}} expected_new-error@-2 {{unexpected code '::Private, where T == Swift::Int' in attribute}}
public func fn<T>() -> T { fatalError() }

func fn(_: @isolated(Swift::any) () -> Void) {} 
// expected_legacy-error@-1 {{expected 'any' as the isolation kind}} expected_new-error@-1 {{unexpected code '::any' in attribute}}
// expected_legacy-error@-2 {{expected ')' after isolation kind}} {{none}}
// expected_legacy-note@-3 {{to match this opening '('}}
// expected_legacy-error@-4 {{expected module name in module selector}}
// expected_legacy-error@-5 {{consecutive statements on a line must be separated by ';'}} {{44-44=;}}
// expected_legacy-error@-6 {{expected expression}}
// expected_legacy-error@-7 {{cannot have more than one parameter list}} FIXME: wat?

@_documentation(metadata: Swift::GroupName)
// expected_legacy-error@-1 {{expected ',' separator}} {{32-32=,}} expected_new-error@-1 {{unexpected code '::GroupName' in attribute}}
// expected_legacy-error@-2 {{'_documentation' attribute expected 'visibility' or 'metadata' argument}}
func fn() {}

@derivative(of: Swift::Foo.Swift::Bar.Swift::baz(), wrt: quux)
func fn() {}


// ModuleSelectorExpr
let x = Swift::do { 1 }

let x = Swift::
do { 1 }
// expected_legacy-error@-2 {{expected identifier after module selector}} expected_new-error@-2 {{expected identifier in variable}}
// expected_legacy-note@-3 {{remove extraneous whitespace after '::'}} {{16-+1:1=}} expected_new-note@-3 {{insert identifier}} {{16-16=<#identifier#>}}

let x = Swift::if y { 1 } else { 0 }
// expected_legacy-error@-1 {{consecutive statements on a line must be separated by ';'}} {{18-18=;}} expected_new-error@-1 {{consecutive statements on a line must be separated by newline or ';'}}
// expected_new-note@-2 {{insert newline}} {{18-19= \n}}
// expected_new-note@-3 {{insert ';'}} {{18-19=}} {{19-19=; }}
// expected_legacy-error@-4 {{consecutive statements on a line must be separated by ';'}} {{26-26=;}}
// expected_legacy-error@-5 {{expected expression}} expected_new-error@-5 {{unexpected code 'else { 0 }' in source file}}

let x = Swift::
if y { 1 } else { 0 }
// expected_legacy-error@-2 {{expected identifier after module selector}} expected_new-error@-2 {{expected identifier in variable}}
// expected_legacy-note@-3 {{remove extraneous whitespace after '::'}} {{16-+1:1=}} expected_new-note@-3 {{insert identifier}} {{16-16=<#identifier#>}}

let x = Swift::switch y {
// expected_legacy-error@-1 {{consecutive statements on a line must be separated by ';'}} {{22-22=;}} expected_new-error@-1 {{consecutive statements on a line must be separated by newline or ';'}}
// expected_new-note@-2 {{insert newline}} {{22-23= \n}}
// expected_new-note@-3 {{insert ';'}} {{22-23=}} {{23-23=; }}
// expected_legacy-error@-4 {{consecutive statements on a line must be separated by ';'}} {{24-24=;}} expected_new-error@-4 {{consecutive statements on a line must be separated by newline or ';'}}
// expected_new-note@-5 {{insert newline}} {{24-25= \n}}
// expected_new-note@-6 {{insert ';'}} {{24-25=}} {{25-25=; }}
  // expected_legacy-error@-7 {{top-level statement cannot begin with a closure expression}}
case true: 1
// expected_legacy-error@-1 {{'case' label can only appear inside a 'switch' statement}} expected_new-error@-1 {{'case' can only appear inside a 'switch' statement or 'enum' declaration}}
case false: 0
// expected_legacy-error@-1 {{'case' label can only appear inside a 'switch' statement}} expected_new-error@-1 {{'case' can only appear inside a 'switch' statement or 'enum' declaration}}
}

let x = Swift::
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in variable}}
// expected_legacy-note@-2 {{remove extraneous whitespace after '::'}} {{16-+3:1=}} expected_new-note@-2 {{insert identifier}} {{16-16=<#identifier#>}}
switch y {
case true: 1
case false: 0
}

fn(Swift::&x)
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in function call}}
// expected_new-note@-2 {{insert identifier}} {{11-11=<#identifier#>}}
// expected_legacy-error@-3 {{expected ',' separator}} expected_new-error@-3 {{unexpected code '&x' in function call}}

_ = Swift::\main::Foo.BarKit::bar
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}
// expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} {{12-12=;}}

_ = \main::Foo.BarKit::bar

_ = Swift::-x
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}
// expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} {{12-12=;}}

_ = Swift::1
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}
// expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} {{12-12=;}}

_ = Swift::1.0
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}
// expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} {{12-12=;}}

func fn() {
  _ = Swift::@"fnord"
  // expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier}}
  // expected_new-note@-2 {{insert identifier}} {{14-14=<#identifier#>}}
  // expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} {{14-14=;}}
  // expected_error@-4 {{string literals in Swift are not preceded by an '@' sign}}
  // expected_new-note@-5 {{remove '@'}} {{14-15=}}
}

_ = Swift::"fnord"
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}
// expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} {{12-12=;}}

_ = Swift::/fnord/
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}
// expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} {{12-12=;}}

_ = Swift::nil

_ = Swift::true

_ = Swift::identifier

_ = Swift::self

func fn() {
  // FIXME: ASTGen might be doing something weird here
  _ = Swift::init
}

@attached(extension, names: Swift::deinit) macro m()
// expected_legacy-error@-1 {{unknown introduced name kind 'Swift'}} FIXME: 'Swift::' should be diagnosed by ASTGen
// expected_legacy-error@-2 {{expected '{' for deinitializer}}

@attached(extension, names: Swift::subscript) macro m()
// expected_legacy-error@-1 {{unknown introduced name kind 'Swift'}} FIXME: 'Swift::' should be diagnosed by ASTGen
// expected_legacy-error@-2 {{expected '(' for subscript parameters}}

_ = Swift::Self

_ = Swift::Any

_ = {
  _ = Swift::$0
  // expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier}}
  // expected_new-note@-2 {{insert identifier}} {{14-14=<#identifier#>}}
  // expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}} {{14-14=;}}
}

_ = Swift::$foo

//  FIXME: Legacy parser considers `_` a keyword; new parser probably should too
_ = Swift::_
// expected_new-error@-1 {{expected identifier}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}

Swift::_ = 1
// expected_new-error@-1 {{expected identifier}}
// expected_new-note@-2 {{insert identifier}} {{8-8=<#identifier#>}}

_ = Swift::#foo
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}
// expected_legacy-error@-3 {{consecutive statements on a line must be separated by ';'}}

_ = #Swift::foo

_ = Swift::{ 1 }
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in function call}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#> }}

_ = Swift::.random()
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in member access}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}

_ = Swift::.main::random()
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in member access}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}

_ = .main::random()

_ = Swift::super.foo()

_ = Swift::(a, b)
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in function call}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}

_ = Swift::[a, b]
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in subscript}}
// expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}

_ = Swift::
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier}}
// expected_legacy-note@-2 {{remove extraneous whitespace after '::'}} {{12-+4:1=}} expected_new-note@-2 {{insert identifier}} {{12-12=<#identifier#>}}

_ = x.Swift::y

_ = x.Swift::1
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in member access}}
// expected_new-note@-2 {{insert identifier}} {{14-14=<#identifier#>}}

_ = x.Swift::self

_ = x.Swift::Self.self

_ = x.Swift::Type.self

_ = x.Swift::Protocol.self

_ = myArray.reduce(0, Swift::+)

if Swift::#available(macOS 15, *) {}
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in 'if' statement}}
// expected_new-note@-2 {{insert identifier}} {{11-11=<#identifier#> }}
// expected_legacy-error@-3 {{expected '{' after 'if' condition}} expected_new-error@-3 {{unexpected code '#available(macOS 15, *)' in 'if' statement}}

func fn(_: Swift::Self) {}

func fn(_: Swift::Any) {}

func fn(_: Swift::Foo) {}

func fn(_: Swift::(Int, String)) {}
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in type}}
// expected_new-note@-2 {{insert identifier}} {{19-19=<#identifier#>}}
// expected_new-error@-3 {{unexpected code '(Int, String)' in parameter clause}}

func fn(_: Swift::[Int]) {}
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in type}}
// expected_new-note@-2 {{insert identifier}} {{19-19=<#identifier#>}}
// expected_new-error@-3 {{unexpected code '[Int]' in parameter clause}}

//  FIXME: Legacy parser considers `_` a keyword; new parser probably should too
func fn(_: Swift::_) {}
// expected_new-error@-1 {{expected identifier in type}}
// expected_new-note@-2 {{insert identifier}} {{19-19=<#identifier#>}}
// expected_new-error@-3 {{unexpected code '_' in parameter clause}}

func fn(_: Swift::) {}
// expected_legacy-error@-1 {{expected identifier after module selector}} expected_new-error@-1 {{expected identifier in type}}
// expected_new-note@-2 {{insert identifier}} {{19-19=<#identifier#>}}

func fn(_: Foo.Swift::Type) {}

func fn(_: Foo.Swift::Protocol) {}

func fn(_: Foo.Swift::Bar) {}

func fn(_: Foo.Swift::self) {}


// ModuleSelectorSubmodule

_ = Foundation::NSData::NSData()
// expected_legacy-error@-1 {{module selector cannot specify a submodule}} {{17-25=}} expected_new-error@-1 {{unexpected code 'NSData::' in module selector}}

_ = Foundation::NSData::Fnord::NSData()
// expected_legacy-error@-1 {{module selector cannot specify a submodule}} {{17-32=}} expected_new-error@-1 {{unexpected code 'NSData::Fnord::' in module selector}}

_ = Foundation::NSData::
Fnord::NSData()
// expected_legacy-error@-2 {{module selector cannot specify a submodule}} {{17-25=}} expected_new-error@-2 {{unexpected code 'NSData::' in module selector}}
// expected_legacy-error@-3 {{expected identifier after module selector}} expected_new-error@-3 {{expected identifier}}
// expected_legacy-note@-4 {{remove extraneous whitespace after '::'}} {{25-+1:1=}} expected_new-note@-4 {{insert identifier}} {{25-25=<#identifier#>}}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/module_selector.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module -module-name main %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@14:15 {{}} // keyword_cant_be_identifier
// expected-note@14:15 {{}} // backticks_to_escape
// expected-error@18:41 {{}} // module_selector_submodule_not_allowed
// expected-error@21:49 {{}} // module_selector_submodule_not_allowed
// expected-note@21:49 {{}} // replace_module_selector_with_member_lookup
// expected-error@25:14 {{}} // module_selector_submodule_not_allowed
// expected-note@25:14 {{}} // replace_module_selector_with_member_lookup
// expected-error@66:26 {{}} // expected_separator
// expected-error@79:24 {{}} // expected_separator
// expected-error@92:12 {{}} // expected_identifier_after_module_selector
// expected-note@92:12 {{}} // extra_whitespace_module_selector
// expected-error@100:13 {{}} // expected_identifier_after_module_selector
// expected-note@100:13 {{}} // extra_whitespace_module_selector
// expected-error@109:3 {{}} // expected_identifier_after_module_selector
// expected-note@109:3 {{}} // extra_whitespace_module_selector
// expected-error@116:10 3 {{}} // expected_identifier_in_module_selector,func_decl_without_paren,statement_same_line_without_semi
// expected-error@121:12 {{}} // expected_parameter_name
// expected-error@127:12 {{}} // expected_parameter_name
// expected-error@134:12 {{}} // expected_parameter_name
// expected-error@141:12 {{}} // expected_parameter_name
// expected-error@151:13 3 {{}} // expected_parameter_colon,expected_parameter_name,expected_separator
// expected-error@159:11 2 {{}} // expected_identifier_in_module_selector,statement_same_line_without_semi
// expected-error@166:7 {{}} // var_pattern_in_var
// expected-error@166:10 {{}} // expected_pattern
// expected-error@174:11 2 {{}} // expected_identifier_in_module_selector,statement_same_line_without_semi
// expected-error@180:12 2 {{}} // expected_pattern,expected_separator
// expected-error@184:15 2 {{}} // expected_identifier_in_module_selector,expected_separator
// expected-error@188:18 2 {{}} // expected_identifier_in_module_selector,expected_separator
// expected-error@193:31 2 {{}} // expected_identifier_in_module_selector,expected_separator
// expected-error@202:31 2 {{}} // expected_identifier_in_module_selector,expected_separator
// expected-error@211:17 2 {{}} // expected_case_colon,expected_identifier_in_module_selector
// expected-error@211:26 2 {{}} // expected_expr,statement_same_line_without_semi
// expected-error@221:11 2 {{}} // expected_foreach_in,expected_identifier_in_module_selector
// expected-error@221:20 {{}} // expected_foreach_lbrace
// expected-error@231:13 {{}} // statement_same_line_without_semi
// expected-error@231:14 {{}} // expected_expr
// expected-error@236:22 2 {{}} // expected_parameter_name,expected_separator
// expected-error@240:22 2 {{}} // expected_parameter_name,expected_separator
// expected-error@244:22 2 {{}} // expected_parameter_name,expected_separator
// expected-error@250:10 {{}} // expected_lbrace_enum
// expected-note@252:6 {{}} // note_in_decl_of
// expected-error@254:13 2 {{}} // declaration_same_line_without_semi,expected_decl
// expected-error@259:12 {{}} // expected_lbrace_struct
// expected-error@262:11 {{}} // expected_lbrace_class
// expected-error@265:15 {{}} // expected_equal_in_typealias
// expected-error@268:14 {{}} // expected_lbrace_protocol
// expected-note@270:10 {{}} // note_in_decl_of
// expected-error@272:23 2 {{}} // declaration_same_line_without_semi,expected_decl
// expected-error@279:9 2 {{}} // expected_identifier_in_module_selector,statement_same_line_without_semi
// expected-error@285:9 2 {{}} // expected_identifier_in_module_selector,statement_same_line_without_semi
// expected-error@285:20 {{}} // statement_same_line_without_semi
// expected-error@285:21 {{}} // statement_begins_with_closure
// expected-note@299:10 {{}} // opening_paren
// expected-error@299:16 2 {{}} // expected_lbrace_accessor,expected_rparen_willSet_name
// expected-note@309:9 {{}} // opening_paren
// expected-error@309:13 2 {{}} // expected_lbrace_accessor,expected_rparen_didSet_name
// expected-note@317:8 {{}} // note_in_decl_of
// expected-error@320:12 3 {{}} // declaration_same_line_without_semi,expected_decl,func_decl_without_paren
// expected-error@325:12 {{}} // expected_lbrace_enum
// expected-note@328:8 {{}} // note_in_decl_of
// expected-error@330:15 2 {{}} // declaration_same_line_without_semi,expected_decl
// expected-error@335:14 {{}} // expected_lbrace_struct
// expected-error@338:13 {{}} // expected_lbrace_class
// expected-error@341:17 {{}} // expected_equal_in_typealias
// expected-error@353:2 {{}} // attr_expected_rparen
// expected-error@353:38 {{}} // expected_decl
// expected-error@360:29 2 {{}} // expected_identifier_in_module_selector,statement_same_line_without_semi
// expected-error@367:21 {{}} // expected_precedencegroup_lbrace
// expected-error@370:20 {{}} // expected_precedencegroup_attribute
// expected-error@376:8 {{}} // expected_identifier_in_module_selector
// expected-error@380:9 {{}} // expected_identifier_in_module_selector
// expected-error@384:7 {{}} // statement_same_line_without_semi
// expected-error@384:8 {{}} // expected_type
// expected-error@384:9 {{}} // expected_identifier_in_module_selector
// expected-error@390:8 {{}} // keyword_cant_be_identifier
// expected-note@390:8 {{}} // backticks_to_escape
// expected-error@394:8 {{}} // keyword_cant_be_identifier
// expected-note@394:8 {{}} // backticks_to_escape
// expected-error@398:8 {{}} // keyword_cant_be_identifier
// expected-note@398:8 {{}} // backticks_to_escape
// expected-error@402:13 {{}} // expected_identifier_in_module_selector
// expected-error@412:8 {{}} // keyword_cant_be_identifier
// expected-note@412:8 {{}} // backticks_to_escape
// expected-error@416:14 {{}} // expected_identifier_in_module_selector
// expected-error@420:15 {{}} // expected_identifier_in_module_selector
// expected-note@424:13 {{}} // opening_bracket
// expected-error@424:14 3 {{}} // expected_element_type,expected_rbracket_array_type,statement_same_line_without_semi
// expected-error@424:15 {{}} // expected_identifier_in_module_selector
// expected-error@424:20 2 {{}} // expected_expr,statement_same_line_without_semi
// expected-error@434:14 {{}} // keyword_cant_be_identifier
// expected-note@434:14 {{}} // backticks_to_escape
// expected-error@438:14 {{}} // keyword_cant_be_identifier
// expected-note@438:14 {{}} // backticks_to_escape
// expected-error@442:14 {{}} // keyword_cant_be_identifier
// expected-note@442:14 {{}} // backticks_to_escape
// expected-error@446:19 {{}} // expected_identifier_in_module_selector
// expected-error@457:14 {{}} // keyword_cant_be_identifier
// expected-note@457:14 {{}} // backticks_to_escape
// expected-error@461:20 {{}} // expected_identifier_in_module_selector
// expected-error@466:19 2 {{}} // expected_expr_after_unary_operator,statement_same_line_without_semi
// expected-error@466:21 {{}} // expected_identifier_in_module_selector
// expected-error@471:20 {{}} // keyword_cant_be_identifier
// expected-note@471:20 {{}} // backticks_to_escape
// expected-error@475:20 {{}} // keyword_cant_be_identifier
// expected-note@475:20 {{}} // backticks_to_escape
// expected-error@479:20 {{}} // keyword_cant_be_identifier
// expected-note@479:20 {{}} // backticks_to_escape
// expected-error@483:20 3 {{}} // expected_expr,expected_identifier_in_dotted_type,statement_same_line_without_semi
// expected-error@490:20 {{}} // keyword_cant_be_identifier
// expected-note@490:20 {{}} // backticks_to_escape
// expected-error@495:3 {{}} // expected_identifier_in_module_selector
// expected-error@501:4 {{}} // expected_identifier_in_module_selector
// expected-error@507:4 {{}} // expected_identifier_in_module_selector
// expected-error@512:3 {{}} // keyword_cant_be_identifier
// expected-note@512:3 {{}} // backticks_to_escape
// expected-error@518:3 {{}} // keyword_cant_be_identifier
// expected-note@518:3 {{}} // backticks_to_escape
// expected-error@524:3 {{}} // keyword_cant_be_identifier
// expected-note@524:3 {{}} // backticks_to_escape
// expected-error@530:3 {{}} // expected_expr
// expected-error@540:3 {{}} // keyword_cant_be_identifier
// expected-note@540:3 {{}} // backticks_to_escape
// expected-error@546:9 {{}} // expected_identifier_in_module_selector
// expected-error@552:10 {{}} // expected_identifier_in_module_selector
// expected-error@559:10 {{}} // expected_identifier_in_module_selector
// expected-error@568:9 {{}} // keyword_cant_be_identifier
// expected-note@568:9 {{}} // backticks_to_escape
// expected-error@574:9 {{}} // keyword_cant_be_identifier
// expected-note@574:9 {{}} // backticks_to_escape
// expected-error@580:9 {{}} // keyword_cant_be_identifier
// expected-note@580:9 {{}} // backticks_to_escape
// expected-error@586:14 2 {{}} // expected_identifier_in_module_selector,statement_same_line_without_semi
// expected-error@595:9 {{}} // keyword_cant_be_identifier
// expected-note@595:9 {{}} // backticks_to_escape
// expected-error@602:2 {{}} // attr_expected_rparen
// expected-error@602:11 {{}} // expected_decl
// expected-note@607:13 {{}} // opening_paren
// expected-error@607:50 2 {{}} // attr_expected_rparen,expected_decl
// expected-error@613:26 {{}} // attr_specialize_missing_comma
// expected-error@613:44 {{}} // attr_specialize_missing_comma
// expected-error@618:8 {{}} // parameter_curry_syntax_removed
// expected-note@618:21 {{}} // opening_paren
// expected-error@618:22 {{}} // attr_isolated_expected_kind
// expected-error@618:27 2 {{}} // attr_isolated_expected_rparen,expected_identifier_in_module_selector
// expected-error@618:44 2 {{}} // expected_expr,statement_same_line_without_semi
// expected-error@627:32 2 {{}} // documentation_attr_expected_argument,expected_separator
// expected-error@639:16 {{}} // expected_identifier_after_module_selector
// expected-note@639:16 {{}} // extra_whitespace_module_selector
// expected-error@644:18 {{}} // statement_same_line_without_semi
// expected-error@644:26 {{}} // statement_same_line_without_semi
// expected-error@644:27 {{}} // expected_expr
// expected-error@651:16 {{}} // expected_identifier_after_module_selector
// expected-note@651:16 {{}} // extra_whitespace_module_selector
// expected-error@656:22 {{}} // statement_same_line_without_semi
// expected-error@656:24 {{}} // statement_same_line_without_semi
// expected-error@656:25 {{}} // statement_begins_with_closure
// expected-error@664:1 {{}} // case_outside_of_switch
// expected-error@666:1 {{}} // case_outside_of_switch
// expected-error@670:16 {{}} // expected_identifier_after_module_selector
// expected-note@670:16 {{}} // extra_whitespace_module_selector
// expected-error@678:11 2 {{}} // expected_identifier_after_module_selector,expected_separator
// expected-error@683:12 2 {{}} // expected_identifier_after_module_selector,statement_same_line_without_semi
// expected-error@690:12 2 {{}} // expected_identifier_after_module_selector,statement_same_line_without_semi
// expected-error@695:12 2 {{}} // expected_identifier_after_module_selector,statement_same_line_without_semi
// expected-error@700:12 2 {{}} // expected_identifier_after_module_selector,statement_same_line_without_semi
// expected-error@706:14 3 {{}} // expected_identifier_after_module_selector,statement_same_line_without_semi,string_literal_no_atsign
// expected-error@714:12 2 {{}} // expected_identifier_after_module_selector,statement_same_line_without_semi
// expected-error@719:12 2 {{}} // expected_identifier_after_module_selector,statement_same_line_without_semi
// expected-error@737:29 {{}} // macro_attribute_unknown_name_kind
// expected-error@737:42 {{}} // expected_lbrace_destructor
// expected-error@741:29 {{}} // macro_attribute_unknown_name_kind
// expected-error@741:45 {{}} // expected_lparen_subscript
// expected-error@750:14 2 {{}} // expected_identifier_after_module_selector,statement_same_line_without_semi
// expected-error@767:12 2 {{}} // expected_identifier_after_module_selector,statement_same_line_without_semi
// expected-error@774:12 {{}} // expected_identifier_after_module_selector
// expected-error@778:12 {{}} // expected_identifier_after_module_selector
// expected-error@782:12 {{}} // expected_identifier_after_module_selector
// expected-error@790:12 {{}} // expected_identifier_after_module_selector
// expected-error@794:12 {{}} // expected_identifier_after_module_selector
// expected-error@798:12 {{}} // expected_identifier_after_module_selector
// expected-note@798:12 {{}} // extra_whitespace_module_selector
// expected-error@804:14 {{}} // expected_identifier_after_module_selector
// expected-error@818:11 2 {{}} // expected_identifier_after_module_selector,expected_lbrace_after_if
// expected-error@829:19 {{}} // expected_identifier_after_module_selector
// expected-error@834:19 {{}} // expected_identifier_after_module_selector
// expected-error@845:19 {{}} // expected_identifier_after_module_selector
// expected-error@860:17 {{}} // module_selector_submodule_not_allowed
// expected-error@863:17 {{}} // module_selector_submodule_not_allowed
// expected-error@866:17 {{}} // module_selector_submodule_not_allowed
// expected-error@866:25 {{}} // expected_identifier_after_module_selector
// expected-note@866:25 {{}} // extra_whitespace_module_selector
// ---- end ASTGen parity ----
