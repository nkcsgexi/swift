// RUN; %target-typecheck-verify-swift

import Swift

// ===---------- Multiline --------===

// expecting at least 4 columns of leading indentation
_ = """
    Eleven
  Mu
    """ // expected_error@-1{{insufficient indentation of line in multi-line string literal}}
        // expected_note@-1{{should match space here}}
        // expected_note@-3{{change indentation of this line to match closing delimiter}} {{3-3=  }}

// expecting at least 4 columns of leading indentation
_ = """
    Eleven
   Mu
    """ // expected_error@-1{{insufficient indentation of line in multi-line string literal}}
        // expected_note@-1{{should match space here}}
        // expected_note@-3{{change indentation of this line to match closing delimiter}} {{4-4= }}

// \t is not the same as an actual tab for de-indentation
_ = """
	Twelve
\tNu
	""" // expected_error@-1{{insufficient indentation of line in multi-line string literal}}
      // expected_note@-1{{should match tab here}}
      // expected_note@-3{{change indentation of this line to match closing delimiter}} {{1-1=	}}

_ = """
    \(42
)
    """ // expected_error@-1{{insufficient indentation of line in multi-line string literal}}
        // expected_note@-1{{should match space here}}
        // expected_note@-3{{change indentation of this line to match closing delimiter}} {{1-1=    }}

_ = """
    Foo
\
    Bar 
    """ // expected_error@-2{{insufficient indentation of line in multi-line string literal}}
        // expected_note@-1{{should match space here}}
        // expected_note@-4{{change indentation of this line to match closing delimiter}} {{1-1=    }}

// a tab is not the same as multiple spaces for de-indentation
_ = """
  Thirteen
	Xi
  """ // expected_error@-1{{unexpected tab in indentation of line in multi-line string literal}}
      // expected_note@-1{{should match space here}}
      // expected_note@-3{{change indentation of this line to match closing delimiter}} {{1-2=  }}

// a tab is not the same as multiple spaces for de-indentation
_ = """
    Fourteen
  	Pi
    """ // expected_error@-1{{unexpected tab in indentation of line in multi-line string literal}}
        // expected_note@-1{{should match space here}}
        // expected_note@-3{{change indentation of this line to match closing delimiter}} {{3-4=  }}

// multiple spaces are not the same as a tab for de-indentation
_ = """
	Thirteen 2
  Xi 2
	""" // expected_error@-1{{unexpected space in indentation of line in multi-line string literal}}
      // expected_note@-1{{should match tab here}}
      // expected_note@-3{{change indentation of this line to match closing delimiter}} {{1-3=	}}

// multiple spaces are not the same as a tab for de-indentation
_ = """
		Fourteen 2
	  Pi 2
		""" // expected_error@-1{{unexpected space in indentation of line in multi-line string literal}}
        // expected_note@-1{{should match tab here}}
        // expected_note@-3{{change indentation of this line to match closing delimiter}} {{2-4=	}}

// newline currently required after opening """
_ = """Fourteen
    Pi
    """ // expected_error@-2{{multi-line string literal content must begin on a new line}} {{8-8=\n}}

// newline currently required before closing """
_ = """
    Fourteen
    Pi""" // expected_error@-0{{multi-line string literal closing delimiter must begin on a new line}} {{7-7=\n}}

// newline currently required after opening """
_ = """""" // expected_error@-0{{multi-line string literal content must begin on a new line}} {{8-8=\n}}

// newline currently required after opening """
_ = """ """ // expected_error@-0{{multi-line string literal content must begin on a new line}} {{8-8=\n}}

// two lines should get only one error
_ = """
    Hello,
        World!
	"""     // expected_error@-2{{unexpected space in indentation of next 2 lines in multi-line string literal}}
          // expected_note@-1{{should match tab here}}
          // expected_note@-4{{change indentation of these lines to match closing delimiter}} {{1-5=	}} {{1-5=	}}

  _ = """
Zero A
Zero B
	One A
	One B
  Two A
  Two B
Three A
Three B
		Four A
		Four B
			Five A
			Five B
		"""   // expected_error@-12{{insufficient indentation of next 2 lines in multi-line string literal}}
          // expected_note@-1{{should match tab here}}
          // expected_note@-14{{change indentation of these lines to match closing delimiter}} {{1-1=		}} {{1-1=		}}
          // expected_error@-13{{insufficient indentation of next 2 lines in multi-line string literal}}
          // expected_note@-4{{should match tab here}}
          // expected_note@-15{{change indentation of these lines to match closing delimiter}} {{2-2=	}} {{2-2=	}}
          // expected_error@-14{{unexpected space in indentation of next 4 lines in multi-line string literal}}
          // expected_note@-7{{should match tab here}}
          // expected_note@-16{{change indentation of these lines to match closing delimiter}} {{1-1=		}} {{1-1=		}} {{1-1=		}} {{1-1=		}}

