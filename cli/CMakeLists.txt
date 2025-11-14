cmake_minimum_required(VERSION 3.20)

add_executable(nanookjaro-cli main.cpp)

target_link_libraries(nanookjaro-cli PRIVATE Nanookjaro::nanookjaro_core)

target_compile_features(nanookjaro-cli PRIVATE cxx_std_20)

if (MSVC)
    target_compile_options(nanookjaro-cli PRIVATE /W4 /WX)
else()
    target_compile_options(nanookjaro-cli PRIVATE -Wall -Wextra -Wpedantic)
endif()

# Installation rules
if(NANOOKJARO_ENABLE_INSTALL)
    include(GNUInstallDirs)
    install(TARGETS nanookjaro-cli
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endif()