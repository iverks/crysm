# Pets tutorial source

This guide has been moved to the [crysm project](https://github.com/iverks/crysm).

In order to compile the project, [typst](https://github.com/typst/typst) must be installed. To compile, run:

```bash
typst compile main.typ document.pdf
```

## Recommended vscode settings

For automatic compilation on save i recommend the vscode extension [tinymist](vscode:extension/myriad-dreamin.tinymist). I recommend adding the following settings to the local file `.vscode/settings.json`.

```jsonc
{
    "tinymist.typstExtraArgs": [
        "main.typ"
    ],
    "tinymist.outputPath": "$root/$dir/$name",
    "tinymist.exportPdf": "onSave",
    "tinymist.formatterMode": "typstyle",
    "editor.tabSize": 2
}
```
