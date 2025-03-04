"""
This script finds the calibrated angles for each image by looking at the timestamps in their metadata.
We assume:
1. The start angle was recorded immediately before the end timestamp of the first image.
2. The end angle was recorded immediately after the start timestamp of the last image.
3. The time between acquisition and end timestamp is constant for any given dataset.
"""

from dataclasses import dataclass
from pathlib import Path

import tifffile as tf
import yaml

from lib.find_cred_project import find_cred_project


def get_timings(image: Path):
    with tf.TiffFile(image) as img:
        page: tf.TiffPage = img.pages[0]
        metadata = yaml.load(page.tags["ImageDescription"].value, Loader=yaml.Loader)
        start = float(metadata["ImageGetTimeStart"])
        end = float(metadata["ImageGetTimeEnd"])
    return start, end


@dataclass
class DatasetStat:
    start: float
    end: float
    end_times: list[float]
    names: list[int]


def get_stats_for_folder(dataset: Path):
    names = []
    start_times = []
    end_times = []
    for img in dataset.glob("*.tiff"):
        start, end = get_timings(img)
        names.append(int(img.stem))
        start_times.append(start)
        end_times.append(end)

    zipped = list(zip(names, start_times, end_times))
    zipped.sort()
    names, start_times, end_times = zip(*zipped)

    return DatasetStat(start_times[0], end_times[-1], end_times, names)


def calibrate_angles():
    cur_dir = find_cred_project()
    cred_log = (cur_dir / "cRED_log.txt").read_text(errors="ignore")
    start_angle = float(cred_log.split("Starting angle: ")[1].split(" degrees")[0])
    end_angle = float(cred_log.split("Ending angle: ")[1].split(" degrees")[0])
    print(f"Parsed angles as {start_angle} to {end_angle}")
    total_angle = end_angle - start_angle

    pets = (cur_dir / "pets.pts").read_text(errors="ignore")
    rest = pets.split("imagelist")[0]

    stats = get_stats_for_folder(cur_dir / "tiff")
    total_time = stats.end - stats.start

    with open(cur_dir / "pets-fromtime.pts", "w") as petsout:
        petsout.write(rest)
        petsout.write("imagelist\n")

        for name, time in zip(stats.names, stats.end_times):
            timefraction = (time - stats.start) / total_time
            angle = start_angle + total_angle * timefraction
            petsout.write(f"tiff/{name:05d}.tiff   {angle:.4f} {0.0:.2f}\n")

        petsout.write("endimagelist\n\n")
