# Copyright 2016, Max Planck Society.
# Not licensed
# author Raffi Enficiaud

# this file contains all the necessary to link against thirdparty libraries

# location of the stored thirdparty archives
set(thirdparty_dir ${CMAKE_SOURCE_DIR}/thirdparty)

# the location where the archives will be deflated, to avoid pollution
# of the source tree
set(thirdparties_deflate_directory ${CMAKE_BINARY_DIR}/external_libs_deflate)
if(NOT EXISTS ${thirdparties_deflate_directory})
  file(MAKE_DIRECTORY ${thirdparties_deflate_directory})
endif()

# this module may be used to find system installed libraries on Linux
if(UNIX AND NOT APPLE)
  find_package(PkgConfig)
endif()


# Python libraries, required
find_package(PythonLibs REQUIRED)
find_package(PythonInterp REQUIRED)

# numpy
execute_process(
  COMMAND ${PYTHON_EXECUTABLE} -c "import numpy; print (numpy.get_include())"
  OUTPUT_VARIABLE NUMPY_INCLUDE_PATH
  ERROR_VARIABLE  NUMPY_ERROR
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )
if(NOT (NUMPY_ERROR STREQUAL "") OR (NUMPY_INCLUDE_PATH STREQUAL ""))
  message(FATAL_ERROR "[numpy] the following error occured: ${NUMPY_ERROR} - Consider setting PYTHON_ROOT in the environment")
endif()
message(STATUS "[numpy] found headers in ${NUMPY_INCLUDE_PATH}")


# cgal
set(CGAL_MAJOR_VERSION 4)
set(CGAL_MINOR_VERSION 7)
set(CGAL_VERSION ${CGAL_MAJOR_VERSION}.${CGAL_MINOR_VERSION})
set(LIBCGAL CGAL-${CGAL_MAJOR_VERSION}.${CGAL_MINOR_VERSION})
set(libcgalroot ${thirdparties_deflate_directory}/${LIBCGAL})

if(NOT EXISTS ${libcgalroot})
  message(STATUS "Untarring ${LIBCGAL}")
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar xzf ${thirdparty_dir}/${LIBCGAL}.tar.gz
    WORKING_DIRECTORY ${thirdparties_deflate_directory})
endif()

if(NOT EXISTS ${libcgalroot}/include/CGAL/compiler_config.h)
  message(STATUS "[CGAL] creating empty configuration file for header only compilation")
  file(WRITE 
       ${libcgalroot}/include/CGAL/compiler_config.h
       "// automatically generated by mesh cmake")
endif()



# boost (needed by CGAL)
if(NOT BOOST_ROOT)
  message(STATUS "[BOOST] Boost root not configured, taking the system boost version")
  set(MESH_BOOST_FROM_SYSTEM TRUE)
else()
  message(STATUS "[BOOST] Boost root directory set to ${BOOST_ROOT}")
  set(MESH_BOOST_FROM_SYSTEM FALSE)
endif()

if(UNIX AND NOT APPLE AND NOT MESH_BOOST_FROM_SYSTEM)
  message(WARNING "[BOOST] you are setting a different boost than the one provided by the system. This option should be taken with care.")
endif()

set(Boost_ADDITIONAL_VERSIONS   
    "1.54" "1.54.0" "1.55" "1.55.0" "1.56" "1.56.0" "1.57.0" "1.58" "1.58.0" "1.59" "1.59.0"
    "1.60" "1.60.0" "1.61" "1.61.0")


add_definitions(-DBOOST_ALL_NO_LIB)   # disable auto link
set(Boost_USE_STATIC_LIBS OFF)        # linking with static library version (not used because of the header only)
if(NOT Boost_USE_STATIC_LIBS)
  # link against dynamic libraries
  add_definitions(-DBOOST_ALL_DYN_LINK)
endif()

# if we are using the system version, we do not want to have the exact version embedded in the rpath/ldd
if(MESH_BOOST_FROM_SYSTEM)
  set(Boost_REALPATH OFF)
else()
  set(Boost_REALPATH ON)
endif()

set(Boost_USE_MULTITHREADED ON)
set(Boost_DEBUG ON)
set(Boost_DETAILED_FAILURE_MSG ON)
if(DEFINED BOOST_ROOT)
  set(Boost_NO_SYSTEM_PATHS ON)
else()
  set(Boost_NO_SYSTEM_PATHS OFF)
endif()
set(Boost_NO_BOOST_CMAKE ON)

# only the header locations
find_package(Boost 1.59)

