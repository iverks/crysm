from pathlib import Path
from typer import Typer



app = Typer(name="crysm", no_args_is_help=True)


def main():
    """Alias for uv"""
    print("Still using main instead of app")
    app()


@app.command()
def pets_calibrate_angles(skip: bool = False):
    import pets
    import pets.calibrate_angles
    pets.calibrate_angles.calibrate_angles(skip_after_defocus=skip)


@app.command()
def debug():
    from pathlib import Path

    import orix.crystal_map

    cur_dir = Path(__file__).parent.parent
    phase = orix.crystal_map.Phase.from_cif(cur_dir / "mor.cif")

    print(phase.a_axis.length)
    print(phase.b_axis.length)
    print(phase.c_axis.length)


@app.command()
def compare_hkl():
    import compare_hkl as mod_compare_hkl
    mod_compare_hkl.main()

@app.command()
def plot_hkl(filename: Path | None = None):
    import compare_hkl as mod_compare_hkl
    mod_compare_hkl.plot_hkl_file(filename)

if __name__ == "__main__":
    app()
