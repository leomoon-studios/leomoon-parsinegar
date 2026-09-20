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
    docs/WINDOWS_SIGNING.md
    scripts/package-windows.ps1
    scripts/smoke-windows-installer.ps1
    scripts/verify-windows-package.ps1
    packaging/macos/Info.plist.in
    packaging/macos/distribution.xml.in
    packaging/macos/generate-icon.sh
    packaging/macos/package.sh.in
    packaging/macos/shortcut-scripts/postinstall
    docs/MACOS_SIGNING.md
    scripts/package-macos.sh
    scripts/smoke-macos-packages.sh
    scripts/verify-macos-package.sh
    scripts/prepare-release-metadata.sh
    scripts/collect-release-assets.sh
    .github/workflows/release.yml
    .github/workflows/macos.yml
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

file(READ "${SOURCE_DIR}/cmake/Packaging.cmake" packaging_cmake)
foreach(expected IN ITEMS
    "DestDir: \\\"{commonfonts}\\\""
    "FontInstall:"
    "Tasks: systemfonts"
)
    string(FIND "${packaging_cmake}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Windows native font packaging is missing: ${expected}")
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
    "id=\"application\" title=\"ParsiNegar Desktop\" start_visible=\"false\" start_enabled=\"false\" start_selected=\"true\""
    "id=\"systemfonts\" title=\"Install bundled LMN and LMU fonts system-wide\" start_selected=\"true\""
    "id=\"desktopshortcut\" title=\"Create a desktop shortcut\" start_selected=\"true\""
)
    string(FIND "${macos_installer}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "macOS installer is missing: ${expected}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/packaging/macos/package.sh.in" macos_packaging)
foreach(expected IN ITEMS
    "*.ttf|*.otf|*.ttc"
    "Library/Fonts"
    "PARSINEGAR_CODESIGN_IDENTITY"
    "PARSINEGAR_NOTARY_PROFILE"
)
    string(FIND "${macos_packaging}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "macOS packaging is missing: ${expected}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/.github/workflows/release.yml" release_workflow)
foreach(expected IN ITEMS
    "tags:"
    "v*.*.*"
    "uses: ./.github/workflows/linux.yml"
    "uses: ./.github/workflows/windows.yml"
    "uses: ./.github/workflows/macos.yml"
    "needs: [validate, linux, windows, macos]"
    "release-assets/*"
)
    string(FIND "${release_workflow}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Tag release workflow is missing: ${expected}")
    endif()
endforeach()

foreach(platform IN ITEMS linux windows macos)
    file(READ "${SOURCE_DIR}/.github/workflows/${platform}.yml" platform_workflow)
    string(FIND "${platform_workflow}" "workflow_call:" workflow_call_position)
    string(FIND "${platform_workflow}" "branches:" branch_trigger_position)
    if(workflow_call_position EQUAL -1 OR NOT branch_trigger_position EQUAL -1)
        message(FATAL_ERROR "${platform} packaging must be called only by the tag release workflow")
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
