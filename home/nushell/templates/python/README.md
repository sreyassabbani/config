# app

## Setup

Choose either setup path; both create the same project-local `.venv`:

- With [devenv](https://devenv.sh): run `devenv allow` once; the shell hook then activates
  the environment on `cd` (or run `devenv shell`).
- Without Nix: install [`uv`](https://docs.astral.sh/uv/getting-started/installation/) and
  run `uv sync`. `uv` can install a compatible Python version when needed.

After setup, use the commands below on macOS, Linux, or Windows. Nix is not required to
work on the project.

## Python deps

This project uses `uv`.

- Add dependencies with `uv add <package>`
- Sync the environment with `uv sync`
- Generate or refresh the lockfile with `uv lock`

Commit `uv.lock` so devenv and non-devenv contributors resolve the same Python dependencies.
