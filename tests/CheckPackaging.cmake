if(NOT DEFINED SOURCE_DIR)
    message(FATAL_ERROR "SOURCE_DIR is required")
endif()

set(required_files
    cmake/Packaging.cmake
    packaging/Qt-LGPL-NOTICE.md
    packaging/licenses/Qt-LGPL-3.0-only.txt
    packaging/linux/com.leomoon.ParsiNegarDesktop.desktop
    packaging/linux/com.leomoon.ParsiNegarDesktop.metainfo.xml.in
    packaging/linux/build-appimage.cmake
    packaging/linux/fonts-postinst
    packaging/linux/fonts-postrm
    packaging/windows/ParsiNegar.rc.in
    packaging/windows/ParsiNegar.iss.in
    packaging/windows/app-icon.ico
    packaging/windows/deploy.cmake
    packaging/windows/install-fonts.ps1
    packaging/windows/uninstall-fonts.ps1
    packaging/macos/Info.plist.in
    packaging/macos/distribution.xml.in
    packaging/macos/generate-icon.sh
    packaging/macos/package.sh.in
    packaging/macos/shortcut-scripts/postinstall
)

foreach(relative_path IN LISTS required_files)
    set(absolute_path "${SOURCE_DIR}/${relative_path}")
    if(NOT EXISTS "${absolute_path}")
        message(FATAL_ERROR "Required packaging file is missing: ${relative_path}")
    endif()
    file(SIZE "${absolute_path}" file_size)
    if(file_size EQUAL 0)
        message(FATAL_ERROR "Required packaging file is empty: ${relative_path}")
    endif()
endforeach()

file(GLOB system_fonts
    "${SOURCE_DIR}/assets/fonts/system/*.ttf"
    "${SOURCE_DIR}/assets/fonts/system/*.otf"
    "${SOURCE_DIR}/assets/fonts/system/*.ttc"
)
list(LENGTH system_fonts system_font_count)
if(system_font_count EQUAL 0)
    message(FATAL_ERROR "The optional system-font component has no font files")
endif()

file(READ "${SOURCE_DIR}/packaging/windows/ParsiNegar.iss.in" windows_installer)
foreach(expected IN ITEMS
    "Name: \"systemfonts\""
    "Name: \"desktopshortcut\""
    "Flags: checkedonce"
)
    string(FIND "${windows_installer}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Windows installer is missing: ${expected}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/packaging/macos/distribution.xml.in" macos_installer)
foreach(expected IN ITEMS
    "id=\"application\" title=\"ParsiNegar Desktop\" visible=\"false\" enabled=\"false\" selected=\"true\""
    "id=\"systemfonts\" title=\"Install bundled LMN and LMU fonts system-wide\" selected=\"true\""
    "id=\"desktopshortcut\" title=\"Create a desktop shortcut\" selected=\"true\""
)
    string(FIND "${macos_installer}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "macOS installer is missing: ${expected}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/packaging/linux/com.leomoon.ParsiNegarDesktop.desktop" desktop_entry)
foreach(expected IN ITEMS
    "Type=Application"
    "Exec=ParsiNegar"
    "Icon=com.leomoon.ParsiNegarDesktop"
)
    string(FIND "${desktop_entry}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Linux desktop entry is missing: ${expected}")
    endif()
endforeach()

message(STATUS "Packaging metadata is complete for ${system_font_count} optional system fonts")
