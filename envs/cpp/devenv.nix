{ pkgs, ... }:
let
  llvm = pkgs.llvmPackages_21;
in
{
  stdenv = llvm.stdenv;

  packages = [
    llvm.clang-tools # clangd, clang-format
    llvm.lldb # lldb-dap
    pkgs.cmake
  ];
}
