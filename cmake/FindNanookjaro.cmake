#.rst:
#
# Find Nanookjaro
#
# This module finds the Nanookjaro library and headers.
#
# Imported Targets
# ^^^^^^^^^^^^^^^^
#
# This module defines the following :prop_tgt:`IMPORTED` targets:
#
# ``Nanookjaro::nanookjaro``
#   The Nanookjaro library, if found.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module sets the following variables:
#
# ``NANOOKJARO_FOUND``
#   True if Nanookjaro was found.
# ``NANOOKJARO_INCLUDE_DIRS``
#   Where to find nanookjaro headers.
# ``NANOOKJARO_LIBRARIES``
#   The Nanookjaro libraries.
# ``NANOOKJARO_VERSION``
#   The version of Nanookjaro found.

find_path(NANOOKJARO_INCLUDE_DIR
    NAMES nanookjaro/export.hpp
    PATHS ${CMAKE_INSTALL_PREFIX}/include
)

find_library(NANOOKJARO_LIBRARY
    NAMES nanookjaro_core
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
)

if(NANOOKJARO_INCLUDE_DIR AND EXISTS "${NANOOKJARO_INCLUDE_DIR}/nanookjaro/export.hpp")
    file(STRINGS "${NANOOKJARO_INCLUDE_DIR}/nanookjaro/export.hpp" _nanookjaro_version_lines
        REGEX "#define NANOOKJARO_VERSION_(MAJOR|MINOR|PATCH)")
    
    string(REGEX REPLACE ".*#define NANOOKJARO_VERSION_MAJOR ([0-9]+).*" "\\1" NANOOKJARO_VERSION_MAJOR "${_nanookjaro_version_lines}")
    string(REGEX REPLACE ".*#define NANOOKJARO_VERSION_MINOR ([0-9]+).*" "\\1" NANOOKJARO_VERSION_MINOR "${_nanookjaro_version_lines}")
    string(REGEX REPLACE ".*#define NANOOKJARO_VERSION_PATCH ([0-9]+).*" "\\1" NANOOKJARO_VERSION_PATCH "${_nanookjaro_version_lines}")
    
    set(NANOOKJARO_VERSION "${NANOOKJARO_VERSION_MAJOR}.${NANOOKJARO_VERSION_MINOR}.${NANOOKJARO_VERSION_PATCH}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Nanookjaro
    REQUIRED_VARS NANOOKJARO_LIBRARY NANOOKJARO_INCLUDE_DIR
    VERSION_VAR NANOOKJARO_VERSION
)

if(NANOOKJARO_FOUND)
    set(NANOOKJARO_LIBRARIES ${NANOOKJARO_LIBRARY})
    set(NANOOKJARO_INCLUDE_DIRS ${NANOOKJARO_INCLUDE_DIR})
    
    if(NOT TARGET Nanookjaro::nanookjaro)
        add_library(Nanookjaro::nanookjaro UNKNOWN IMPORTED)
        set_target_properties(Nanookjaro::nanookjaro PROPERTIES
            IMPORTED_LOCATION "${NANOOKJARO_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${NANOOKJARO_INCLUDE_DIR}"
        )
    endif()
endif()

mark_as_advanced(NANOOKJARO_INCLUDE_DIR NANOOKJARO_LIBRARY)