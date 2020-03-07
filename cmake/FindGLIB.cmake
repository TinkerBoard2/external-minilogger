include(FindPackageHandleStandardArgs)

find_package(PkgConfig REQUIRED)

if(${CMAKE_VERSION} VERSION_LESS "3.6.0")
    pkg_check_modules(GLIB2 "glib-2.0>=${MIN_GLIB_VERSION}" "gobject-2.0>=${MIN_GLIB_VERSION}" "gio-2.0>=${MIN_GLIB_VERSION}")
else()
    pkg_check_modules(GLIB2 IMPORTED_TARGET "glib-2.0>=${MIN_GLIB_VERSION}" "gobject-2.0>=${MIN_GLIB_VERSION}" "gio-2.0>=${MIN_GLIB_VERSION}")
endif()

find_package_handle_standard_args(GLib DEFAULT_MSG GLIB2_LIBRARIES GLIB2_CFLAGS GLIB2_LIBRARY_DIRS)
