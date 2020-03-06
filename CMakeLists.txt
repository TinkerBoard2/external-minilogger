cmake_minimum_required(VERSION 3.8)

project(minilogger
    LANGUAGES C CXX
    VERSION 1.0.0)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

add_library(minilogger
	STATIC
    src/backtrace.cpp
    src/log.cpp)
target_include_directories(minilogger
	PUBLIC
		$<INSTALL_INTERFACE:include>
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
	PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}/src
)
target_compile_options(minilogger PRIVATE -g -ggdb -gdwarf)
target_compile_options(minilogger PRIVATE -rdynamic -funwind-tables)

find_package(Libunwind REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_search_module(GLIB REQUIRED glib-2.0)

target_include_directories(minilogger PRIVATE ${GLIB_INCLUDE_DIRS})
target_link_libraries(minilogger PUBLIC ${GLIB_LDFLAGS} ${LIBUNWIND_LIBRARIES})


add_subdirectory(test)
