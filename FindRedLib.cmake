if(NOT TARGET RedLib)
  add_compile_definitions(NOMINMAX)
  add_subdirectory(deps/red_lib)
endif()