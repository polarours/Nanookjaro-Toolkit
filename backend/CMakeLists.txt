cmake_minimum_required(VERSION 3.20)

add_library(nanookjaro_core SHARED
    src/system/system_summary.cpp
    src/ffi.cpp
    src/maintenance/package_manager.cpp
    src/hardware/cpu_monitor.cpp
    src/hardware/gpu_monitor.cpp
    src/hardware/memory_monitor.cpp
    src/hardware/disk_monitor.cpp
    src/network/network_monitor.cpp
    src/drivers/driver_manager.cpp
    src/performance/performance_monitor.cpp
)

add_library(Nanookjaro::nanookjaro_core ALIAS nanookjaro_core)

set_target_properties(nanookjaro_core PROPERTIES
    VERSION ${CMAKE_PROJECT_VERSION}
    SOVERSION ${CMAKE_PROJECT_VERSION_MAJOR}
)

target_include_directories(nanookjaro_core
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/hardware>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/system>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/network>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/drivers>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/maintenance>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/performance>
        $<INSTALL_INTERFACE:include>
)

target_compile_definitions(nanookjaro_core PRIVATE NANOOKJARO_CORE_BUILD)

target_compile_features(nanookjaro_core PUBLIC cxx_std_20)

if (MSVC)
    target_compile_options(nanookjaro_core PRIVATE /W4 /WX)
else()
    target_compile_options(nanookjaro_core PRIVATE -Wall -Wextra -Wpedantic)
endif()

if(EXISTS "/etc/arch-release")
    set(ARCH_LINUX TRUE)

    find_program(PACMAN_EXECUTABLE pacman)
    find_program(LSPCI_EXECUTABLE lspci)
    find_program(SMARTCTL_EXECUTABLE smartctl)
    
    if(NOT PACMAN_EXECUTABLE)
        message(WARNING "pacman not found, package manager features will be disabled")
    endif()
    
    if(NOT LSPCI_EXECUTABLE)
        message(WARNING "lspci not found, GPU detection will be disabled")
    endif()
    
    if(NOT SMARTCTL_EXECUTABLE)
        message(WARNING "smartctl not found, disk health monitoring will be disabled")
    endif()
endif()

if(NANOOKJARO_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

if(NANOOKJARO_ENABLE_INSTALL)
    include(GNUInstallDirs)
    
    install(TARGETS nanookjaro_core
        EXPORT nanookjaro_coreTargets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    install(DIRECTORY include/ 
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        FILES_MATCHING PATTERN "*.hpp"
    )

    install(DIRECTORY src/hardware/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/nanookjaro/hardware
        FILES_MATCHING PATTERN "*.hpp"
    )
    
    install(DIRECTORY src/system/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/nanookjaro/system
        FILES_MATCHING PATTERN "*.hpp"
    )
    
    install(DIRECTORY src/network/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/nanookjaro/network
        FILES_MATCHING PATTERN "*.hpp"
    )
    
    install(DIRECTORY src/drivers/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/nanookjaro/drivers
        FILES_MATCHING PATTERN "*.hpp"
    )
    
    install(DIRECTORY src/maintenance/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/nanookjaro/maintenance
        FILES_MATCHING PATTERN "*.hpp"
    )
    
    install(DIRECTORY src/performance/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/nanookjaro/performance
        FILES_MATCHING PATTERN "*.hpp"
    )

    install(EXPORT nanookjaro_coreTargets
        FILE nanookjaro_coreTargets.cmake
        NAMESPACE Nanookjaro::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/nanookjaro_core
    )

    install(DIRECTORY ${CMAKE_SOURCE_DIR}/config/
        DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/nanookjaro
        FILES_MATCHING PATTERN "*.conf"
    )
endif()