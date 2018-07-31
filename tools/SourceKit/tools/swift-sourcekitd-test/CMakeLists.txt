set(EXTRA_COMPILE_FLAGS "-F" "${SWIFT_LIBRARY_OUTPUT_INTDIR}" "-module-name" "main")
set(EXTRA_LINKER_FLAGS "-Xlinker" "-rpath" "-Xlinker" "${SWIFT_LIBRARY_OUTPUT_INTDIR}"
    "-Xlinker" "-F" "-Xlinker" "${SWIFT_LIBRARY_OUTPUT_INTDIR}")

macro(add_swift_module_depends results target)
  list(APPEND ${results} "${target}-macosx")
  list(APPEND ${results} "${target}-macosx-x86_64")
  list(APPEND ${results} "${target}-swiftmodule-macosx-x86_64")
endmacro()

add_swift_module_depends(all_depends swiftTestUtils)
add_swift_module_depends(all_depends swiftSwiftLang)

add_swift_host_tool(swift-sourcekitd-test
  main.swift
  empty.c # FIXME: If there is no C file in the target Xcode skips the linking phase and doesn't create the executable
  COMPILE_FLAGS ${EXTRA_COMPILE_FLAGS}
  LINK_FLAGS ${EXTRA_LINKER_FLAGS}
  DEPENDS ${all_depends}
)
