# SPDX-License-Identifier: Apache-2.0

# Build a Zig project as an external project.  The build is done using
# zig build-obj, which will build the project into a single object
# file containing the entire Zig part of the program.

cmake_minimum_required(VERSION 3.13.1)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

project(zig_hello)

target_sources (app PRIVATE src/hooks.c)

include(ExternalProject)

set(zig_src_dir ${CMAKE_CURRENT_SOURCE_DIR})
set(zig_build_dir ${zig_src_dir})

ExternalProject_Add(
    zig_project
    PREFIX ${zig_build_dir}
    SOURCE_DIR ${zig_src_dir}
    BINARY_DIR ${zig_src_dir}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND "zig" "build-obj"
       "-OReleaseSafe"
       "-target" "arm-freestanding-eabi" "-mcpu" "cortex_m33"
       "main.zig"
    INSTALL_COMMAND ""
    BUILD_ALWAYS True
    BUILD_BYPRODUCTS
      ${zig_src_dir}/main.o)

add_library(zig_lib STATIC IMPORTED GLOBAL)

add_dependencies(
    zig_lib
    zig_project
)
set_target_properties(zig_lib PROPERTIES IMPORTED_LOCATION
    ${zig_build_dir}/main.o)

target_link_libraries(app PUBLIC zig_lib)
