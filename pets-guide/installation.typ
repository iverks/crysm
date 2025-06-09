#import "@preview/abbr:0.2.3": a as acr, s as acr_short
#import "@preview/unify:0.7.1": num, unit, qty
#import "_frames.typ": note

#let PETS = acr("PETS")

= Tool overview and Installation

The data processing procedure consists of two main steps, data reduction and structure solution and refinement.
The tools used in the procedure are listed in #ref(<tab:tools>).
An overview of key files or folders and their purposes are listed in #ref(<tab:files>).

#figure(
  caption: [Tools used in the data processing procedure.],
  table(
    columns: 4,
    [Tool], [Purpose], [Input], [Output],
    [crysm], [Utility scripts, mainly preprocessing], [], [],
    [PETS], [Data reduction, intensity determination], [.pts, .pts2], [.hkl, .ins, .cif_pets],
    [edtools], [Creating input file for SHELXT], [], [.ins],
    [SHELXT], [Structure solution], [.ins, .hkl], [.res, .hkl],
    [SHELXL], [Structure refinement], [.res, .hkl], [],
    [Olex2], [#acr_short("GUI") for SHELXT and SHELXL], [-], [-],
  ),
) <tab:tools>

#figure(
  caption: [File formats/folders and their purpose.],
  table(
    columns: 3,
    [File suffix], [Output from], [Purpose],
    [.pts], [Instamatic], [PETS input config],
    [.pts2], [PETS (`ctrl + s`)], [PETS stored state],
    "<project>_petsdata", [PETS], [PETS stored state],
    [\_shelx.hkl], [PETS integration], [Input for SHELX\ (reflexes)],
    [\_shelx.ins], [PETS integration], [Input for SHELX\ (instructions/parameters)],
  ),
) <tab:files>


== PETS

#PETS is a windows only program used for data reduction of #acr("3D ED") data from #acr("cRED") or #acr("PED"), which includes peak searching, refinement of various parameters and integration of intensities.
#PETS can be downloaded from http://pets.fzu.cz/, and requires a registration which is free for academic users.

== SHELX and Olex2

SHELX #ref(<short_history_of_shelx>)#ref(<shelxt_structure_determination>) is a collection of command line executables that can be downloaded from https://shelx.uni-goettingen.de/download.php. Like #PETS and Jana it requires a registration that is free for academic users.
Once installed, their location must be added to the PATH.
Olex2 is a windows only #acr("GUI") for the SHELX programmes, and can be downloaded from https://www.olexsys.org/olex2/.

// == Jana

// Jana is an alternative to SHELX that is notably capable of doing dynamical analysis.
// Jana is currently not used in this process, but can be downloaded from https://jana-login.fzu.cz/jana2020.
// It also requires a registration that is free for academic users.

== Python scripts: Crysm and edtools

=== Crysm

Crysm is an in-house developed collection of python scripts to aid the entire data analysis process. It requires python 3.10 or greater.
For users, we recommend the quick installation from pip using `pip install crysm`.

#note[Editable installation][For developers][
  Crysm must be cloned from https://github.com/iverks/crysm. To do so, navigate to a fitting directory and run `git clone git@github.com:iverks/crysm.git`.
  It uses `uv` as a project manager, which can be installed from https://docs.astral.sh/uv/getting-started/installation/
  To install crysm, run `uv tool install -e .` in the newly cloned folder. Any changes made to the code will automatically be reflected in the program.
  If the dependency list in `pyproject.toml` is updated, `crysm` must be uninstalled and reinstalled using `uv tool uninstall crysm; uv tool install -e .`.
]

Make sure that it is available from any location by running `crysm --help`.
You should get a message showing how to use `crysm` and listing all available commands, as shown in #ref(<fig:crysm-help-message>).

#figure(
  image("images/crysm_help_message.png"),
  caption: [Running `crysm --help` gives us the instructions for how to use crysm.],
) <fig:crysm-help-message>

Similarly it is possible to get instructions for how to use subcommands by running `crysm COMMAND --help`, shown in #ref(<fig:crysm-subcommand-help-message>).

#figure(
  image("images/crysm_command_help_message.png"),
  caption: [Running `crysm COMMAND --help` gives us the instructions for how to the specific subcommand from crysm.],
) <fig:crysm-subcommand-help-message>

If anything fails and the versions dependencies have to be changed, the package needs to be reinstalled.

=== edtools

Edtools can be installed from pip using the command `pip install edtools`. The command we use from edtools, `edtools.make_shelx` depends on one of `cctbx.python` and `sginfo`. We thus need to install either `cctbx` or `sginfo`

For Windows, installing `cctbx` is the simplest. An installation of conda is required, then `cctbx` is installed using `conda install -c conda-forge cctbx-base`. Make sure that `cctbx.python` is available for `edtools` by running `edtools.make_shelx --help`.
If the text "Either sginfo or cctbx.python must be in the path" is returned, then the location of `cctbx.python.bat` must be added to path.
The program should be in `C:\Users\USERNAME\ANACONDA_DISTRIBUTION\Library\bin\`.

For linux users, installing `sginfo` is simpler. The project can be found at https://github.com/rwgk/sginfo, cloned with `git clone git@github.com:rwgk/sginfo.git sginfo` and built with any C compiler using `clang -o sginfo sgclib.c sgfind.c sghkl.c sgio.c sgsi.c sginfo.c -lm`. The executable should either be moved to a folder on `PATH` or the folder added to `PATH`.
