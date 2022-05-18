# Basic configuration for Rust development.
{ pkgs ? import <nixos> {} }:
let
in
pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.cargo
    pkgs.zig
  ];
}
