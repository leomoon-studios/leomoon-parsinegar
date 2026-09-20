if(NOT DEFINED BUILD_DIR OR NOT DEFINED STAGE_DIR OR NOT DEFINED WINDEPLOYQT)
    message(FATAL_ERROR "BUILD_DIR, STAGE_DIR, and WINDEPLOYQT are required")
endif()

file(REMOVE_RECURSE "${STAGE_DIR}")
file(MAKE_DIRECTORY "${STAGE_DIR}")

set(install_command "${CMAKE_COMMAND}" --install "${BUILD_DIR}" --prefix "${STAGE_DIR}" --component Application)
if(DEFINED CONFIG AND NOT CONFIG STREQUAL "")
    list(APPEND install_command --config "${CONFIG}")
endif()
execute_process(COMMAND ${install_command} RESULT_VARIABLE install_result)
if(NOT install_result EQUAL 0)
    message(FATAL_ERROR "Failed to stage the Windows application")
endif()

execute_process(
    COMMAND "${WINDEPLOYQT}"
        --qmldir "${CMAKE_CURRENT_LIST_DIR}/../../qml"
        --compiler-runtime
        --no-translations
        "${STAGE_DIR}/bin/leomoon-parsinegar.exe"
    RESULT_VARIABLE deploy_result
)
if(NOT deploy_result EQUAL 0)
    message(FATAL_ERROR "windeployqt failed")
endif()
