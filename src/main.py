from pathlib import Path
from typing import Annotated

import typer
from typer import Typer

app = Typer(name="crysm", no_args_is_help=True)


@app.command(
    help="Calibrate the angle of each image based on the timestamps in their metadata"
)
def pets_calibrate_angles(
    range: Annotated[
        float,
        typer.Option(help="Estimaged percentage of total angle range really spanned"),
    ] = 100,
    skip: Annotated[bool, typer.Option(help="Skip first frame after defocus")] = False,
):  # noqa: F821
    import pets
    import pets.calibrate_angles

    pets.calibrate_angles.calibrate_angles(percentage=range, skip_after_defocus=skip)


@app.command(
    help="Print lines to add to XDS.INP to correct the rotation axis and detector distance"
)
def xds_calibrate(
    pixel_size: Annotated[
        float,
        typer.Option(
            help="Calibrated pixel size, depends on camera length. Suggested values: 120cm -> 0.00947, 150cm -> 0.007929, 200cm -> 0.006167"
        ),
    ] = 0.007929,
    rotation_axis: Annotated[
        float,
        typer.Option(help="Rotation axis in degrees. Default 231 degrees."),
    ] = 231,
):
    import xds.calibrate

    xds.calibrate.calibrate(rotation_axis=rotation_axis, pixel_size=pixel_size)


@app.command(help="Compare the indexed reflections in SMV/INTEGRATE.HKL and pets.hkl")
def compare_hkl():
    import compare_hkl as mod_compare_hkl

    mod_compare_hkl.main()


@app.command(help="Plot the distribution of indexed peaks in a pets .hkl-file")
def plot_hkl(filename: Path | None = None):
    import compare_hkl as mod_compare_hkl

    mod_compare_hkl.plot_hkl_file(filename)


@app.command(help="Plot the rocking curve from a .cml-file")
def plot_camel(filename: Annotated[Path, typer.Argument(help="The .cml file to plot")]):
    from matplotlib import pyplot as plt

    from pets.camel import parse_camel, plot_camel

    data = parse_camel(filename)
    _ax = plot_camel(data)
    plt.show()


if __name__ == "__main__":
    app()
