if(NOT DEFINED SOURCE_DIR)
    message(FATAL_ERROR "SOURCE_DIR is required")
endif()

file(GLOB_RECURSE qml_files "${SOURCE_DIR}/qml/*.qml")
if(NOT qml_files)
    message(FATAL_ERROR "No QML source files were found")
endif()

foreach(qml_file IN LISTS qml_files)
    file(READ "${qml_file}" contents)
    if(contents MATCHES "import[ \t]+Quickshell" OR contents MATCHES "import[ \t]+qs\\.(Ui|Commons)")
        file(RELATIVE_PATH relative_path "${SOURCE_DIR}" "${qml_file}")
        message(FATAL_ERROR "Desktop QML contains a forbidden host import: ${relative_path}")
    endif()
endforeach()

message(STATUS "Desktop QML imports are host-independent")
