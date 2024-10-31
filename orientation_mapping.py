from pathlib import Path

import imageio.v3 as imageio
import matplotlib.pyplot as plt
import orix
import orix.crystal_map
import orix.quaternion
import orix.sampling
from diffpy.structure import Atom, Lattice, Structure


def create_crystal_map():
    a = 5.430986  # lattice parameter in Å
    atoms = (
        Atom("Si", (0, 0, 0)),
        Atom("Si", (0.5, 0, 0.5)),
        Atom("Si", (0, 0.5, 0.5)),
        Atom("Si", (0.5, 0.5, 0)),
    )
    lattice = Lattice(a, a, a, 90, 90, 90)
    phase = orix.crystal_map.Phase(
        name="Si", space_group=227, structure=Structure(atoms, lattice)
    )
    return phase


def main():
    dataset = "Si_4"
    data_folder = Path(f"../si_data/{dataset}/tiff")

    for img_file in sorted(data_folder.iterdir()):
        img = imageio.imread(img_file)

        plt.imshow(img)
        plt.show()

        break


if __name__ == "__main__":
    main()
