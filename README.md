# CRYSM

## Installation

In order to install the package, run 

```bash
uv tool install -e .
```

This exposes the `crysm` command. To see available commands, run `crysm --help`. The commands correspond to the decorated functions in `src/main.py`.

## Installation of uv

In this package, `uv` is used for package management. To install on linux/mac, run

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

and on windows (in powershell)

```ps1
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```
