# inputs
# MOD_RED4EXT_SDK_DIR
# ZOLTAN_USER_SIGNATURES
# ZOLTAN_ADDRESSES_OUTPUT
# ZOLTAN_CLANG_EXE

list(APPEND CMAKE_MODULE_PATH "${MOD_RED4EXT_SDK_DIR}/cmake")
include(GetGameVersion)

# project(${MOD_SLUG}.dll LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Addresses from Zoltan

add_custom_command(
  OUTPUT ${ZOLTAN_ADDRESSES_OUTPUT}
  DEPENDS ${ZOLTAN_USER_SIGNATURES}
  COMMAND ${ZOLTAN_CLANG_EXE}
  ARGS ${ZOLTAN_USER_SIGNATURES} ${CYBERPUNK_2077_EXE} -f "std=c++20" -f "I${MOD_RED4EXT_SDK_DIR}/include" --c-output "${ZOLTAN_ADDRESSES_OUTPUT}" --safe-addr
  COMMENT "Finding binary addresses of declared functions in ${ZOLTAN_USER_SIGNATURES}"
)

add_custom_target(addresses DEPENDS ${ZOLTAN_ADDRESSES_OUTPUT})
set_target_properties(addresses PROPERTIES FOLDER Red4ext)

add_library(${MOD_SLUG}.dll SHARED ${ZOLTAN_ADDRESSES_OUTPUT})
set_target_properties(${MOD_SLUG}.dll PROPERTIES FOLDER Red4ext)

target_compile_definitions(${MOD_SLUG}.dll PUBLIC
  # Support Windows 7 and above.
  WINVER=0x0601
  _WIN32_WINNT=0x0601

  # Exclude unnecessary APIs.
  WIN32_LEAN_AND_MEAN

  # Use Unicode charset.
  UNICODE
  _UNICODE

  # https://github.com/microsoft/STL/issues/1934
  _ITERATOR_DEBUG_LEVEL=0

  # for Codeware
  NOMINMAX
  #  _DEBUG
#  _WINDLL
 _CRT_SECURE_NO_WARNINGS

  MOD_VERSION_STR="${MOD_VERSION_STR}"
  MOD_VERSION_MAJOR=${MOD_VERSION_MAJOR}
  MOD_VERSION_MINOR=${MOD_VERSION_MINOR}
  MOD_VERSION_PATCH=${MOD_VERSION_PATCH}

  GAME_VERSION_MAJOR=${CYBERPUNK_2077_FILE_VERSION_MAJOR}
  GAME_VERSION_MINOR=${CYBERPUNK_2077_FILE_VERSION_MINOR}
  GAME_VERSION_BUILD=${CYBERPUNK_2077_FILE_VERSION_BUILD}
  GAME_VERSION_PRIVATE=${CYBERPUNK_2077_FILE_VERSION_PRIVATE}

  VER_INTERNALNAME_STR="${MOD_SLUG}"
  VER_FILEVERSION=${MOD_VERSION_MAJOR},${MOD_VERSION_MINOR},${MOD_VERSION_PATCH}
  VER_FILEVERSION_STR="${MOD_VERSION_MAJOR}.${MOD_VERSION_MINOR}.${MOD_VERSION_PATCH}"
  VER_PRODUCTVERSION=${CYBERPUNK_2077_FILE_VERSION_MAJOR},${CYBERPUNK_2077_FILE_VERSION_MINOR},${CYBERPUNK_2077_FILE_VERSION_BUILD},${CYBERPUNK_2077_FILE_VERSION_PRIVATE}
  VER_PRODUCTVERSION_STR="${CYBERPUNK_2077_GAME_VERSION_STR}"
  VER_COMPANYNAME="${MOD_AUTHOR}"
  VER_FILEDESCRIPTION_STR="Red4ext plugin for Cyberpunk 2077"
  # VER_LEGALCOPYRIGHT_STR="© 2023 ${MOD_AUTHOR}. All rights reserved"
  VER_COMPANYNAME_STR="${MOD_AUTHOR}"
  VER_PRODUCTNAME_STR="${MOD_NAME}"
  VER_ORIGINALFILENAME_STR="${MOD_SLUG}.dll"
  VER_COMMENTS_STR="Built for ${CYBERPUNK_2077_GAME_VERSION_STR}"
)

set_target_properties(${MOD_SLUG}.dll PROPERTIES OUTPUT_NAME ${MOD_SLUG})
set_target_properties(${MOD_SLUG}.dll PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
set_target_properties(${MOD_SLUG}.dll PROPERTIES ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

file(GLOB_RECURSE HEADER_FILES *.hpp)
file(GLOB_RECURSE SOURCE_FILES *.cpp)
file(GLOB_RECURSE RC_FILES *.rc)

source_group(_CMake REGULAR_EXPRESSION cmake_pch.*)
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES ${HEADER_FILES} ${SOURCE_FILES} ${RC_FILES})

target_include_directories(${MOD_SLUG}.dll PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_sources(${MOD_SLUG}.dll PRIVATE ${HEADER_FILES} ${SOURCE_FILES} ${RC_FILES} ${CMAKE_CURRENT_LIST_DIR}/versioninfo.rc)

target_precompile_headers(${MOD_SLUG}.dll PUBLIC stdafx.hpp)

add_custom_command(
  TARGET ${MOD_SLUG}.dll POST_BUILD
  DEPENDS ${MOD_SLUG}.dll
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  $<TARGET_FILE:${MOD_SLUG}.dll>
  ${MOD_GAME_DIR}/red4ext/plugins/${MOD_SLUG}/${MOD_SLUG}.dll
  COMMENT "${MOD_SLUG}.dll -> ${MOD_GAME_DIR}/red4ext/plugins/${MOD_SLUG}/${MOD_SLUG}.dll")
add_dependencies(${MOD_SLUG} ${MOD_SLUG}.dll)