// RUN; %target-typecheck-verify-swift -verify-ignore-unrelated

//===--- Helper types used in this file.

protocol FooProtocol {}

//===--- Tests.

func garbage() -> () {
  var a : Int
  ) this line is invalid, but we will stop at the keyword below... // expected_error{{expected expression}}
  return a + "a" // expected_error{{binary operator '+' cannot be applied to operands of type 'Int' and 'String'}} expected_note {{overloads for '+' exist with these partially matching parameter lists: (Int, Int), (String, String)}}
  // expected_error@-1 {{no '+' candidates produce the expected contextual result type '()'}}
}

func moreGarbage() -> () {
  ) this line is invalid, but we will stop at the declaration... // expected_error{{expected expression}}
  func a() -> Int { return 4 }
  return a() + "a" // expected_error{{binary operator '+' cannot be applied to operands of type 'Int' and 'String'}} expected_note {{overloads for '+' exist with these partially matching parameter lists: (Int, Int), (String, String)}}
  // expected_error@-1 {{no '+' candidates produce the expected contextual result type '()'}}
}


class Container<T> {
  func exists() -> Bool { return true }
}

func useContainer() -> () {
  var a : Container<not a type [skip this greater: >] >, b : Int // expected_error{{expected '>' to complete generic argument list}} expected_note{{to match this opening '<'}}
  b = 5 // no-warning
  a.exists()
}

@xyz class BadAttributes { // expected_error{{unknown attribute 'xyz'}}
  func exists() -> Bool { return true }
}

// expected_note @+2 {{did you mean 'test'?}}
// expected_note @+1 {{'test' declared here}}
func test(a: BadAttributes) -> () {
  _ = a.exists() // no-warning
}

// Here is an extra random close-brace!
} // expected_error{{extraneous '}' at top level}} {{1-3=}}


//===--- Recovery for braced blocks.

func braceStmt1() {
  { braceStmt1(); } // expected_error {{closure expression is unused}} expected_note {{did you mean to use a 'do' statement?}} {{3-3=do }}
}

func braceStmt2() {
  { () in braceStmt2(); } // expected_error {{closure expression is unused}}
}

func braceStmt3() {
  {  // expected_error {{closure expression is unused}} expected_note {{did you mean to use a 'do' statement?}} {{3-3=do }}
    undefinedIdentifier {} // expected_error {{cannot find 'undefinedIdentifier' in scope}}
  }
}

//===--- Recovery for misplaced 'static'.

static func toplevelStaticFunc() {} // expected_error {{static methods may only be declared on a type}} {{1-8=}}

static struct StaticStruct {} // expected_error {{declaration cannot be marked 'static'}} {{1-8=}}
static class StaticClass {} // expected_error {{declaration cannot be marked 'static'}} {{1-8=}}
static protocol StaticProtocol {} // expected_error {{declaration cannot be marked 'static'}} {{1-8=}}
static typealias StaticTypealias = Int // expected_error {{declaration cannot be marked 'static'}} {{1-8=}}

class ClassWithStaticDecls {
  class var a = 42 // expected_error {{class stored properties not supported}}
}

//===--- Recovery for missing controlling expression in statements.

func missingControllingExprInIf() {
  if

  if { // expected_error {{missing condition in 'if' statement}}
  } // expected_error {{expected '{' after 'if' condition}}
  // expected_error@-2 {{cannot convert value of type 'Void' to expected condition type 'Bool'}}
  // expected_error@-3 {{'if' may only be used as expression in return, throw, or as the source of an assignment}}
  // expected_error@-4 {{'if' must have an unconditional 'else' to be used as expression}}

  if // expected_error {{missing condition in 'if' statement}}
  {
  }

  if true {
  } else if { // expected_error {{missing condition in 'if' statement}}
  }

  // It is debatable if we should do recovery here and parse { true } as the
  // body, but the error message should be sensible.
  if { true } { // expected_error {{missing condition in 'if' statement}} expected_error{{consecutive statements on a line must be separated by ';'}} {{14-14=;}} expected_error {{closure expression is unused}} expected_note {{did you mean to use a 'do' statement?}} {{15-15=do }} expected_warning {{boolean literal is unused}}
  }

  if { true }() { // expected_error {{missing condition in 'if' statement}} expected_error 2 {{consecutive statements on a line must be separated by ';'}} expected_error {{closure expression is unused}} expected_note {{did you mean to use a 'do' statement?}} {{17-17=do }} expected_warning {{boolean literal is unused}}
  }

  // <rdar://problem/18940198>
  if { { } } // expected_error{{missing condition in 'if' statement}} expected_error{{closure expression is unused}} expected_note {{did you mean to use a 'do' statement?}} {{8-8=do }}
}

func missingControllingExprInWhile() {
  while // expected_error {{expected expression, var, or let in 'while' condition}}

  while { // expected_error {{missing condition in 'while' statement}}
  }

  while // expected_error {{missing condition in 'while' statement}}
  {
  }

  // It is debatable if we should do recovery here and parse { true } as the
  // body, but the error message should be sensible.
  while { true } { // expected_error {{missing condition in 'while' statement}} expected_error{{consecutive statements on a line must be separated by ';'}} {{17-17=;}} expected_error {{closure expression is unused}} expected_note {{did you mean to use a 'do' statement?}} {{18-18=do }} expected_warning {{boolean literal is unused}}
  }

  while { true }() { // expected_error {{missing condition in 'while' statement}} expected_error 2 {{consecutive statements on a line must be separated by ';'}} expected_error {{closure expression is unused}} expected_note {{did you mean to use a 'do' statement?}} {{20-20=do }} expected_warning {{boolean literal is unused}}
  }

  // <rdar://problem/18940198>
  while { { } } // expected_error{{missing condition in 'while' statement}} expected_error{{closure expression is unused}} expected_note {{did you mean to use a 'do' statement?}} {{11-11=do }}
}

func missingControllingExprInRepeatWhile() {
  repeat {
  } while // expected_error {{missing condition in 'while' statement}}
  { // expected_error{{closure expression is unused}} expected_note {{did you mean to use a 'do' statement?}} {{3-3=do }}
    missingControllingExprInRepeatWhile();
  }

  repeat {
  } while { true }() // expected_error{{missing condition in 'while' statement}} expected_error{{consecutive statements on a line must be separated by ';'}} {{10-10=;}} expected_warning {{result of call to closure returning 'Bool' is unused}}
}

// https://github.com/apple/swift/issues/42787
func missingWhileInRepeat() {
  repeat {
  } // expected_error {{expected 'while' after body of 'repeat' statement}}
}

func acceptsClosure<T>(t: T) -> Bool { return true }

