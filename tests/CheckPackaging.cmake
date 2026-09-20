if(NOT DEFINED SOURCE_DIR)
    message(FATAL_ERROR "SOURCE_DIR is required")
endif()

set(required_files
    cmake/Packaging.cmake
    packaging/Qt-LGPL-NOTICE.md
    packaging/licenses/Qt-LGPL-3.0-only.txt
    packaging/linux/com.leomoon.ParsiNegar.desktop
    packaging/linux/com.leomoon.ParsiNegar.metainfo.xml.in
    packaging/linux/build-appimage.cmake
    packaging/linux/fonts-postinst
    packaging/linux/fonts-postrm
    packaging/windows/leomoon-parsinegar.rc.in
    packaging/windows/leomoon-parsinegar.iss.in
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
    "CPACK_DEBIAN_SYSTEMFONTS_PACKAGE_ARCHITECTURE all"
    "PARSINEGAR_WINDOWS_RELEASE_ARCH"
    "set(PARSINEGAR_WINDOWS_INNO_ARCHITECTURE arm64)"
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

file(READ "${SOURCE_DIR}/packaging/windows/leomoon-parsinegar.iss.in" windows_installer)
foreach(expected IN ITEMS
    "Name: \"systemfonts\""
    "Name: \"desktopshortcut\""
    "UsePreviousTasks=no"
    "OutputBaseFilename=leomoon-parsinegar-{#AppVersion}-windows-@PARSINEGAR_WINDOWS_RELEASE_ARCH@-setup"
    "ArchitecturesAllowed=@PARSINEGAR_WINDOWS_INNO_ARCHITECTURE@"
)
    string(FIND "${windows_installer}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Windows installer is missing: ${expected}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/.github/workflows/linux.yml" linux_workflow)
foreach(expected IN ITEMS
    "inputs.arch == 'x64'"
    "inputs.arch == 'arm64'"
    "ubuntu-24.04-arm"
    "linux_arm64"
    "linux_gcc_arm64"
    "aarch64"
    "leomoon-parsinegar-linux-"
)
    string(FIND "${linux_workflow}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Linux multi-architecture workflow is missing: ${expected}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/.github/workflows/windows.yml" windows_workflow)
foreach(expected IN ITEMS
    "inputs.arch == 'x64'"
    "inputs.arch == 'arm64'"
    "windows-11-vs2026-arm"
    "windows_arm64"
    "win64_msvc2022_arm64"
    "leomoon-parsinegar-windows-"
)
    string(FIND "${windows_workflow}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Windows multi-architecture workflow is missing: ${expected}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/.github/workflows/release.yml" release_workflow)
foreach(expected IN ITEMS
    "target:"
    "arch:"
    "inputs.target == 'linux'"
    "inputs.target == 'windows'"
    "inputs.target == 'macos'"
    "github.event_name == 'push' && 'all' || inputs.arch"
    "gh api \"repos/$GITHUB_REPOSITORY/commits/$commit_hash\""
    "https://github.com/%s"
    "by [%s]"
)
    string(FIND "${release_workflow}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Release workflow filtering is missing: ${expected}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/scripts/collect-release-assets.sh" release_collector)
foreach(expected IN ITEMS
    "linux-x86_64.AppImage"
    "linux-aarch64.AppImage"
    "ubuntu-amd64.deb"
    "ubuntu-arm64.deb"
    "ubuntu-all.deb"
    "windows-x64-setup.exe"
    "windows-arm64-setup.exe"
    "macos-universal.dmg"
    "macos-universal.pkg"
)
    string(FIND "${release_collector}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Release artifact naming is missing: ${expected}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/packaging/macos/distribution.xml.in" macos_installer)
foreach(expected IN ITEMS
    "id=\"application\" title=\"LeoMoon ParsiNegar\" start_visible=\"false\" start_enabled=\"false\" start_selected=\"true\""
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
    "LeoMoon ParsiNegar.app"
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

file(READ "${SOURCE_DIR}/packaging/macos/Info.plist.in" macos_info_plist)
foreach(expected IN ITEMS
    "<key>CFBundleDisplayName</key><string>LeoMoon ParsiNegar</string>"
    "<key>CFBundleExecutable</key><string>LeoMoon ParsiNegar</string>"
    "<key>CFBundleName</key><string>LeoMoon ParsiNegar</string>"
)
    string(FIND "${macos_info_plist}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "macOS application identity is missing: ${expected}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/CMakeLists.txt" root_cmake)
string(FIND "${root_cmake}" "OUTPUT_NAME \"LeoMoon ParsiNegar\"" macos_output_name_position)
if(macos_output_name_position EQUAL -1)
    message(FATAL_ERROR "The macOS bundle filename is not LeoMoon ParsiNegar.app")
endif()

string(FIND "${windows_installer}" "SetupIconFile=" setup_icon_position)
if(NOT setup_icon_position EQUAL -1)
    message(FATAL_ERROR "Windows installer must use the default Inno Setup installer icon")
endif()

string(FIND "${windows_installer}" "Flags: checkedonce" checked_once_position)
if(NOT checked_once_position EQUAL -1)
    message(FATAL_ERROR "Windows installer tasks must be selected by default on every run")
endif()

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

file(READ "${SOURCE_DIR}/packaging/linux/com.leomoon.ParsiNegar.desktop" desktop_entry)
foreach(expected IN ITEMS
    "Type=Application"
    "Exec=leomoon-parsinegar"
    "Icon=com.leomoon.ParsiNegar"
)
    string(FIND "${desktop_entry}" "${expected}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Linux desktop entry is missing: ${expected}")
    endif()
endforeach()

message(STATUS "Packaging metadata is complete for ${system_font_count} optional system fonts")
