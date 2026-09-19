include(CPackComponent)

set(PARSINEGAR_APP_ID "com.leomoon.ParsiNegarDesktop")
set(PARSINEGAR_PACKAGE_NAME "ParsiNegar Desktop")
set(PARSINEGAR_LINUX_METADATA_DIR "${CMAKE_CURRENT_BINARY_DIR}/packaging/linux")
file(MAKE_DIRECTORY "${PARSINEGAR_LINUX_METADATA_DIR}")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/packaging/linux/${PARSINEGAR_APP_ID}.metainfo.xml.in"
    "${PARSINEGAR_LINUX_METADATA_DIR}/${PARSINEGAR_APP_ID}.metainfo.xml"
    @ONLY
)
set(PARSINEGAR_SYSTEM_FONT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts/system")
file(GLOB PARSINEGAR_SYSTEM_FONT_FILES CONFIGURE_DEPENDS
    "${PARSINEGAR_SYSTEM_FONT_SOURCE_DIR}/*.otf"
    "${PARSINEGAR_SYSTEM_FONT_SOURCE_DIR}/*.ttf"
    "${PARSINEGAR_SYSTEM_FONT_SOURCE_DIR}/*.ttc"
)

set(PARSINEGAR_QT_LGPL3_FILE "${CMAKE_CURRENT_SOURCE_DIR}/packaging/licenses/Qt-LGPL-3.0-only.txt")

install(TARGETS parsinegar_desktop
    BUNDLE DESTINATION . COMPONENT Application
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT Application
)

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE"
    "${CMAKE_CURRENT_SOURCE_DIR}/THIRD_PARTY_NOTICES.md"
    "${CMAKE_CURRENT_SOURCE_DIR}/SOURCES.md"
    "${CMAKE_CURRENT_SOURCE_DIR}/packaging/Qt-LGPL-NOTICE.md"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/doc/parsinegar-desktop"
    COMPONENT Application
)
install(FILES "${PARSINEGAR_QT_LGPL3_FILE}"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/doc/parsinegar-desktop"
    RENAME Qt-LGPL-3.0-only.txt
    COMPONENT Application
)

if(UNIX AND NOT APPLE)
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/packaging/linux/${PARSINEGAR_APP_ID}.desktop"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/applications"
        COMPONENT Application
    )
    install(FILES "${PARSINEGAR_LINUX_METADATA_DIR}/${PARSINEGAR_APP_ID}.metainfo.xml"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/metainfo"
        RENAME "${PARSINEGAR_APP_ID}.appdata.xml"
        COMPONENT Application
    )
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/assets/app-icon.svg"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps"
        RENAME "${PARSINEGAR_APP_ID}.svg"
        COMPONENT Application
    )
endif()

if(PARSINEGAR_SYSTEM_FONT_FILES)
    if(UNIX AND NOT APPLE)
        set(parsinegar_system_font_destination "${CMAKE_INSTALL_DATADIR}/fonts/truetype/parsinegar")
    else()
        set(parsinegar_system_font_destination "${CMAKE_INSTALL_DATADIR}/parsinegar-desktop/system-fonts")
    endif()
    install(FILES ${PARSINEGAR_SYSTEM_FONT_FILES}
        DESTINATION "${parsinegar_system_font_destination}"
        COMPONENT SystemFonts
    )
endif()

cpack_add_component(Application
    DISPLAY_NAME "ParsiNegar Desktop"
    DESCRIPTION "Required application files and Qt runtime"
    REQUIRED
)
cpack_add_component(SystemFonts
    DISPLAY_NAME "Install bundled fonts system-wide"
    DESCRIPTION "Optional LMN and LMU fonts for compatibility output; selected by default"
)
cpack_add_component(DesktopShortcut
    DISPLAY_NAME "Create a desktop shortcut"
    DESCRIPTION "Optional desktop shortcut; selected by default"
)

set(CPACK_PACKAGE_NAME "${PARSINEGAR_PACKAGE_NAME}")
set(CPACK_PACKAGE_VENDOR "LeoMoon Studios")
set(CPACK_PACKAGE_CONTACT "LeoMoon Studios")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Persian, Arabic, Urdu, Kurdish, and Hebrew text tools")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "ParsiNegar Desktop")
set(CPACK_PACKAGE_CHECKSUM SHA256)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_COMPONENTS_ALL Application SystemFonts)
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)

if(WIN32)
    set(CPACK_GENERATOR ZIP)
elseif(APPLE)
    set(CPACK_GENERATOR DragNDrop)
else()
    set(CPACK_GENERATOR "TGZ;DEB")
    set(CPACK_DEB_COMPONENT_INSTALL ON)
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE amd64)
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE arm64)
    else()
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${CMAKE_SYSTEM_PROCESSOR}")
    endif()
    set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
    set(CPACK_DEBIAN_APPLICATION_PACKAGE_NAME parsinegar-desktop)
    set(CPACK_DEBIAN_APPLICATION_PACKAGE_SECTION utils)
    set(CPACK_DEBIAN_APPLICATION_PACKAGE_DEPENDS "libc6, libstdc++6, libqt6concurrent6, libqt6core6, libqt6gui6, libqt6qml6, libqt6quick6, libqt6quickcontrols2-6")
    set(CPACK_DEBIAN_SYSTEMFONTS_PACKAGE_NAME parsinegar-desktop-fonts)
    set(CPACK_DEBIAN_SYSTEMFONTS_PACKAGE_SECTION fonts)
    set(CPACK_DEBIAN_SYSTEMFONTS_PACKAGE_DEPENDS "fontconfig")
    set(CPACK_DEBIAN_SYSTEMFONTS_PACKAGE_CONTROL_EXTRA
        "${CMAKE_CURRENT_SOURCE_DIR}/packaging/linux/fonts-postinst"
        "${CMAKE_CURRENT_SOURCE_DIR}/packaging/linux/fonts-postrm"
    )