_ = "hello\("""
            world
            """
            )!"
            // expected_error@-4 {{cannot find ')' to match opening '(' in string interpolation}}
            // expected_error@-5 {{unterminated string literal}}
            // expected_error@-3 {{unterminated string literal}}

_ = "hello\(
            """
            world
            """)!"
            // expected_error@-4 {{cannot find ')' to match opening '(' in string interpolation}}
            // expected_error@-5 {{unterminated string literal}}
            // expected_error@-3 {{unterminated string literal}}

_ = """
  line one \ non-whitespace
  line two
  """
  // expected_error@-3 {{invalid escape sequence in literal}}

_ = """
  line one
  line two\
  """
  // expected_error@-2 {{escaped newline at the last line is not allowed}} {{11-12=}}

_ = """
  \\\	   
  """
  // expected_error@-2 {{escaped newline at the last line is not allowed}} {{5-10=}}

_ = """
  \(42)\		
  """
  // expected_error@-2 {{escaped newline at the last line is not allowed}} {{8-11=}}

_ = """
  foo\
  """
  // expected_error@-2 {{escaped newline at the last line is not allowed}} {{6-7=}}

_ = """
  foo\  """
  // expected_error@-1 {{escaped newline at the last line is not allowed}} {{6-7=}}

_ = """
  foo\
  """ // OK because LF + CR is two new lines.

_ = """
\
  """
  // expected_error@-2 {{escaped newline at the last line is not allowed}} {{1-2=}}
  // expected_error@-3{{insufficient indentation of line in multi-line string literal}}
  // expected_note@-3{{should match space here}}
  // expected_note@-5{{change indentation of this line to match closing delimiter}} {{1-1=  }}

_ = """\
  """
  // FIXME: Bad diagnostics
  // expected_error@-3 {{multi-line string literal content must begin on a new line}}
  // expected_error@-4 {{escaped newline at the last line is not allowed}} {{8-9=}}

let _ = """
  foo
  \("bar
  baz
  """
  // expected_error@-3 {{cannot find ')' to match opening '(' in string interpolation}}
  // expected_error@-4 {{unterminated string literal}}

// ---- ASTGen parity: generated by utils/astgen-parity/generate.py; DO NOT EDIT ----
// SOURCE; test/Parse/multiline_errors.swift
// RUN: %target-swift-frontend -parse -verify -disable-objc-attr-requires-foundation-module %s -enable-experimental-feature ParserASTGen %{astgen-parity-override}
// REQUIRES: swift_swift_parser
// REQUIRES: swift_feature_ParserASTGen
// XFAIL: *
// expected-error@10:3 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@10:3 {{}} // lex_multiline_string_indent_change_line
// expected-note@11:3 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@18:4 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@18:4 {{}} // lex_multiline_string_indent_change_line
// expected-note@19:4 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@26:1 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@26:1 {{}} // lex_multiline_string_indent_change_line
// expected-note@27:1 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@33:1 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@33:1 {{}} // lex_multiline_string_indent_change_line
// expected-note@34:1 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@40:1 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@40:1 {{}} // lex_multiline_string_indent_change_line
// expected-note@42:1 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@49:1 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@49:1 {{}} // lex_multiline_string_indent_change_line
// expected-note@50:1 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@57:3 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@57:3 {{}} // lex_multiline_string_indent_change_line
// expected-note@58:3 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@65:1 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@65:1 {{}} // lex_multiline_string_indent_change_line
// expected-note@66:1 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@73:2 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@73:2 {{}} // lex_multiline_string_indent_change_line
// expected-note@74:2 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@79:8 {{}} // lex_illegal_multiline_string_start
// expected-error@86:7 {{}} // lex_illegal_multiline_string_end
// expected-error@89:8 {{}} // lex_illegal_multiline_string_start
// expected-error@92:8 {{}} // lex_illegal_multiline_string_start
// expected-error@96:1 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@96:1 {{}} // lex_multiline_string_indent_change_line
// expected-note@98:1 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@103:1 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@103:1 {{}} // lex_multiline_string_indent_change_line
// expected-error@105:2 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@105:2 {{}} // lex_multiline_string_indent_change_line
// expected-error@107:1 {{}} // lex_multiline_string_indent_inconsistent
// expected-note@107:1 {{}} // lex_multiline_string_indent_change_line
// expected-note@115:1 2 {{}} // lex_multiline_string_indent_should_match_here
// expected-note@115:2 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@125:5 {{}} // lex_unterminated_string
// expected-error@125:12 {{}} // string_interpolation_unclosed
// expected-error@128:15 {{}} // lex_unterminated_string
// expected-error@133:5 {{}} // lex_unterminated_string
// expected-error@133:12 {{}} // string_interpolation_unclosed
// expected-error@136:18 {{}} // lex_unterminated_string
// expected-error@142:13 {{}} // lex_invalid_escape
// expected-error@149:11 {{}} // lex_escaped_newline_at_lastline
// expected-error@154:5 {{}} // lex_escaped_newline_at_lastline
// expected-error@159:8 {{}} // lex_escaped_newline_at_lastline
// expected-error@164:6 {{}} // lex_escaped_newline_at_lastline
// expected-error@169:6 {{}} // lex_escaped_newline_at_lastline
// expected-error@177:1 2 {{}} // lex_escaped_newline_at_lastline,lex_multiline_string_indent_inconsistent
// expected-note@177:1 {{}} // lex_multiline_string_indent_change_line
// expected-note@178:1 {{}} // lex_multiline_string_indent_should_match_here
// expected-error@184:8 2 {{}} // lex_escaped_newline_at_lastline,lex_illegal_multiline_string_start
// expected-error@192:4 {{}} // string_interpolation_unclosed
// expected-error@192:9 {{}} // lex_unterminated_string
// ---- end ASTGen parity ----
