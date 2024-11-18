# Masterarbeidet mitt

Jeg bruker `uv` til package management. For å installere 

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

eller 

```ps1
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

For å installere dependencies

```bash
uv sync
```

Hvis du nekter å installere `uv` mener jeg det skal være mulig å installere dependencies med

```bash
pip install -e .
```

men hvorfor være så vrang.