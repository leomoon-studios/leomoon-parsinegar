if(NOT DEFINED EXPECTED_VERSION OR NOT DEFINED EXPECTED_RELEASE_DATE OR NOT DEFINED APP_PATH OR NOT DEFINED METADATA_PATH)
    message(FATAL_ERROR "EXPECTED_VERSION, EXPECTED_RELEASE_DATE, APP_PATH, and METADATA_PATH are required")
endif()

execute_process(
    COMMAND "${APP_PATH}" --version
    RESULT_VARIABLE version_result
    OUTPUT_VARIABLE version_output
    ERROR_VARIABLE version_error
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT version_result EQUAL 0)
    message(FATAL_ERROR "The application version command failed: ${version_error}")
endif()
if(NOT version_output STREQUAL "ParsiNegar Desktop ${EXPECTED_VERSION}")
    message(FATAL_ERROR "Application version mismatch: ${version_output}")
endif()

file(READ "${METADATA_PATH}" metadata)
string(FIND "${metadata}" "<release version=\"${EXPECTED_VERSION}\" date=\"${EXPECTED_RELEASE_DATE}\"" metadata_version_position)
if(metadata_version_position EQUAL -1)
    message(FATAL_ERROR "AppStream metadata does not contain version ${EXPECTED_VERSION}")
endif()

message(STATUS "Release metadata and executable report version ${EXPECTED_VERSION} dated ${EXPECTED_RELEASE_DATE}")
