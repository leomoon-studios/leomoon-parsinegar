if(NOT DEFINED BUILD_DIR OR NOT DEFINED SOURCE_DIR OR NOT DEFINED LINUXDEPLOY)
    message(FATAL_ERROR "BUILD_DIR, SOURCE_DIR, and LINUXDEPLOY are required")
endif()

set(app_dir "${BUILD_DIR}/package/linux/AppDir")
file(REMOVE_RECURSE "${app_dir}")
file(MAKE_DIRECTORY "${app_dir}")

execute_process(
    COMMAND "${CMAKE_COMMAND}" -E env "DESTDIR=${app_dir}"
        "${CMAKE_COMMAND}" --install "${BUILD_DIR}" --prefix /usr --component Application
    RESULT_VARIABLE install_result
)
if(NOT install_result EQUAL 0)
    message(FATAL_ERROR "Failed to stage the AppImage application component")
endif()

execute_process(
    COMMAND "${CMAKE_COMMAND}" -E env OUTPUT="${BUILD_DIR}/package/linux/ParsiNegar-${CMAKE_HOST_SYSTEM_PROCESSOR}.AppImage"
        "${LINUXDEPLOY}"
        --appdir "${app_dir}"
        --executable "${app_dir}/usr/bin/ParsiNegar"
        --desktop-file "${SOURCE_DIR}/packaging/linux/com.leomoon.ParsiNegarDesktop.desktop"
        --icon-file "${SOURCE_DIR}/assets/app-icon.svg"
        --plugin qt
        --output appimage
    WORKING_DIRECTORY "${BUILD_DIR}/package/linux"
    RESULT_VARIABLE appimage_result
)
if(NOT appimage_result EQUAL 0)
    message(FATAL_ERROR "linuxdeploy failed while creating the AppImage")
endif()
