# ASTGen diagnostic parity: test/Parse

| | count |
|---|---|
| generated tests | 263 |
| xfail (not at parity) | 155 |
| passing (regression guards) | 108 |
| skipped configs/files | 28 |

## Tests by directory (gap type behind most failures)

| directory | tests |
|---|---|
| passing/ | 108 |
| extra/ | 44 |
| ifconfig/ | 43 |
| crash/ | 24 |
| mixed/ | 21 |
| missing/ | 20 |
| wrong-column/ | 3 |

## Diagnostics by category

| category | count |
|---|---|
| extra | 876 |
| matched | 208 |
| message-differs | 411 |
| missing | 1044 |
| wrong-column | 160 |
| wrong-severity | 40 |

## Tags on non-matched diagnostics

| tag | count |
|---|---|
| ifconfig_condition | 190 |
| in_ifconfig_clause | 89 |
| at_eof | 42 |

## Top missing legacy diagnostics

| id | count |
|---|---|
| accessor_requires_coroutine_accessors | 37 |
| statement_same_line_without_semi | 35 |
| expected_decl | 30 |
| previous_accessor | 24 |
| conflicting_accessor | 18 |
| case_stmt_without_body | 18 |
| case_outside_of_switch | 17 |
| backticks_to_escape | 17 |
| invalid_accessor_specifier | 16 |
| opening_paren | 16 |
| missing_reading_accessor | 16 |
| expected_expr | 15 |
| note_in_decl_of | 15 |
| dollar_identifier_decl | 15 |
| where_inside_brackets | 14 |
| expected_parameter_name | 14 |
| try_on_var_let | 14 |
| expected_close_to_if_directive | 13 |
| expected_rbrace_in_brace_stmt | 13 |
| avail_query_expected_platform_name | 12 |
| avail_query_expected_rparen | 12 |
| expected_type | 12 |
| expected_identifier_in_module_selector | 11 |
| case_after_default | 11 |
| invalid_accessor_with_effectful_get | 10 |
| keyword_cant_be_identifier | 10 |
| expected_pattern | 9 |
| unknown_attr_name | 9 |
| destructor_decl_outside_class_or_noncopyable | 9 |
| lex_invalid_utf8 | 9 |

## Skip reasons

| reason | count |
|---|---|
| extra input or argument | 11 |
| no frontend RUN line on %s | 5 |
| legacy harvest | 4 |
| debugger support makes ASTGen fall back to legacy | 2 |
| split-file test | 2 |
| unsupported flag | 1 |
| mock-sdk frontend | 1 |
| feature-checker exception | 1 |
| contains NUL bytes | 1 |
