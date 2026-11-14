# Shared project dev shells. Use from a project's `.envrc`:
#
#   use flake ~/config#cpp
{ pkgs }:
let
  llvm = pkgs.llvmPackages_21;
  mkLlvmShell = (pkgs.mkShell.override { stdenv = llvm.stdenv; });

  cppPackages = [
    llvm.clang-tools # clangd, clang-format
    llvm.lldb # lldb-dap
    pkgs.cmake
  ];

  pythonPackages = with pkgs; [
    python3
    python3Packages.debugpy
    uv
    ruff
    basedpyright
  ];

  # Keep uv on the Nix Python and put the venv in the project.
  pythonHook = ''
    export UV_PYTHON_DOWNLOADS=never
    export UV_PYTHON="$(command -v python)"
    export UV_PROJECT_ENVIRONMENT="$PWD/.venv"

    if [ ! -d "$UV_PROJECT_ENVIRONMENT" ]; then
      uv venv --quiet --python "$UV_PYTHON" "$UV_PROJECT_ENVIRONMENT"
    fi

    . "$UV_PROJECT_ENVIRONMENT/bin/activate"
  '';
in
{
  cpp = mkLlvmShell { packages = cppPackages; };

  python = pkgs.mkShellNoCC {
    packages = pythonPackages;
    shellHook = pythonHook;
  };

  cpp-python = mkLlvmShell {
    packages = cppPackages ++ pythonPackages;
    shellHook = pythonHook;
  };

  rust = pkgs.mkShell {
    packages = with pkgs; [
      cargo
      rustc
      rustfmt
      clippy
      rust-analyzer
    ];
    RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
  };
}
