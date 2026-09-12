if(NOT DEFINED SOURCE_DIR)
    message(FATAL_ERROR "SOURCE_DIR is required")
endif()

set(required_files
    LICENSE
    SOURCES.md
    THIRD_PARTY_NOTICES.md
    assets/fonts/OFL.txt
    "assets/fonts/Vazirmatn[wght].ttf"
    vendor/js-bidi.js
    vendor/js-bidi/COPYING
    vendor/js-bidi/LICENSE
    vendor/js-bidi/README.md
    vendor/js-bidi/SOURCES.md
    vendor/js-bidi/UNICODE-LICENSE.txt
    vendor/js-parsi-reshaper.js
    vendor/js-parsi-reshaper/LICENSE
    vendor/js-parsi-reshaper/README.md
    vendor/js-parsi-reshaper/SOURCES.md
    vendor/typr.js
    vendor/typr/LICENSE
    vendor/typr/README.md
)

foreach(relative_path IN LISTS required_files)
    set(absolute_path "${SOURCE_DIR}/${relative_path}")
    if(NOT EXISTS "${absolute_path}")
        message(FATAL_ERROR "Required artifact or notice is missing: ${relative_path}")
    endif()
    file(SIZE "${absolute_path}" file_size)
    if(file_size EQUAL 0)
        message(FATAL_ERROR "Required artifact or notice is empty: ${relative_path}")
    endif()
endforeach()

file(READ "${SOURCE_DIR}/THIRD_PARTY_NOTICES.md" notices)
foreach(dependency IN ITEMS JsBidi JsParsiReshaper Typr.js Vazirmatn)
    string(FIND "${notices}" "${dependency}" match_position)
    if(match_position EQUAL -1)
        message(FATAL_ERROR "THIRD_PARTY_NOTICES.md does not identify ${dependency}")
    endif()
endforeach()

message(STATUS "License inventory is complete")
