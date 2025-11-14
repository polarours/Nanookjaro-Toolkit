cmake_minimum_required(VERSION 3.20)
project(NanookjaroToolkit 
  VERSION 0.1.0
  DESCRIPTION "Cross-platform hardware detection and system monitoring toolkit for Manjaro/Arch"
  LANGUAGES CXX)

option(NANOOKJARO_BUILD_CLI "Build the Nanookjaro CLI" ON)
option(NANOOKJARO_BUILD_TESTS "Build tests" OFF)
option(NANOOKJARO_ENABLE_INSTALL "Enable install targets" ON)

if(EXISTS "/etc/arch-release")
    set(ARCH_LINUX TRUE)
    message(STATUS "Building for Arch-based system (Manjaro/Arch Linux)")
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

add_subdirectory(backend)

if(NANOOKJARO_BUILD_CLI)
    add_subdirectory(cli)
endif()

if(NANOOKJARO_ENABLE_INSTALL)
    include(GNUInstallDirs)

    install(DIRECTORY docs/
        DESTINATION ${CMAKE_INSTALL_DOCDIR}
        FILES_MATCHING PATTERN "*.md"
    )

    install(DIRECTORY assets/
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/nanookjaro
    )
endif()
