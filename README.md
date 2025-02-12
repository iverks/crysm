# Masterarbeidet mitt

Uhh jeg har ingen anelse hvordan man kan gjøre pakken brukbar for andre. For øyeblikket har jeg lagt src-mappen til path og kaller på filene som om de var shell scripts.


## Resten

Jeg bruker `uv` til package management. For å installere på linux/mac

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

eller på windows

```ps1
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

For å installere pakken kjører du 

```bash
uv tool install -e .
```

Pakken har flere scripts, listet under [project.scripts] i [`pyproject.toml`](./pyproject.toml). De kjøres med 

```bash
uv run <script>
```

Før eller siden skal alle helst være tilgjengelige via 

```bash
uv run crysm --help
```

### Reinstall

Om du legger til et ekstra script i pakken må du reinstallere den ved å kjøre

```bash
uv tool uninstall crysm; uv tool install -e .
```