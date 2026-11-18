# Shared devenv environments

Every env here pins the same nixpkgs revision, so projects share one copy of each
toolchain in `/nix/store`. A project on another revision gets its own copy of Python,
Rust, LLVM, …: often gigabytes, with no warning.

## Using one

- **Scratch or nested dirs:** bind instead of adding files. Bindings for existing
  projects live in [`home/devenv.nix`](../home/devenv.nix) and are re-applied on switch.

  ```nu
  devenv --from path:~/config/envs/python allow
  ```

- **New repos:** run `ds` (`ds py`, `ds rs`, `ds js`, `ds cpp`), which copies an env's
  `devenv.nix` and `devenv.yaml` into the project. Use it rather than `devenv init`:
  `devenv init` pins `cachix/devenv-nixpkgs/rolling`, and devenv has no user-level
  setting to change that default. The copy is a snapshot; later fixes here don't reach it.

## Bumping the pin

Change the `url` in every `envs/*/devenv.yaml` together, matching `nixpkgs-unstable` in
[`flake.lock`](../flake.lock). Projects with their own `devenv.yaml` keep their pin until
bumped by hand.
