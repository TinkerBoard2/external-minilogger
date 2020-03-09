cmake_minimum_required(VERSION 3.8...3.16 FATAL_ERROR)

project(minilogger
    LANGUAGES C CXX
    VERSION 1.0.0)

list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_LIST_DIR}/cmake)

if (NOT APPLE)
set(MIN_Libunwind_VERSION 1.31)
find_package(Libunwind REQUIRED)
endif()
set(MIN_GLIB_VERSION 2.32.0)
find_package(GLIB REQUIRED)

add_library(minilogger
    STATIC
    src/backtrace.cpp
    src/log.cpp)

add_library(MiniLogger::MiniLogger ALIAS minilogger)

if (NOT APPLE)
    target_compile_options(minilogger PRIVATE -rdynamic)
endif()
target_compile_options(minilogger PUBLIC ${GLIB2_CFLAGS})
target_compile_options(minilogger PRIVATE -fno-exceptions -fno-rtti)
target_compile_options(minilogger PRIVATE -fstack-protector-all -fstack-check)
target_compile_options(minilogger PRIVATE -Wno-variadic-macros)
target_compile_options(minilogger PRIVATE -g -ggdb -gdwarf)
target_compile_options(minilogger PRIVATE -funwind-tables)
target_compile_options(minilogger PRIVATE
    $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:
    -Wall -Wextra -Wpedantic>)

target_compile_features(minilogger PRIVATE cxx_auto_type)
target_compile_features(minilogger PRIVATE cxx_std_11)

target_include_directories(minilogger
    PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/minilogger>
        $<BUILD_INTERFACE:${GLIB2_INCLUDE_DIR}>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

link_directories(BEFORE ${GLIB2_LIBRARY_DIRS})

target_link_libraries(minilogger
    PUBLIC 
    ${GLIB2_LIBRARIES}
)

if (NOT APPLE)
target_link_libraries(minilogger
    PUBLIC
    ${LIBUNWIND_LIBRARIES}
)
endif()

include(GNUInstallDirs)
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/MiniLogger)

install(TARGETS minilogger
    EXPORT minilogger-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

set_target_properties(minilogger PROPERTIES EXPORT_NAME MiniLogger)

install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(EXPORT minilogger-targets
    FILE
    MiniLoggerTargets.cmake
    NAMESPACE
    MiniLogger::
    DESTINATION
    ${INSTALL_CONFIGDIR}
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/MiniLoggerConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)


configure_package_config_file(${CMAKE_CURRENT_LIST_DIR}/cmake/MiniLoggerConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MiniLoggerConfig.cmake
    INSTALL_DESTINATION ${INSTALL_CONFIGDIR}
)

install(FILES
    ${CMAKE_CURRENT_LIST_DIR}/cmake/FindGLIB.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/FindLibunwind.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/MiniLoggerConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/MiniLoggerConfigVersion.cmake
    DESTINATION ${INSTALL_CONFIGDIR}
)

configure_file(${CMAKE_CURRENT_LIST_DIR}/cmake/FindLibunwind.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/FindLibunwind.cmake
    COPYONLY)

export(EXPORT minilogger-targets
    FILE ${CMAKE_CURRENT_BINARY_DIR}/MiniLoggerTargets.cmake
    NAMESPACE MiniLogger::)

export(PACKAGE MiniLogger)

enable_testing()
add_subdirectory(test)