func missingControllingExprInFor() {
  for ; { // expected_error {{C-style for statement was removed in Swift 3}}
  }

  for ; // expected_error {{C-style for statement was removed in Swift 3}}
  { 
  }

  for ; true { // expected_error {{C-style for statement was removed in Swift 3}}
  }

  for var i = 0; true { // expected_error {{C-style for statement was removed in Swift 3}}
    i += 1
  }
}

func missingControllingExprInForEach() {
  // expected_error @+3 {{expected pattern}}
  // expected_error @+2 {{expected Sequence expression for for-each loop}}
  // expected_error @+1 {{expected '{' to start the body of for-each loop}}
  for

  // expected_error @+2 {{expected pattern}}
  // expected_error @+1 {{expected Sequence expression for for-each loop}}
  for {
  }

  // expected_error @+2 {{expected pattern}}
  // expected_error @+1 {{expected Sequence expression for for-each loop}}
  for
  {
  }

  // expected_error @+2 {{expected 'in' after for-each pattern}}
  // expected_error @+1 {{expected Sequence expression for for-each loop}}
  for i {
  }

  // expected_error @+2 {{expected 'in' after for-each pattern}}
  // expected_error @+1 {{expected Sequence expression for for-each loop}}
  for var i {
  }

  // expected_error @+2 {{expected pattern}}
  // expected_error @+1 {{expected Sequence expression for for-each loop}}
  for in {
  }

  // expected_error @+1 {{expected pattern}}
  for 0..<12 {
  }

  // expected_error @+3 {{expected pattern}}
  // expected_error @+2 {{expected Sequence expression for for-each loop}}
  // expected_error @+1 {{expected '{' to start the body of for-each loop}}
  for for in {
  }

  for i in { // expected_error {{expected Sequence expression for for-each loop}}
  }

// The #if block is used to provide a scope for the for stmt to force it to end
// where necessary to provoke the crash.
#if true  // <rdar://problem/21679557> compiler crashes on "for{{"
  // expected_error @+4 {{expected pattern}}
  // expected_error @+3 {{expected Sequence expression for for-each loop}}
  // expected_error @+2 {{closure expression is unused}}
  // expected_note @+1 {{did you mean to use a 'do' statement?}}
  for{{ // expected_note 2 {{to match this opening '{'}}
#endif  // expected_error {{expected '}' at end of closure}} expected_error {{expected '}' at end of brace statement}}

#if true
  // expected_error @+2 {{expected pattern}}
  // expected_error @+1 {{expected Sequence expression for for-each loop}}
  for{
    var x = 42
  }
#endif
  
  // https://github.com/apple/swift/issues/48502
  struct User { let name: String? }
  let users = [User]()
  for user in users whe { // expected_error {{expected '{' to start the body of for-each loop}}
    if let name = user.name {
      let key = "\(name)"
    }
  }

  for // expected_error {{expected pattern}} expected_error {{Sequence expression for for-each loop}}
  ; // expected_error {{expected '{' to start the body of for-each loop}}
}

func missingControllingExprInSwitch() {
  switch

  switch { // expected_error {{expected expression in 'switch' statement}}
  } // expected_error {{expected '{' after 'switch' subject expression}}
  // expected_error@-2 {{'switch' may only be used as expression in return, throw, or as the source of an assignment}}

  switch // expected_error {{expected expression in 'switch' statement}} expected_error {{'switch' statement body must have at least one 'case' or 'default' block}}
  {
  }

  switch { // expected_error {{expected expression in 'switch' statement}}
    case _: return
  }

  switch { // expected_error {{expected expression in 'switch' statement}}
    case Int: return // expected_error {{'is' keyword required to pattern match against type name}} {{10-10=is }} 
    case _: return
  }

  switch { 42 } { // expected_error {{expected expression in 'switch' statement}} expected_error{{all statements inside a switch must be covered by a 'case' or 'default'}} expected_error{{consecutive statements on a line must be separated by ';'}} {{16-16=;}} expected_error{{closure expression is unused}} expected_note{{did you mean to use a 'do' statement?}} {{17-17=do }} // expected_error{{'switch' statement body must have at least one 'case' or 'default' block}}
    case _: return // expected_error{{'case' label can only appear inside a 'switch' statement}}
  }

  switch { 42 }() { // expected_error {{expected expression in 'switch' statement}} expected_error {{all statements inside a switch must be covered by a 'case' or 'default'}} expected_error 2 {{consecutive statements on a line must be separated by ';'}} expected_error{{closure expression is unused}} expected_note{{did you mean to use a 'do' statement?}} {{19-19=do }} // expected_error{{'switch' statement body must have at least one 'case' or 'default' block}}
    case _: return // expected_error{{'case' label can only appear inside a 'switch' statement}}
  }
}

//===--- Recovery for missing braces in nominal type decls.

struct NoBracesStruct1() // expected_error {{expected '{' in struct}}
enum NoBracesUnion1() // expected_error {{expected '{' in enum}}
class NoBracesClass1() // expected_error {{expected '{' in class}}
protocol NoBracesProtocol1() // expected_error {{expected '{' in protocol type}}
extension NoBracesStruct1() // expected_error {{expected '{' in extension}}

struct NoBracesStruct2 // expected_error {{expected '{' in struct}}
enum NoBracesUnion2 // expected_error {{expected '{' in enum}}
class NoBracesClass2 // expected_error {{expected '{' in class}}
protocol NoBracesProtocol2 // expected_error {{expected '{' in protocol type}}
extension NoBracesStruct2 // expected_error {{expected '{' in extension}}

//===--- Recovery for multiple identifiers in decls

protocol Multi ident {}
// expected_error @-1 {{found an unexpected second identifier in protocol declaration; is there an accidental break?}}
// expected_note @-2 {{join the identifiers together}} {{10-21=Multiident}}
// expected_note @-3 {{join the identifiers together with camel-case}} {{10-21=MultiIdent}}

class CCC CCC<T> {}
// expected_error @-1 {{found an unexpected second identifier in class declaration; is there an accidental break?}}
// expected_note @-2 {{join the identifiers together}} {{7-14=CCCCCC}}

enum EE EE<T> where T : Multi {
// expected_error @-1 {{found an unexpected second identifier in enum declaration; is there an accidental break?}} 
// expected_note @-2 {{join the identifiers together}} {{6-11=EEEE}}
  
  case a a
  // expected_error @-1 {{found an unexpected second identifier in enum 'case' declaration; is there an accidental break?}} 
  // expected_note @-2 {{join the identifiers together}} {{8-11=aa}}
  // expected_note @-3 {{join the identifiers together with camel-case}} {{8-11=aA}}
  
  case b
}

struct SS SS : Multi {
// expected_error @-1 {{found an unexpected second identifier in struct declaration; is there an accidental break?}}
// expected_note @-2 {{join the identifiers together}} {{8-13=SSSS}}
  
  private var a b : Int = ""
  // expected_error @-1 {{found an unexpected second identifier in variable declaration; is there an accidental break?}}
  // expected_note @-2 {{join the identifiers together}} {{15-18=ab}}
  // expected_note @-3 {{join the identifiers together with camel-case}} {{15-18=aB}}
  // expected_error @-4 {{cannot convert value of type 'String' to specified type 'Int'}}
  
  func f() {
    var c d = 5
    // expected_error @-1 {{found an unexpected second identifier in variable declaration; is there an accidental break?}}
    // expected_note @-2 {{join the identifiers together}} {{9-12=cd}}
    // expected_note @-3 {{join the identifiers together with camel-case}} {{9-12=cD}}
    // expected_warning @-4 {{initialization of variable 'c' was never used; consider replacing with assignment to '_' or removing it}}
    
    let _ = 0
  }
}

let (efg hij, foobar) = (5, 6)
// expected_error @-1 {{found an unexpected second identifier in constant declaration; is there an accidental break?}}
// expected_note @-2 {{join the identifiers together}} {{6-13=efghij}}
// expected_note @-3 {{join the identifiers together with camel-case}} {{6-13=efgHij}}

_ = foobar // OK.


//===--- Recovery for parse errors in types.

struct ErrorTypeInVarDecl1 {
  var v1 : // expected_error {{expected type}} {{11-11= <#type#>}}
}

struct ErrorTypeInVarDecl2 {
  var v1 : Int. // expected_error {{expected member name following '.'}}
  var v2 : Int
}

struct ErrorTypeInVarDecl3 {
  var v1 : Int< // expected_error {{expected type}}
  var v2 : Int
}

struct ErrorTypeInVarDecl4 {
  var v1 : Int<, // expected_error {{expected type}} {{16-16= <#type#>}}
  var v2 : Int
}

struct ErrorTypeInVarDecl5 {
  var v1 : Int<Int // expected_error {{expected '>' to complete generic argument list}} expected_note {{to match this opening '<'}}
  var v2 : Int
}

struct ErrorTypeInVarDecl6 {
  var v1 : Int<Int, // expected_note {{to match this opening '<'}}
               Int // expected_error {{expected '>' to complete generic argument list}}
  var v2 : Int
}


struct ErrorTypeInVarDecl7 {
  var v1 : Int<Int, // expected_error {{expected type}}
  var v2 : Int
}

struct ErrorTypeInVarDecl8 {
  var v1 : protocol<FooProtocol // expected_error {{expected '>' to complete protocol-constrained type}} expected_note {{to match this opening '<'}}
  var v2 : Int
}

struct ErrorTypeInVarDecl9 {
  var v1 : protocol // expected_error {{expected type}}
  var v2 : Int
}

struct ErrorTypeInVarDecl10 {
  var v1 : protocol<FooProtocol // expected_error {{expected '>' to complete protocol-constrained type}} expected_note {{to match this opening '<'}}
  var v2 : Int
}

struct ErrorTypeInVarDecl11 {
  var v1 : protocol<FooProtocol, // expected_error {{expected type}}
  var v2 : Int
}

func ErrorTypeInPattern1(_: protocol<) { } // expected_error {{expected type}}
func ErrorTypeInPattern2(_: protocol<F) { } // expected_error {{expected '>' to complete protocol-constrained type}}
                                            // expected_note@-1 {{to match this opening '<'}}
                                            // expected_error@-2 {{cannot find type 'F' in scope}}

func ErrorTypeInPattern3(_: protocol<F,) { } // expected_error {{expected type}}
                                             // expected_error@-1 {{cannot find type 'F' in scope}}

struct ErrorTypeInVarDecl12 {
  var v1 : FooProtocol & // expected_error{{expected identifier for type name}}
  var v2 : Int
}

struct ErrorTypeInVarDecl13 { // expected_note {{in declaration of 'ErrorTypeInVarDecl13'}}
  var v1 : & FooProtocol // expected_error {{expected type}} expected_error {{consecutive declarations on a line must be separated by ';'}} expected_error{{expected declaration}} 
  var v2 : Int
}

struct ErrorTypeInVarDecl16 {
  var v1 : FooProtocol & // expected_error {{expected identifier for type name}}
  var v2 : Int
}

func ErrorTypeInPattern4(_: FooProtocol & ) { } // expected_error {{expected identifier for type name}}


struct ErrorGenericParameterList1< // expected_error {{expected an identifier to name generic parameter}} expected_error {{expected '{' in struct}}

struct ErrorGenericParameterList2<T // expected_error {{expected '>' to complete generic parameter list}} expected_note {{to match this opening '<'}} expected_error {{expected '{' in struct}}

struct ErrorGenericParameterList3<T, // expected_error {{expected an identifier to name generic parameter}} expected_error {{expected '{' in struct}}

// Note: Don't move braces to a different line here.
struct ErrorGenericParameterList4< // expected_error {{expected an identifier to name generic parameter}}
{
}

// Note: Don't move braces to a different line here.
struct ErrorGenericParameterList5<T // expected_error {{expected '>' to complete generic parameter list}} expected_note {{to match this opening '<'}}
{
}

// Note: Don't move braces to a different line here.
struct ErrorGenericParameterList6<T, // expected_error {{expected an identifier to name generic parameter}}
{
}

struct ErrorTypeInVarDeclFunctionType1 {
  var v1 : () -> // expected_error {{expected type for function result}}
  var v2 : Int
}

struct ErrorTypeInVarDeclArrayType1 {
  var v1 : Int[+] // expected_error {{array types are now written with the brackets around the element type}}
  // expected_error @-1 {{expected expression after unary operator}}
  // expected_error @-2 {{expected expression}}
  var v2 : Int
}

struct ErrorTypeInVarDeclArrayType2 {
  var v1 : Int[+ // expected_error {{unary operator cannot be separated from its operand}}
                 // expected_error@-1 {{expected ']' in array type}}
                 // expected_note@-2 {{to match this opening '['}}
  var v2 : Int // expected_error {{expected expression}}
}

struct ErrorTypeInVarDeclArrayType3 {
  var v1 : Int[ // expected_error {{expected ']' in array type}}
                // expected_note@-1 {{to match this opening '['}}
  ;  // expected_error {{expected expression}}
  var v2 : Int
}

struct ErrorTypeInVarDeclArrayType4 {
  var v1 : Int[1 // expected_error {{expected ']' in array type}} expected_note {{to match this opening '['}}
  var v2 : Int] // expected_error {{unexpected ']' in type; did you mean to write an array type?}} {{12-12=[}}

}

struct ErrorTypeInVarDeclArrayType5 { // expected_note {{in declaration of 'ErrorTypeInVarDeclArrayType5'}}
  let a1: Swift.Int] // expected_error {{unexpected ']' in type; did you mean to write an array type?}} {{11-11=[}}
  let a2: Set<Int]> // expected_error {{expected '>' to complete generic argument list}} // expected_note {{to match this opening '<'}}
  let a3: Set<Int>] // expected_error {{unexpected ']' in type; did you mean to write an array type?}} {{11-11=[}}
  let a4: Int]? // expected_error {{unexpected ']' in type; did you mean to write an array type?}} {{11-11=[}}
  // expected_error @-1 {{consecutive declarations on a line must be separated by ';'}} // expected_error @-1 {{expected declaration}}
  let a5: Int?] // expected_error {{unexpected ']' in type; did you mean to write an array type?}} {{11-11=[}}
  let a6: [Int]] // expected_error {{unexpected ']' in type; did you mean to write an array type?}} {{11-11=[}}
  let a7: [String: Int]] // expected_error {{unexpected ']' in type; did you mean to write an array type?}} {{11-11=[}}
}

