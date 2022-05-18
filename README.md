# Using Non-C languages with Zephyr

This repository contains example programs for my presentation on using
Non-C languages with Zephyr.  There are numbered directories, named
after each of the examples.

All of the examples, beyond the initial per-language "Hello World"
programs assume that the Zephyr build environment has been setup.
There is a shell.nix in each directory that can be used to recreate
the environments that I use for the builds.  Because of conflicts with
gcc and clang, some of the setups are a little complicated, as we
can't use the gcc-based Zephyr SDK.

- 01-rust-hello
  Hello world example in Rust.
