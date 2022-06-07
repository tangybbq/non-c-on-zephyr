# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(hello_world)

target_sources(app PRIVATE src/main.c)

# Build and bring in the rust package as an "external project".
include(ExternalProject)

set(rust_hello_src_dir ${PROJECT_SOURCE_DIR})
set(rust_hello_build_dir ${rust_hello_src_dir})

ExternalProject_Add(
        rust_hello_project
        PREFIX ${standlone_build_dir}
        SOURCE_DIR ${rust_hello_src_dir}
        BINARY_DIR ${rust_hello_src_dir}
        CONFIGURE_COMMAND ""
        # For the build to always be run, so that changes in the Rust
        # code are detected.
        BUILD_ALWAYS TRUE
        BUILD_COMMAND
                "cargo" # "+nightly"
                 "build"
                 "--target" "thumbv7m-none-eabi"
                  "--release"
        INSTALL_COMMAND ""
        BUILD_BYPRODUCTS
          ${rust_hello_build_dir}/target/thumbv7m-none-eabi/release/librust_hello.a
)

add_library(rust_hello_lib STATIC IMPORTED GLOBAL)

add_dependencies(
        rust_hello_lib
        rust_hello_project
)

set_target_properties(rust_hello_lib PROPERTIES IMPORTED_LOCATION
  ${rust_hello_build_dir}/target/thumbv7m-none-eabi/release/librust_hello.a)

# Add our application, along with -lgcc
target_link_libraries(app PUBLIC rust_hello_lib gcc)