endif()

include(CPack)

if(WIN32)
    get_target_property(parsinegar_qmake_executable Qt6::qmake IMPORTED_LOCATION)
    get_filename_component(parsinegar_qt_bin_dir "${parsinegar_qmake_executable}" DIRECTORY)
    find_program(PARSINEGAR_WINDEPLOYQT_EXECUTABLE windeployqt HINTS "${parsinegar_qt_bin_dir}")
    find_program(PARSINEGAR_INNO_SETUP_EXECUTABLE
        NAMES ISCC ISCC.exe
        HINTS "C:/Program Files (x86)/Inno Setup 6"
    )
    set(PARSINEGAR_WINDOWS_STAGE_DIR "${CMAKE_CURRENT_BINARY_DIR}/package/windows/stage")
    file(GLOB parsinegar_windows_font_files CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts/system/*.ttf"
        "${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts/system/*.otf"
        "${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts/system/*.ttc"
    )
    list(SORT parsinegar_windows_font_files)
    set(PARSINEGAR_WINDOWS_FONT_FILE_ENTRIES "")
    foreach(font_path IN LISTS parsinegar_windows_font_files)
        get_filename_component(font_filename "${font_path}" NAME)
        get_filename_component(font_name "${font_path}" NAME_WE)
        string(APPEND PARSINEGAR_WINDOWS_FONT_FILE_ENTRIES
            "Source: \"{#SourceDir}\\assets\\fonts\\system\\${font_filename}\"; DestDir: \"{commonfonts}\"; FontInstall: \"${font_name}\"; Flags: ignoreversion; Tasks: systemfonts\n"
        )
    endforeach()
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/packaging/windows/ParsiNegar.iss.in"
        "${CMAKE_CURRENT_BINARY_DIR}/packaging/windows/ParsiNegar.iss"
        @ONLY
    )

    if(PARSINEGAR_WINDEPLOYQT_EXECUTABLE)
        add_custom_target(deploy_windows
            COMMAND "${CMAKE_COMMAND}"
                "-DBUILD_DIR=${CMAKE_BINARY_DIR}"
                "-DSTAGE_DIR=${PARSINEGAR_WINDOWS_STAGE_DIR}"
                "-DWINDEPLOYQT=${PARSINEGAR_WINDEPLOYQT_EXECUTABLE}"
                "-DCONFIG=$<CONFIG>"
                -P "${CMAKE_CURRENT_SOURCE_DIR}/packaging/windows/deploy.cmake"
            DEPENDS parsinegar_desktop
            VERBATIM
        )
        if(PARSINEGAR_INNO_SETUP_EXECUTABLE)
            add_custom_target(package_windows
                COMMAND "${PARSINEGAR_INNO_SETUP_EXECUTABLE}"
                    "${CMAKE_CURRENT_BINARY_DIR}/packaging/windows/ParsiNegar.iss"
                DEPENDS deploy_windows
                VERBATIM
            )
        endif()
    endif()
elseif(APPLE)
    get_target_property(parsinegar_qmake_executable Qt6::qmake IMPORTED_LOCATION)
    get_filename_component(parsinegar_qt_bin_dir "${parsinegar_qmake_executable}" DIRECTORY)
    find_program(PARSINEGAR_MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${parsinegar_qt_bin_dir}")
    if(PARSINEGAR_MACDEPLOYQT_EXECUTABLE)
        add_custom_target(deploy_macos
            COMMAND "${PARSINEGAR_MACDEPLOYQT_EXECUTABLE}"
                "$<TARGET_BUNDLE_DIR:parsinegar_desktop>"
                -qmldir="${CMAKE_CURRENT_SOURCE_DIR}/qml"
                -always-overwrite
            DEPENDS parsinegar_desktop
            VERBATIM
        )
        configure_file(
            "${CMAKE_CURRENT_SOURCE_DIR}/packaging/macos/package.sh.in"
            "${CMAKE_CURRENT_BINARY_DIR}/packaging/macos/package.sh"
            @ONLY
        )
        add_custom_target(package_macos
            COMMAND sh "${CMAKE_CURRENT_BINARY_DIR}/packaging/macos/package.sh"
            DEPENDS deploy_macos
            VERBATIM
        )
    endif()
elseif(UNIX)
    get_target_property(parsinegar_qmake_executable Qt6::qmake IMPORTED_LOCATION)
    find_program(PARSINEGAR_LINUXDEPLOY_EXECUTABLE linuxdeploy)
    if(PARSINEGAR_LINUXDEPLOY_EXECUTABLE)
        add_custom_target(package_appimage
            COMMAND "${CMAKE_COMMAND}"
                "-DBUILD_DIR=${CMAKE_BINARY_DIR}"
                "-DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
                "-DARCH=${CMAKE_SYSTEM_PROCESSOR}"
                "-DLINUXDEPLOY=${PARSINEGAR_LINUXDEPLOY_EXECUTABLE}"
                "-DQMAKE=${parsinegar_qmake_executable}"
                "-DVERSION=${PROJECT_VERSION}"
                -P "${CMAKE_CURRENT_SOURCE_DIR}/packaging/linux/build-appimage.cmake"
            DEPENDS parsinegar_desktop
            VERBATIM
        )
    endif()
endif()
