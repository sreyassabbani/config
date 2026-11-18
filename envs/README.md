# Shared devenv environments

Bind a project directory to one of these instead of giving it its own `devenv.nix`:

```nu
devenv --from path:~/config/envs/python allow
```

Bindings for existing projects are declared in [`home/devenv.nix`](../home/devenv.nix)
and re-applied on every switch. Every env pins the same nixpkgs revision so
projects share one copy of each toolchain in `/nix/store`.
