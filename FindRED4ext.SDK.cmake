include(ResolveDependency)

if(NOT TARGET RED4ext.SDK)
  option(RED4EXT_USE_PCH "" ON)
  option(RED4EXT_HEADER_ONLY "" ON)

  resolve_dependency(deps/red4ext.sdk)
  add_subdirectory(deps/red4ext.sdk)
  set_target_properties(RED4ext.SDK PROPERTIES FOLDER "Dependencies")

  mark_as_advanced(
    RED4EXT_BUILD_EXAMPLES
    RED4EXT_USE_PCH
    RED4EXT_INSTALL
  )

  set(MOD_RED4EXT_SDK_DIR "${MOD_SOURCE_DIR}/deps/red4ext.sdk")
endif()