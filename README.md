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

```bash
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

## Usage

The functionality of this library can be found by typing `crysm --help` or reading the functions in `src/main.py`. Below are some examples.

### Example 1: Finding correction factors for the central cross from a flatfield image

```bash
crysm find-center-cross-correction flatfield_200kV_24bit.tiff 
> Mean value of cross: 40151.59
> Mean value of central four pixels: 74076.75
> Mean value of rest of image: 18284.44
> Number of additional pixels should be verified with detector manufacturer
> --additional-pixels 4 --correction-factor 2.196 --central-four-factor 4.051354571397547
```

### Example 2: Correcting the central cross of a calibration image

```bash
crysm pets-correct-center-cross-calibration --additional-pixels 4 --correction-factor 2.196 --central-four-factor 4.051354571397547 SAED_150cm.mib WIDE_150cm.tiff
> Wrote corrected image to WIDE_150cm.tiff
```

### Example 3: Correcting the central cross of a pets project

```bash
```