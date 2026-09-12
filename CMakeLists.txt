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
    Gui
    Qml
    Quick
    QuickControls2
    Test
)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(parsinegar_desktop
    src/main.cpp
)

set_source_files_properties(qml/Main.qml PROPERTIES
    QT_RESOURCE_ALIAS Main.qml
)

qt_add_qml_module(parsinegar_desktop
    URI LeoMoon.ParsiNegar
    VERSION 1.0
    RESOURCE_PREFIX /qt/qml
    QML_FILES
        qml/Main.qml
    RESOURCES
        "assets/fonts/Vazirmatn[wght].ttf"
        assets/fonts/OFL.txt
        vendor/js-bidi.js
        vendor/js-parsi-reshaper.js
        vendor/typr.js
        qml/core/InterfaceStrings.js
        qml/core/ParsiNegar.js
        qml/core/ReshaperSettings.js
        qml/core/ResourceLimits.js
)

target_link_libraries(parsinegar_desktop PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
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
            qml/core/InterfaceStrings.js
            qml/core/ParsiNegar.js
            qml/core/ReshaperSettings.js
            qml/core/ResourceLimits.js
            tests/fixtures/ParsiNegarFixtures.js
            tests/CoreTests.js
    )

    add_test(
        NAME conversion_core
        COMMAND parsinegar_core_tests
    )
endif()
