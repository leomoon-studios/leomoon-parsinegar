if(NOT DEFINED BUILD_DIR OR NOT DEFINED SOURCE_DIR OR NOT DEFINED ARCH OR NOT DEFINED LINUXDEPLOY OR NOT DEFINED QMAKE OR NOT DEFINED VERSION)
    message(FATAL_ERROR "BUILD_DIR, SOURCE_DIR, ARCH, LINUXDEPLOY, QMAKE, and VERSION are required")
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
    COMMAND "${QMAKE}" -query QT_INSTALL_PLUGINS
    RESULT_VARIABLE qmake_result
    OUTPUT_VARIABLE qt_plugins_dir
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT qmake_result EQUAL 0 OR NOT IS_DIRECTORY "${qt_plugins_dir}/platforms")
    message(FATAL_ERROR "Could not locate Qt platform plugins with ${QMAKE}")
endif()

execute_process(
    COMMAND "${QMAKE}" -query QT_INSTALL_LIBS
    RESULT_VARIABLE qmake_libs_result
    OUTPUT_VARIABLE qt_libraries_dir
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
find_file(qt_concurrent_library
    NAMES libQt6Concurrent.so.6 libQt6Concurrent.so
    PATHS "${qt_libraries_dir}"
    NO_DEFAULT_PATH
)
if(NOT qmake_libs_result EQUAL 0 OR NOT qt_concurrent_library)
    message(FATAL_ERROR "Could not locate the Qt Concurrent runtime library with ${QMAKE}")
endif()

file(GLOB wayland_plugin_paths "${qt_plugins_dir}/platforms/libqwayland*.so")
if(NOT wayland_plugin_paths)
    message(FATAL_ERROR "The selected Qt installation has no Wayland platform plugin")
endif()
set(wayland_plugin_names)
foreach(wayland_plugin_path IN LISTS wayland_plugin_paths)
    get_filename_component(wayland_plugin_name "${wayland_plugin_path}" NAME)
    list(APPEND wayland_plugin_names "${wayland_plugin_name}")
endforeach()
list(JOIN wayland_plugin_names ";" extra_platform_plugins)

set(ENV{APPIMAGE_EXTRACT_AND_RUN} 1)
set(ENV{EXTRA_PLATFORM_PLUGINS} "${extra_platform_plugins}")
set(ENV{NO_STRIP} 1)
set(ENV{QMAKE} "${QMAKE}")
set(ENV{QML_SOURCES_PATHS} "${SOURCE_DIR}/qml")
set(ENV{LDAI_OUTPUT} "${BUILD_DIR}/package/linux/ParsiNegar-${VERSION}-${ARCH}.AppImage")

execute_process(
    COMMAND "${LINUXDEPLOY}"
        --appdir "${app_dir}"
        --executable "${app_dir}/usr/bin/ParsiNegar"
        --library "${qt_concurrent_library}"
        --desktop-file "${SOURCE_DIR}/packaging/linux/com.leomoon.ParsiNegarDesktop.desktop"
        --icon-file "${SOURCE_DIR}/assets/app-icon.svg"
        --plugin qt
        --output appimage
    WORKING_DIRECTORY "${BUILD_DIR}/package/linux"
    RESULT_VARIABLE appimage_result
)
unset(ENV{APPIMAGE_EXTRACT_AND_RUN})
unset(ENV{EXTRA_PLATFORM_PLUGINS})
unset(ENV{NO_STRIP})
unset(ENV{QMAKE})
unset(ENV{QML_SOURCES_PATHS})
unset(ENV{LDAI_OUTPUT})
if(NOT appimage_result EQUAL 0)
    message(FATAL_ERROR "linuxdeploy failed while creating the AppImage")
endif()
