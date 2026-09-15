cmake_minimum_required(VERSION 3.21)

project(
    ParsiNegarDesktop
    VERSION 0.1.0
    DESCRIPTION "Standalone ParsiNegar desktop application"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 6.5 REQUIRED COMPONENTS
    Core
    Concurrent
    Gui
    Qml
    Quick
    QuickControls2
    QuickTest
    Test
)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_library(parsinegar_native_services STATIC)

target_sources(parsinegar_native_services PRIVATE
    src/services/ClipboardBridge.cpp
    src/services/ClipboardBridge.h
    src/services/ClipboardKeeper.cpp
    src/services/ClipboardKeeper.h
    src/services/FileBridge.cpp
    src/services/FileBridge.h
    src/services/SettingsStore.cpp
    src/services/SettingsStore.h
    src/services/TextDirectionBridge.cpp
    src/services/TextDirectionBridge.h
)

target_include_directories(parsinegar_native_services PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

target_link_libraries(parsinegar_native_services PUBLIC
    Qt6::Core
    Qt6::Concurrent
    Qt6::Gui
    Qt6::Quick
)

set_source_files_properties(qml/Main.qml PROPERTIES
    QT_RESOURCE_ALIAS Main.qml
)

set_source_files_properties(qml/theme/AppTheme.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
    QT_RESOURCE_ALIAS AppTheme.qml
)

set_source_files_properties(qml/components/BusySpinner.qml PROPERTIES QT_RESOURCE_ALIAS BusySpinner.qml)
set_source_files_properties(qml/components/LetterBadge.qml PROPERTIES QT_RESOURCE_ALIAS LetterBadge.qml)
set_source_files_properties(qml/components/Typography.qml PROPERTIES QT_RESOURCE_ALIAS Typography.qml)
set_source_files_properties(qml/controls/AppButton.qml PROPERTIES QT_RESOURCE_ALIAS AppButton.qml)
set_source_files_properties(qml/controls/AppMenuItem.qml PROPERTIES QT_RESOURCE_ALIAS AppMenuItem.qml)
set_source_files_properties(qml/controls/DocumentMenu.qml PROPERTIES QT_RESOURCE_ALIAS DocumentMenu.qml)
set_source_files_properties(qml/controls/AppToggle.qml PROPERTIES QT_RESOURCE_ALIAS AppToggle.qml)
set_source_files_properties(qml/controls/IconButton.qml PROPERTIES QT_RESOURCE_ALIAS IconButton.qml)
set_source_files_properties(qml/controls/ModeCard.qml PROPERTIES QT_RESOURCE_ALIAS ModeCard.qml)
set_source_files_properties(qml/controls/NumericField.qml PROPERTIES QT_RESOURCE_ALIAS NumericField.qml)
set_source_files_properties(qml/controls/PageHeader.qml PROPERTIES QT_RESOURCE_ALIAS PageHeader.qml)
set_source_files_properties(qml/controls/StatusMessage.qml PROPERTIES QT_RESOURCE_ALIAS StatusMessage.qml)
set_source_files_properties(qml/controls/SettingsToggle.qml PROPERTIES QT_RESOURCE_ALIAS SettingsToggle.qml)
set_source_files_properties(qml/editor/EditorController.qml PROPERTIES QT_RESOURCE_ALIAS EditorController.qml)
set_source_files_properties(qml/editor/EditorPage.qml PROPERTIES QT_RESOURCE_ALIAS EditorPage.qml)
set_source_files_properties(qml/settings/SettingsPage.qml PROPERTIES QT_RESOURCE_ALIAS SettingsPage.qml)
set_source_files_properties(qml/texttools/TextToolsPage.qml PROPERTIES QT_RESOURCE_ALIAS TextToolsPage.qml)
set_source_files_properties(qml/core/ConversionWorker.js PROPERTIES QT_RESOURCE_ALIAS ConversionWorker.js)
set_source_files_properties(qml/core/SvgCurveWorker.js PROPERTIES QT_RESOURCE_ALIAS SvgCurveWorker.js)
set_source_files_properties(qml/export/SvgCurveExportController.qml PROPERTIES QT_RESOURCE_ALIAS SvgCurveExportController.qml)
set_source_files_properties(qml/export/ExportPage.qml PROPERTIES QT_RESOURCE_ALIAS ExportPage.qml)

qt_add_library(parsinegar_ui STATIC)

qt_add_qml_module(parsinegar_ui
    URI LeoMoon.ParsiNegar
    VERSION 1.0
    RESOURCE_PREFIX /qt/qml
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/LeoMoon/ParsiNegar"
    QML_FILES
        qml/Main.qml
        qml/theme/AppTheme.qml
        qml/components/BusySpinner.qml
        qml/components/LetterBadge.qml
        qml/components/Typography.qml
        qml/controls/AppButton.qml
        qml/controls/AppMenuItem.qml
        qml/controls/DocumentMenu.qml
        qml/controls/AppToggle.qml
        qml/controls/IconButton.qml
        qml/controls/ModeCard.qml
        qml/controls/NumericField.qml
        qml/controls/PageHeader.qml
        qml/controls/SettingsToggle.qml
        qml/controls/StatusMessage.qml
        qml/editor/EditorController.qml
        qml/editor/EditorPage.qml
        qml/settings/SettingsPage.qml
        qml/texttools/TextToolsPage.qml
        qml/export/SvgCurveExportController.qml
        qml/export/ExportPage.qml
    RESOURCES
        assets/app-icon.svg
        "assets/fonts/Vazirmatn[wght].ttf"
        assets/fonts/OFL.txt
        assets/fonts/MaterialSymbolsRounded.ttf
        assets/fonts/MaterialSymbols-LICENSE.txt
        vendor/js-bidi.js
        vendor/js-parsi-reshaper.js
        vendor/typr.js
        qml/core/InterfaceStrings.js
        qml/core/ConversionWorker.js
        qml/core/SvgCurveExporter.js
        qml/core/SvgCurveWorker.js
        qml/core/ParsiNegar.js
        qml/core/ReshaperSettings.js
        qml/core/ResourceLimits.js
        qml/core/SourceHistory.js
        qml/core/TextTools.js
)

target_link_libraries(parsinegar_ui PUBLIC
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

qt_add_executable(parsinegar_desktop
    src/main.cpp
)

target_link_libraries(parsinegar_desktop PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    parsinegar_native_services
    parsinegar_uiplugin
)

set_target_properties(parsinegar_desktop PROPERTIES
    OUTPUT_NAME ParsiNegar
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_BUNDLE_NAME "ParsiNegar Desktop"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.leomoon-studios.parsinegar-desktop"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
    MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
)

include(CTest)

if(BUILD_TESTING)
    add_test(
        NAME license_inventory
        COMMAND "${CMAKE_COMMAND}"
            "-DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/tests/CheckLicenses.cmake"
    )

    add_test(
        NAME resource_smoke
        COMMAND parsinegar_desktop --smoke-test
    )

    set_tests_properties(resource_smoke PROPERTIES
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QPA_PLATFORMTHEME=;QT_QUICK_BACKEND=software"
        TIMEOUT 10
    )

    qt_add_executable(parsinegar_core_tests
        tests/core_tests.cpp
    )

    target_link_libraries(parsinegar_core_tests PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Test
    )

    qt_add_resources(parsinegar_core_tests core_test_resources
        PREFIX /
        FILES
            vendor/js-bidi.js
            vendor/js-parsi-reshaper.js
            vendor/typr.js
            "assets/fonts/Vazirmatn[wght].ttf"
            qml/core/InterfaceStrings.js
            qml/core/ParsiNegar.js
            qml/core/ReshaperSettings.js
            qml/core/ResourceLimits.js
            qml/core/SourceHistory.js
            qml/core/TextTools.js
            qml/core/SvgCurveExporter.js
            tests/fixtures/ParsiNegarFixtures.js
            tests/fixtures/TextToolsFixtures.js
            tests/CoreTests.js
            tests/SvgCurveTests.js
    )

    add_test(
        NAME conversion_core
        COMMAND parsinegar_core_tests
    )

    qt_add_executable(parsinegar_service_tests
        tests/service_tests.cpp
    )

    target_compile_definitions(parsinegar_service_tests PRIVATE
        PARSINEGAR_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
        PARSINEGAR_TEST_APP_PATH="$<TARGET_FILE:parsinegar_desktop>"
    )

    add_dependencies(parsinegar_service_tests parsinegar_desktop)

    target_link_libraries(parsinegar_service_tests PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Test
        parsinegar_native_services
    )

    qt_add_resources(parsinegar_service_tests service_test_resources
        PREFIX /qt/qml/LeoMoon/ParsiNegar
        FILES
            "assets/fonts/Vazirmatn[wght].ttf"
    )

    add_test(
        NAME native_services
        COMMAND parsinegar_service_tests
    )

    set_tests_properties(native_services PROPERTIES
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QPA_PLATFORMTHEME="
        TIMEOUT 20
    )

    qt_add_executable(parsinegar_ui_tests
        tests/ui_test_main.cpp
    )

    target_compile_definitions(parsinegar_ui_tests PRIVATE
        QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/tests/qml"
    )

    target_link_libraries(parsinegar_ui_tests PRIVATE
        Qt6::QuickTest
        parsinegar_native_services
        parsinegar_uiplugin
    )

    add_test(
        NAME desktop_shell
        COMMAND parsinegar_ui_tests
    )

    set_tests_properties(desktop_shell PROPERTIES
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QPA_PLATFORMTHEME=;QT_QUICK_BACKEND=software;QT_QUICK_CONTROLS_STYLE=Basic"
        TIMEOUT 60
    )

    add_test(
        NAME qml_import_boundaries
        COMMAND "${CMAKE_COMMAND}"
            "-DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/tests/CheckQmlImports.cmake"
    )
endif()
