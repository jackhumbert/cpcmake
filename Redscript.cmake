# MOD_SLUG
# MOD_TOOLS_DIR
# MOD_GAME_DIR
# MOD_PREREQS_DIR
# MOD_REDSCRIPT_DIR
# CYBERPUNK_2077_REDSCRIPT_BACKUP

include(Header)

# project(redscript)

set(REDSCRIPT_PREREQ_FILE "${PROJECT_BINARY_DIR}/prereqs.redscripts")
set(REDSCRIPT_LAST_LINT "${PROJECT_BINARY_DIR}/redscript.lint")
set(REDSCRIPT_PREREQS_DIR "${MOD_PREREQS_DIR}/r6/scripts")
set(REDSCRIPT_PACKED_FILE "${MOD_GAME_DIR}/r6/scripts/${MOD_SLUG}/${MOD_SLUG}.packed.reds")
set(REDSCRIPT_MODULE_FILE "${MOD_GAME_DIR}/r6/scripts/${MOD_SLUG}/${MOD_SLUG}.module.reds")
set(REDSCRIPT_MODULE_TEMP "${PROJECT_BINARY_DIR}/${MOD_SLUG}.module.reds")
set(REDSCRIPT_CLI_EXE "${MOD_TOOLS_DIR}/redscript-cli.exe")

configure_file(${MOD_REDSCRIPT_DIR}/Module.reds.in "${REDSCRIPT_MODULE_TEMP}" @ONLY)

file(GLOB_RECURSE REDSCRIPT_PREREQ_REDSCRIPT_FILES ${REDSCRIPT_PREREQS_DIR}/*.reds)

add_custom_command(
  OUTPUT ${REDSCRIPT_PREREQ_FILE}
  DEPENDS ${REDSCRIPT_PREREQ_REDSCRIPT_FILES}
  COMMAND ${REDSCRIPT_CLI_EXE}
  ARGS compile -s "${REDSCRIPT_PREREQS_DIR}" -b "${CYBERPUNK_2077_REDSCRIPT_BACKUP}" -o ${REDSCRIPT_PREREQ_FILE}
  COMMENT "Compiling redscript prereqs")

# add_custom_target(prereqs DEPENDS ${REDSCRIPT_PREREQ_FILE})

file(GLOB_RECURSE REDSCRIPT_SOURCE_FILES ${MOD_REDSCRIPT_DIR}/*.reds LIST_DIRECTORIES false)

add_custom_command(
  OUTPUT ${REDSCRIPT_LAST_LINT}
  DEPENDS ${REDSCRIPT_PREREQ_FILE} ${REDSCRIPT_SOURCE_FILES}
  COMMAND ${REDSCRIPT_CLI_EXE} lint -s ${MOD_REDSCRIPT_DIR} -b ${REDSCRIPT_PREREQ_FILE} && echo "1" > ${REDSCRIPT_LAST_LINT}
  COMMENT "Linting redscript against pre-compiled prereqs"
  USES_TERMINAL)

add_custom_target(lint DEPENDS ${REDSCRIPT_LAST_LINT})

add_custom_command(
  OUTPUT ${REDSCRIPT_PACKED_FILE}
  DEPENDS lint ${REDSCRIPT_SOURCE_FILES}
  COMMAND ${CMAKE_COMMAND} -D COMMENT_SLUG="//" -D GLOB_EXT="reds" -D HEADER_FILE="${CMAKE_CURRENT_LIST_DIR}/Header.txt" -D PACKED_FILE=${REDSCRIPT_PACKED_FILE} -D SEARCH_FOLDER=${MOD_REDSCRIPT_DIR} -P ${CMAKE_CURRENT_LIST_DIR}/PackFiles.cmake
  COMMENT "Packing redscript files into one")

add_custom_command(
  OUTPUT ${REDSCRIPT_MODULE_FILE}
  DEPENDS ${REDSCRIPT_MODULE_TEMP}
  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${REDSCRIPT_MODULE_TEMP} ${REDSCRIPT_MODULE_FILE}
  COMMENT "Creating redscript module file")

add_custom_target(redscript DEPENDS ${REDSCRIPT_PACKED_FILE} ${REDSCRIPT_MODULE_FILE})