struct ErrorTypeInVarDeclDictionaryType {
  let a1: String: // expected_error {{unexpected ':' in type; did you mean to write a dictionary type?}} {{11-11=[}}
  // expected_error @-1 {{expected dictionary value type}}
  let a2: String: Int] // expected_error {{unexpected ':' in type; did you mean to write a dictionary type?}} {{11-11=[}}
  let a3: String: [Int] // expected_error {{unexpected ':' in type; did you mean to write a dictionary type?}} {{11-11=[}} {{24-24=]}}
  let a4: String: Int // expected_error {{unexpected ':' in type; did you mean to write a dictionary type?}} {{11-11=[}} {{22-22=]}}
}

struct ErrorInFunctionSignatureResultArrayType1 {
  func foo() -> Int[ { // expected_error {{expected '{' in body of function declaration}}
                       // expected_note@-1 {{to match this opening '['}}
    return [0]
  }  // expected_error {{expected ']' in array type}}
  func bar() -> Int] { // expected_error {{unexpected ']' in type; did you mean to write an array type?}} {{17-17=[}}
    return [0]
  }
}

struct ErrorInFunctionSignatureResultArrayType2 {
  func foo() -> Int[0 { // expected_error {{expected ']' in array type}} expected_note {{to match this opening '['}}
    return [0]  // expected_error {{cannot convert return expression of type '[Int]' to return type 'Int'}}
  }
}

struct ErrorInFunctionSignatureResultArrayType3 {
  func foo() -> Int[0] { // expected_error {{array types are now written with the brackets around the element type}} {{17-17=[}} {{20-21=}}
    return [0]
  }
}

struct ErrorInFunctionSignatureResultArrayType4 {
  func foo() -> Int[0_1] { // expected_error {{array types are now written with the brackets around the element type}} {{17-17=[}} {{20-21=}}
    return [0]
  }
}


struct ErrorInFunctionSignatureResultArrayType5 {
  func foo() -> Int[0b1] { // expected_error {{array types are now written with the brackets around the element type}} {{17-17=[}} {{20-21=}}
    return [0]
  }
}


struct ErrorInFunctionSignatureResultArrayType11 { // expected_note{{in declaration of 'ErrorInFunctionSignatureResultArrayType11'}}
  func foo() -> Int[(a){a++}] { // expected_error {{consecutive declarations on a line must be separated by ';'}} {{29-29=;}} expected_error {{expected ']' in array type}} expected_note {{to match this opening '['}} expected_error {{cannot find operator '++' in scope; did you mean '+= 1'?}} expected_error {{cannot find 'a' in scope}} expected_error {{expected declaration}}
  }
}

//===--- Recovery for missing initial value in var decls.

struct MissingInitializer1 {
  var v1 : Int = // expected_error {{expected initial value after '='}}
}

//===--- Recovery for expr-postfix.

func exprPostfix1(x : Int) {
  x. // expected_error {{expected member name following '.'}}
}

func exprPostfix2() {
  _ = .42 // expected_error {{'.42' is not a valid floating point literal; it must be written '0.42'}} {{7-7=0}}
}

//===--- Recovery for expr-super.

class ExprSuper {
  init() {
    super. // expected_error {{expected member name following '.'}}
    // expected_error@-1 {{'super' cannot be used in class 'ExprSuper' because it has no superclass}}
  }
}

//===--- Recovery for braces inside a nominal decl.

struct BracesInsideNominalDecl1 { // expected_note{{in declaration of 'BracesInsideNominalDecl1'}}
  { // expected_error {{expected declaration}}
    aaa
  }
  typealias A = Int
}
func use_BracesInsideNominalDecl1() {
  // Ensure that the typealias decl is not skipped.
  var _ : BracesInsideNominalDecl1.A // no-error
}

// https://github.com/apple/swift/issues/43383
class С_43383 {
    print("No one else was in the room where it happened") // expected_note {{'print()' previously declared here}}
    // expected_error @-1 {{expected 'func' keyword in instance method declaration}}
    // expected_error @-2 {{expected '{' in body of function declaration}}
    // expected_error @-3 {{expected parameter name followed by ':'}}
}
extension С_43383 {
    print("The room where it happened, the room where it happened")
    // expected_error @-1 {{expected 'func' keyword in instance method declaration}}
    // expected_error @-2 {{invalid redeclaration of 'print()'}}
    // expected_error @-3 {{expected parameter name followed by ':'}}
}


//===--- Recovery for wrong decl introducer keyword.

class WrongDeclIntroducerKeyword1 {
  notAKeyword() {} // expected_error {{expected 'func' keyword in instance method declaration}}
  func foo() {}
  class func bar() {}
}

//===--- Recovery for wrong inheritance clause.

class Base2<T> {
}

class SubModule {
    class Base1 {}
    class Base2<T> {}
}

// expected_error@+1 {{expected ':' to begin inheritance clause}} {{30-31=: }} {{34-35=}}    
class WrongInheritanceClause1(Int) {}           

// expected_error@+1 {{expected ':' to begin inheritance clause}} {{30-31=: }} {{41-42=}}
class WrongInheritanceClause2(Base2<Int>) {}

// expected_error@+1 {{expected ':' to begin inheritance clause}} {{33-34=: }} {{49-50=}}
class WrongInheritanceClause3<T>(SubModule.Base1) where T:AnyObject {}

// expected_error@+1 {{expected ':' to begin inheritance clause}} {{30-31=: }} {{51-52=}}
class WrongInheritanceClause4(SubModule.Base2<Int>) {}

// expected_error@+1 {{expected ':' to begin inheritance clause}} {{33-34=: }} {{54-55=}}
class WrongInheritanceClause5<T>(SubModule.Base2<Int>) where T:AnyObject {}

// expected_error@+1 {{expected ':' to begin inheritance clause}} {{30-31=: }} 
class WrongInheritanceClause6(Int {}

// expected_error@+1 {{expected ':' to begin inheritance clause}} {{33-34=: }} 
class WrongInheritanceClause7<T>(Int where T:AnyObject {}

class Base {}

// <rdar://problem/18502220> [swift-crashes 078] parser crash on invalid cast in sequence expr
Base=1 as Base=1 // expected_error{{cannot convert value of type 'Int' to type 'Base' in coercion}}
// expected_error@-1 {{cannot assign to immutable expression of type 'Base.Type'}}
// expected_error@-2 {{cannot assign to immutable expression of type 'Base'}}
// expected_error@-3 {{cannot assign value of type '()' to type 'Base.Type'}}
// expected_error@-4 {{cannot assign value of type 'Int' to type 'Base'}}

// <rdar://problem/18634543> Parser hangs at swift::Parser::parseType
public enum TestA {
  // expected_error @+1{{expected '{' in body of function declaration}}
  public static func convertFromExtenndition( // expected_error {{expected parameter name followed by ':'}}
    // expected_error@+1{{expected parameter name followed by ':'}}
    s._core.count != 0, "Can't form a Character from an empty String")
}

public enum TestB {
  // expected_error@+1{{expected '{' in body of function declaration}}
  public static func convertFromExtenndition( // expected_error {{expected parameter name followed by ':'}}
    // expected_error@+1 {{expected parameter name followed by ':'}}
    s._core.count ?= 0, "Can't form a Character from an empty String")
}



// <rdar://problem/18634543> Infinite loop and unbounded memory consumption in parser
class bar {}
var baz: bar
// expected_error@+1{{unnamed parameters must be written with the empty name '_'}}
func foo1(bar!=baz) {} // expected_note {{did you mean 'foo1'?}}
// expected_error@+1{{unnamed parameters must be written with the empty name '_'}}
func foo2(bar! = baz) {}// expected_note {{did you mean 'foo2'?}}

// rdar://19605567
// expected_error@+1{{cannot find 'esp' in scope; did you mean 'test'?}}
switch esp {
case let (jeb):
  // expected_error@+2{{expected an identifier to name generic parameter}}
  // expected_error@+1{{expected '{' in class}}
  class Ceac<}> {}
// expected_error@+1{{extraneous '}' at top level}} {{1-+1:1=}}
}


#if true

// rdar://19605164
// expected_error@+2{{cannot find type 'S' in scope}}
struct Foo19605164 {
func a(s: S[{{g) -> Int {} // expected_note {{to match this opening '['}}
}}} // expected_error {{expected ']' in array type}}
// expected_error@-2{{consecutive statements on a line must be separated by ';'}}
// expected_error@-3{{expected expression}}
#endif
  
// rdar://19605567
// expected_error@+6{{expected '(' for initializer parameters}}
// expected_error@+5{{initializers may only be declared within a type}}
// expected_error@+4{{expected an identifier to name generic parameter}}
// expected_error@+3{{consecutive statements on a line must be separated by ';'}}
// expected_error@+2{{expected expression}}
// expected_error@+1{{extraneous '}' at top level}}
func F() { init<( } )} // expected_note 2{{did you mean 'F'?}}

struct InitializerWithName {
  init x() {} // expected_error {{initializers cannot have a name}} {{8-9=}}
}

struct InitializerWithNameAndParam {
  init a(b: Int) {} // expected_error {{initializers cannot have a name}} {{8-9=}}
  init? c(_ d: Int) {} // expected_error {{initializers cannot have a name}} {{9-10=}}
  init e<T>(f: T) {} // expected_error {{initializers cannot have a name}} {{8-9=}}
  init? g<T>(_: T) {} // expected_error {{initializers cannot have a name}} {{9-10=}}
}

struct InitializerWithLabels {
  init c d: Int {}
  // expected_error @-1 {{expected '(' for initializer parameters}}
  // expected_error @-2 {{initializer requires a body}}
}

// rdar://20337695
func f1() {

  // expected_error @+6 {{cannot find 'C' in scope}}
  // expected_note @+5 {{did you mean 'n'?}}
  // expected_error @+4 {{unary operator cannot be separated from its operand}} {{11-12=}}
  // expected_error @+3 {{'==' is not a prefix unary operator}}
  // expected_error @+2 {{consecutive statements on a line must be separated by ';'}} {{8-8=;}}
  // expected_error@+1 {{type annotation missing in pattern}}
  let n == C { get {}  // expected_error {{cannot find 'get' in scope}}
  }
}


// <rdar://problem/20489838> QoI: Nonsensical error and fixit if "let" is missing between 'if let ... where' clauses
func testMultiPatternConditionRecovery(x: Int?) {
  // expected_error@+1 {{expected ',' joining parts of a multi-clause condition}} {{15-21=,}}
  if let y = x where y == 0, let z = x {
    _ = y
    _ = z
  }

  if var y = x, y == 0, var z = x {
    z = y; y = z
  }

  if var y = x, z = x { // expected_error {{expected 'var' in conditional}} {{17-17=var }}
    z = y; y = z
  }


  // <rdar://problem/20883210> QoI: Following a "let" condition with boolean condition spouts nonsensical errors
  guard let x: Int? = 1, x == 1 else {  }
  // expected_warning @-1 {{explicitly specified type 'Int?' adds an additional level of optional to the initializer, making the optional check always succeed}} {{16-20=Int}}
}

// rdar://20866942
func testRefutableLet() {
  var e : Int?
  let x? = e  // expected_error {{consecutive statements on a line must be separated by ';'}} {{8-8=;}}
  // expected_error @-1 {{expected expression}}
  // expected_error @-2 {{type annotation missing in pattern}}
}

// <rdar://problem/19833424> QoI: Bad error message when using Objective-C literals (@"Hello") in Swift files
let myString = @"foo" // expected_error {{string literals in Swift are not preceded by an '@' sign}} {{16-17=}}


// <rdar://problem/16990885> support curly quotes for string literals
// expected_error @+1 {{unicode curly quote found, replace with '"'}} {{35-38="}}
let curlyQuotes1 = “hello world!” // expected_error {{unicode curly quote found, replace with '"'}} {{20-23="}}

// expected_error @+1 {{unicode curly quote found, replace with '"'}} {{20-23="}}
let curlyQuotes2 = “hello world!"


// <rdar://problem/21196171> compiler should recover better from "unicode Specials" characters
let ￼tryx  = 123        // expected_error {{invalid character in source file}}  {{5-8= }}


// <rdar://problem/21369926> Malformed Swift Enums crash playground service
enum Rank: Int {  // expected_error {{'Rank' declares raw type 'Int', but does not conform to RawRepresentable and conformance could not be synthesized}} expected_note {{add stubs for conformance}}
  case Ace = 1
  case Two = 2.1  // expected_error {{cannot convert value of type 'Double' to raw type 'Int'}}
}

// rdar://22240342 - Crash in diagRecursivePropertyAccess
class r22240342 {
  lazy var xx: Int = {
    foo {  // expected_error {{cannot find 'foo' in scope}}
      let issueView = 42
      issueView.delegate = 12
      
    }
    return 42
    }()
}


// <rdar://problem/22387625> QoI: Common errors: 'let x= 5' and 'let x =5' could use Fix-its
func r22387625() {
  let _= 5 // expected_error{{'=' must have consistent whitespace on both sides}} {{8-8= }}
  let _ =5 // expected_error{{'=' must have consistent whitespace on both sides}} {{10-10= }}
}
// https://github.com/apple/swift/issues/45723
do {
  let _: Int= 5 // expected_error{{'=' must have consistent whitespace on both sides}} {{13-13= }}
  let _: Array<Int>= [] // expected_error{{'=' must have consistent whitespace on both sides}} {{20-20= }}
}


// <rdar://problem/23086402> Swift compiler crash in CSDiag
protocol A23086402 {
  var b: B23086402 { get }
}

protocol B23086402 {
  var c: [String] { get }
}

func test23086402(a: A23086402) {
  print(a.b.c + "") // should not crash but: expected_error {{}}
}

// <rdar://problem/23550816> QoI: Poor diagnostic in argument list of "print" (varargs related)
// The situation has changed. String now conforms to the RangeReplaceableCollection protocol
// and `ss + s` becomes ambiguous. Disambiguation is provided with the unavailable overload
// in order to produce a meaningful diagnostics. (Related: <rdar://problem/31763930>)
func test23550816(ss: [String], s: String) {
  print(ss + s)  // expected_error {{'+' is unavailable: Operator '+' cannot be used to append a String to a sequence of strings}}
}

// <rdar://problem/23719432> [practicalswift] Compiler crashes on &(Int:_)
func test23719432() {
  var x = 42
    &(Int:x) // expected_error {{'&' may only be used to pass an argument to inout parameter}}
}

// <rdar://problem/19911096> QoI: terrible recovery when using '·' for an operator
infix operator · {  // expected_error {{'·' is considered an identifier and must not appear within an operator name}}
  associativity none precedence 150
}

infix operator -@-class Recover1 {} // expected_error {{'@' is not allowed in operator names}}
prefix operator -фф--class Recover2 {} // expected_error {{'фф' is considered an identifier and must not appear within an operator name}}

// <rdar://problem/21712891> Swift Compiler bug: String subscripts with range should require closing bracket.
func r21712891(s : String) -> String {
  let a = s.startIndex..<s.startIndex
  _ = a
  // The specific errors produced don't actually matter, but we need to reject this.
  return "\(s[a)"  // expected_error {{expected ']' in expression list}} expected_note {{to match this opening '['}}
}


// <rdar://problem/24029542> "Postfix '.' is reserved" error message" isn't helpful
func postfixDot(a : String) {
  _ = a.utf8
  _ = a.   utf8  // expected_error {{extraneous whitespace after '.' is not permitted}} {{9-12=}}
  _ = a.       // expected_error {{expected member name following '.'}}
    a.         // expected_error {{expected member name following '.'}}
}

// <rdar://problem/22290244> QoI: "UIColor." gives two issues, should only give one
func f() { // expected_note 2{{did you mean 'f'?}}
  _ = ClassWithStaticDecls.  // expected_error {{expected member name following '.'}}
}


// rdar://problem/22478168
// https://github.com/apple/swift/issues/53396
// expected_error@+1 {{expected '=' instead of '==' to assign default value for parameter}} {{21-23==}}
func f_53396(a: Int == 0) {}

// rdar://38225184
extension Collection where Element == Int && Index == Int {}
// expected_error@-1 {{expected ',' to separate the requirements of this 'where' clause}} {{43-45=,}}

func testSkipUnbalancedParen() {
  ?( // expected_error {{expected expression}}
}
func testSkipToFindOpenBrace1() {
  // expected_error@+3 {{expected pattern}}
  // expected_error@+2 {{variable binding in a condition requires an initializer}}
  // expected_error@+1 {{expected '{' after 'if' condition}}
  do { if case }
}
func testSkipToFindOpenBrace2() {
  do { if true {} else false } // expected_error {{expected '{' or 'if' after 'else'}}
}

struct Outer {
  struct Inner<T> {}
}
extension Outer.Inner<Never> { // expected_note {{in extension of 'Outer.Inner<Never>'}}
  @someAttr
} // expected_error {{expected declaration}}
// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/recovery.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@11:3 {{}} // expected_expr
// expected-error@17:3 {{}} // expected_expr
// expected-note@29:20 {{}} // opening_angle
// expected-error@29:25 {{}} // expected_rangle_generic_arg_list
// expected-error@45:1 {{}} // extra_rbrace
// expected-error@66:8 {{}} // static_func_decl_global_scope
// expected-error@68:15 {{}} // decl_not_static
// expected-error@69:14 {{}} // decl_not_static
// expected-error@70:17 {{}} // decl_not_static
// expected-error@71:18 {{}} // decl_not_static
// expected-error@82:3 {{}} // missing_condition_after_if
// expected-error@83:4 {{}} // expected_lbrace_after_if
// expected-error@88:3 {{}} // missing_condition_after_if
// expected-error@93:10 {{}} // missing_condition_after_if
// expected-error@98:3 {{}} // missing_condition_after_if
// expected-error@98:14 {{}} // statement_same_line_without_semi
// expected-error@101:3 {{}} // missing_condition_after_if
// expected-error@101:14 {{}} // statement_same_line_without_semi
// expected-error@101:16 {{}} // statement_same_line_without_semi
// expected-error@105:3 {{}} // missing_condition_after_if
// expected-error@109:8 {{}} // expected_condition_while
// expected-error@111:3 {{}} // missing_condition_after_while
// expected-error@114:3 {{}} // missing_condition_after_while
// expected-error@120:3 {{}} // missing_condition_after_while
// expected-error@120:17 {{}} // statement_same_line_without_semi
// expected-error@123:3 {{}} // missing_condition_after_while
// expected-error@123:17 {{}} // statement_same_line_without_semi
// expected-error@123:19 {{}} // statement_same_line_without_semi
// expected-error@127:3 {{}} // missing_condition_after_while
// expected-error@132:5 {{}} // missing_condition_after_while
// expected-error@138:5 {{}} // missing_condition_after_while
// expected-error@138:10 {{}} // statement_same_line_without_semi
// expected-error@144:3 {{}} // expected_while_after_repeat_body
// expected-error@150:3 {{}} // c_style_for_stmt_removed
// expected-error@153:3 {{}} // c_style_for_stmt_removed
// expected-error@157:3 {{}} // c_style_for_stmt_removed
// expected-error@160:3 {{}} // c_style_for_stmt_removed
// expected-error@169:6 3 {{}} // expected_foreach_container,expected_foreach_lbrace,expected_pattern
// expected-error@173:7 2 {{}} // expected_foreach_container,expected_pattern
// expected-error@178:6 2 {{}} // expected_foreach_container,expected_pattern
// expected-error@184:9 2 {{}} // expected_foreach_container,expected_foreach_in
// expected-error@189:13 2 {{}} // expected_foreach_container,expected_foreach_in
// expected-error@194:7 {{}} // expected_pattern
// expected-error@194:10 {{}} // expected_foreach_container
// expected-error@198:7 {{}} // expected_pattern
// expected-error@204:7 3 {{}} // expected_foreach_container,expected_foreach_lbrace,expected_pattern
// expected-error@207:12 {{}} // expected_foreach_container
// expected-error@217:6 2 {{}} // expected_foreach_container,expected_pattern
// expected-note@217:6 {{}} // opening_brace
// expected-note@217:7 {{}} // opening_brace
// expected-error@218:1 2 {{}} // expected_closure_rbrace,expected_rbrace_in_brace_stmt
// expected-error@223:6 2 {{}} // expected_foreach_container,expected_pattern
// expected-error@231:21 {{}} // expected_foreach_lbrace
// expected-error@237:6 2 {{}} // expected_foreach_container,expected_pattern
// expected-error@238:4 {{}} // expected_foreach_lbrace
// expected-error@244:10 {{}} // expected_switch_expr
// expected-error@245:4 {{}} // expected_lbrace_after_switch
// expected-error@248:9 {{}} // expected_switch_expr
// expected-error@252:10 {{}} // expected_switch_expr
// expected-error@256:10 {{}} // expected_switch_expr
// expected-error@261:10 {{}} // expected_switch_expr
// expected-error@261:12 {{}} // stmt_in_switch_not_covered_by_case
// expected-error@261:16 {{}} // statement_same_line_without_semi
// expected-error@262:5 {{}} // case_outside_of_switch
// expected-error@265:10 {{}} // expected_switch_expr
// expected-error@265:12 {{}} // stmt_in_switch_not_covered_by_case
// expected-error@265:16 {{}} // statement_same_line_without_semi
// expected-error@265:18 {{}} // statement_same_line_without_semi
// expected-error@266:5 {{}} // case_outside_of_switch
// expected-error@272:23 {{}} // expected_lbrace_struct
// expected-error@273:20 {{}} // expected_lbrace_enum
// expected-error@274:21 {{}} // expected_lbrace_class
// expected-error@275:27 {{}} // expected_lbrace_protocol
// expected-error@276:26 {{}} // expected_lbrace_extension
// expected-error@278:23 {{}} // expected_lbrace_struct
// expected-error@279:20 {{}} // expected_lbrace_enum
// expected-error@280:21 {{}} // expected_lbrace_class
// expected-error@281:27 {{}} // expected_lbrace_protocol
// expected-error@282:26 {{}} // expected_lbrace_extension
// expected-error@286:16 {{}} // repeated_identifier
// expected-note@286:16 2 {{}} // join_identifiers,join_identifiers_camel_case
// expected-error@291:11 {{}} // repeated_identifier
// expected-note@291:11 {{}} // join_identifiers
// expected-error@295:9 {{}} // repeated_identifier
// expected-note@295:9 {{}} // join_identifiers
// expected-error@299:10 {{}} // repeated_identifier
// expected-note@299:10 2 {{}} // join_identifiers,join_identifiers_camel_case
// expected-error@307:11 {{}} // repeated_identifier
// expected-note@307:11 {{}} // join_identifiers
// expected-error@311:17 {{}} // repeated_identifier
// expected-note@311:17 2 {{}} // join_identifiers,join_identifiers_camel_case
// expected-error@318:11 {{}} // repeated_identifier
// expected-note@318:11 2 {{}} // join_identifiers,join_identifiers_camel_case
// expected-error@328:10 {{}} // repeated_identifier
// expected-note@328:10 2 {{}} // join_identifiers,join_identifiers_camel_case
// expected-error@339:11 {{}} // expected_type
// expected-error@343:15 {{}} // expected_member_name
// expected-error@348:16 {{}} // expected_type
// expected-error@353:16 {{}} // expected_type
// expected-note@358:15 {{}} // opening_angle
// expected-error@358:19 {{}} // expected_rangle_generic_arg_list
// expected-note@363:15 {{}} // opening_angle
// expected-error@364:19 {{}} // expected_rangle_generic_arg_list
// expected-error@370:20 {{}} // expected_type
// expected-note@375:20 {{}} // opening_angle
// expected-error@375:32 {{}} // expected_rangle_protocol
// expected-error@380:12 {{}} // expected_type
// expected-note@385:20 {{}} // opening_angle
// expected-error@385:32 {{}} // expected_rangle_protocol
// expected-error@390:33 {{}} // expected_type
// expected-error@394:38 {{}} // expected_type
// expected-note@395:37 {{}} // opening_angle
// expected-error@395:39 {{}} // expected_rangle_protocol
// expected-error@399:40 {{}} // expected_type
// expected-error@403:25 {{}} // expected_identifier_for_type
// expected-note@407:8 {{}} // note_in_decl_of
// expected-error@408:11 {{}} // declaration_same_line_without_semi
// expected-error@408:12 2 {{}} // expected_decl,expected_type
// expected-error@413:25 {{}} // expected_identifier_for_type
// expected-error@417:43 {{}} // expected_identifier_for_type
// expected-error@420:35 2 {{}} // expected_generics_parameter_name,expected_lbrace_struct
// expected-note@422:34 {{}} // opening_angle
// expected-error@422:36 2 {{}} // expected_lbrace_struct,expected_rangle_generics_param
// expected-error@424:37 2 {{}} // expected_generics_parameter_name,expected_lbrace_struct
// expected-error@427:35 {{}} // expected_generics_parameter_name
// expected-note@432:34 {{}} // opening_angle
// expected-error@432:36 {{}} // expected_rangle_generics_param
// expected-error@437:37 {{}} // expected_generics_parameter_name
// expected-error@442:17 {{}} // expected_type_function_result
// expected-error@447:15 {{}} // new_array_syntax
// expected-error@447:16 {{}} // expected_expr_after_unary_operator
// expected-error@447:17 {{}} // expected_expr
// expected-note@454:15 {{}} // opening_bracket
// expected-error@454:16 {{}} // expected_prefix_operator
// expected-error@454:17 {{}} // expected_rbracket_array_type
// expected-error@457:3 {{}} // expected_expr
// expected-note@461:15 {{}} // opening_bracket
// expected-error@461:16 {{}} // expected_rbracket_array_type
// expected-error@463:3 {{}} // expected_expr
// expected-note@468:15 {{}} // opening_bracket
// expected-error@468:17 {{}} // expected_rbracket_array_type
// expected-error@469:15 {{}} // extra_rbracket
// expected-note@473:8 {{}} // note_in_decl_of
// expected-error@474:20 {{}} // extra_rbracket
// expected-note@475:14 {{}} // opening_angle
// expected-error@475:18 {{}} // expected_rangle_generic_arg_list
// expected-error@476:19 {{}} // extra_rbracket
// expected-error@477:14 {{}} // extra_rbracket
// expected-error@477:15 2 {{}} // declaration_same_line_without_semi,expected_decl
// expected-error@479:15 {{}} // extra_rbracket
// expected-error@480:16 {{}} // extra_rbracket
// expected-error@481:24 {{}} // extra_rbracket
// expected-error@485:17 {{}} // extra_colon
// expected-error@485:18 {{}} // expected_dictionary_value_type
// expected-error@487:17 {{}} // extra_colon
// expected-error@488:17 {{}} // extra_colon
// expected-error@489:17 {{}} // extra_colon
// expected-note@493:20 {{}} // opening_bracket
// expected-error@496:4 {{}} // expected_rbracket_array_type
// expected-error@497:20 {{}} // extra_rbracket
// expected-note@503:20 {{}} // opening_bracket
// expected-error@503:23 {{}} // expected_rbracket_array_type
// expected-error@509:20 {{}} // new_array_syntax
// expected-error@515:20 {{}} // new_array_syntax
// expected-error@522:20 {{}} // new_array_syntax
// expected-note@528:8 {{}} // note_in_decl_of
// expected-note@529:20 {{}} // opening_bracket
// expected-error@529:24 {{}} // expected_rbracket_array_type
// expected-error@529:29 2 {{}} // declaration_same_line_without_semi,expected_decl
// expected-error@536:17 {{}} // expected_init_value
// expected-error@542:4 {{}} // expected_member_name
// expected-error@546:7 {{}} // invalid_float_literal_missing_leading_zero
// expected-error@553:10 {{}} // expected_member_name
// expected-note@560:8 {{}} // note_in_decl_of
// expected-error@561:3 {{}} // expected_decl
// expected-error@573:5 {{}} // expected_keyword_in_decl
// expected-error@573:11 {{}} // expected_parameter_name
// expected-error@579:5 {{}} // expected_keyword_in_decl
// expected-error@579:11 {{}} // expected_parameter_name
// expected-error@589:3 {{}} // expected_keyword_in_decl
// expected-error@605:30 {{}} // expected_colon_class
// expected-error@608:30 {{}} // expected_colon_class
// expected-error@611:33 {{}} // expected_colon_class
// expected-error@614:30 {{}} // expected_colon_class
// expected-error@617:33 {{}} // expected_colon_class
// expected-error@620:30 {{}} // expected_colon_class
// expected-error@623:33 {{}} // expected_colon_class
// expected-error@637:46 {{}} // expected_parameter_name
// expected-error@639:25 {{}} // expected_parameter_name
// expected-error@644:46 {{}} // expected_parameter_name
// expected-error@646:25 {{}} // expected_parameter_name
// expected-error@655:11 {{}} // parameter_unnamed
// expected-error@657:11 {{}} // parameter_unnamed
// expected-error@665:14 2 {{}} // expected_generics_parameter_name,expected_lbrace_class
// expected-error@667:1 {{}} // extra_rbrace
// expected-note@675:12 {{}} // opening_bracket
// expected-error@675:16 2 {{}} // expected_expr,statement_same_line_without_semi
// expected-error@676:3 {{}} // expected_rbracket_array_type
// expected-error@688:16 {{}} // initializer_decl_wrong_scope
// expected-error@688:17 {{}} // expected_generics_parameter_name
// expected-error@688:19 {{}} // expected_lparen_initializer
// expected-error@688:20 {{}} // statement_same_line_without_semi
// expected-error@688:21 {{}} // expected_expr
// expected-error@688:22 {{}} // extra_rbrace
// expected-error@691:8 {{}} // initializer_has_name
// expected-error@695:8 {{}} // initializer_has_name
// expected-error@696:9 {{}} // initializer_has_name
// expected-error@697:8 {{}} // initializer_has_name
// expected-error@698:9 {{}} // initializer_has_name
// expected-error@702:8 {{}} // expected_lparen_initializer
// expected-error@716:8 {{}} // statement_same_line_without_semi
// expected-error@716:9 {{}} // expected_prefix_operator
// expected-error@724:16 {{}} // expected_comma_stmtcondition
// expected-error@733:17 {{}} // expected_binding_keyword
// expected-error@746:8 2 {{}} // expected_expr,statement_same_line_without_semi
// expected-error@752:16 {{}} // string_literal_no_atsign
// expected-error@757:20 {{}} // lex_invalid_curly_quote
// expected-error@757:35 {{}} // lex_invalid_curly_quote
// expected-error@760:20 {{}} // lex_invalid_curly_quote
// expected-error@764:5 {{}} // lex_invalid_character
// expected-error@788:8 {{}} // lex_unary_equal
// expected-error@789:9 {{}} // lex_unary_equal
// expected-error@793:13 {{}} // lex_unary_equal
// expected-error@794:20 {{}} // lex_unary_equal
// expected-error@826:16 {{}} // identifier_within_operator_name
// expected-error@830:17 {{}} // operator_name_invalid_char
// expected-error@831:18 {{}} // identifier_within_operator_name
// expected-note@838:14 {{}} // opening_bracket
// expected-error@838:16 {{}} // expected_rsquare_expr_list
// expected-error@845:8 {{}} // extra_whitespace_period
// expected-error@846:8 {{}} // expected_member_name
// expected-error@847:6 {{}} // expected_member_name
// expected-error@852:27 {{}} // expected_member_name
// expected-error@859:21 {{}} // expected_assignment_instead_of_comparison_operator
// expected-error@862:43 {{}} // requires_comma
// expected-error@866:3 {{}} // expected_expr
// expected-error@872:16 3 {{}} // conditional_var_initializer_required,expected_lbrace_after_if,expected_pattern
// expected-error@875:24 {{}} // expected_lbrace_or_if_after_else
// expected-note@881:1 {{}} // note_in_extension_of
// expected-error@883:1 {{}} // expected_decl
// ---- end ASTGen parity ----
