import os
import re
import shlex
import shutil
import subprocess
from pathlib import Path

from rich import print

from lib.find_cred_project import find_cred_project


def parse_composition(composition: str) -> list[tuple[str, int]]:
    """
    Parses an input composition to

    >>> parse_composition("SiO") == [("Si", 1), ("O", 1)]
    True
    >>> parse_composition("SiO2") == [("Si", 1), ("O", 2)]
    True
    >>> parse_composition("SiO") == [("Si", 1), ("O", 1)]
    True
    >>> parse_composition("OF") == [("O", 1), ("F", 1)]
    True
    >>> parse_composition("O2F") == [("O", 2), ("F", 1)]
    True
    >>> parse_composition("OF2") == [("O", 1), ("F", 2)]
    True
    >>> parse_composition("Si O") == [("Si", 1), ("O", 1)]
    True
    >>> parse_composition("Si") == [("Si", 1)]
    True
    """

    materials = composition.split()

    if len(materials) == 1:  # Maybe camelcased
        materials = re.findall("[A-Z][^A-Z]*", composition)

    output: list[tuple[str, int]] = []
    for material in materials:
        element = "".join([c for c in material if not c.isdigit()])
        count_str = "".join([c for c in material if c.isdigit()])
        count = int(count_str) if count_str else 1

        if element == "":  # Assume user supplied Si 2 O 4
            if not len(output) > 0:
                raise ValueError(
                    "Composition parsing failed due to first element being a number"
                )
            if not output[-1][1] == 1:
                raise ValueError(
                    "Composition parsing failed due to receiving two numbers in a row"
                )
            output[-1] = (output[-1][0], count)
            continue
        output.append((element, count))

    return output


def run_shelx(pts_file: Path, composition: str, shelxt_args: list[str]):
    cur_dir = find_cred_project(pts_file.parent)
    pets_contents = pts_file.read_text(errors="ignore")
    integration_mode = re.findall("integrationmode .*\n", pets_contents)
    if integration_mode is None:
        raise RuntimeError("Couldn't find integrationmode line in .pts2 file")
    laue_class = int(integration_mode[0].split()[3])
    if laue_class == 0:
        print("[Yellow]Warning: Laue class set to auto")
    elif laue_class == 1:
        print("[Yellow]Warning: Laue class set to -1")

    elements = parse_composition(composition)
    print("Found composition", "".join(f"{el}{cnt}" for el, cnt in elements))
    shelx_folder = cur_dir / "shelx"
    os.makedirs(shelx_folder, exist_ok=True)
    hkl_file = pts_file.with_name(pts_file.stem + "_shelx.hkl")
    ins_file = pts_file.with_name(pts_file.stem + "_shelx.ins")
    assert hkl_file.exists()
    assert ins_file.exists()
    shutil.copyfile(hkl_file, shelx_folder / hkl_file.name)
    ins_string = ins_file.read_text()
    sfac = "SFAC " + " ".join([el[0] for el in elements])
    cell = "CELL " + " ".join([str(el[1]) for el in elements])
    ins_string = re.sub("SFAC.*\n", sfac, ins_string)
    ins_string = re.sub("CELL.*\n", cell, ins_string)
    (shelx_folder / ins_file.name).write_text(ins_string)
    subprocess.call(shlex.split(f"shelx {ins_file.stem} -l{laue_class}") + shelxt_args)


if __name__ == "__main__":
    import doctest

    doctest.testmod()
