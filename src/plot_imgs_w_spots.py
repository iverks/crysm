#!/usr/bin/env python3
import csv

import matplotlib.pyplot as plt
import numpy as np
import tifffile as tf
from matplotlib.widgets import Slider

import find_cred_project


def main():
    cur_dir = find_cred_project.find_cred_project()
    view_corrected = True

    # cur_dir = Path("/home/iverks/progging/master/zenodo/mordenite_cRED_1")
    # view_corrected = False
    corrected = "_corrected" if view_corrected else ""

    integrate = cur_dir / "SMV/SPOT.XDS"

    with integrate.open() as rf:
        data = csv.DictReader(
            (line for line in rf if not line.startswith("!")),
            fieldnames=(
                "x",
                "y",
                "z",
                "Intensity",
                "iseg",
                "h",
                "k",
                "l",
            ),
            delimiter=" ",
            skipinitialspace=True,
        )

        dataa = list(data)

    highest_image_number = max(
        [int(f.stem) for f in (cur_dir / f"tiff{corrected}").glob("*.tiff")]
    )
    image_number = 75
    delta = highest_image_number // 80

    fig = plt.figure()
    ax = fig.add_subplot()
    plt.subplots_adjust(bottom=0.25)
    axfreq = plt.axes([0.25, 0.15, 0.65, 0.03])
    axamplitude = plt.axes([0.25, 0.1, 0.65, 0.03])
    image_file = cur_dir / f"tiff{corrected}/{image_number:05d}.tiff"
    print(image_file)
    image = tf.imread(image_file.as_posix())
    image_shape = image.shape

    i_num_slider = Slider(
        axfreq, "Image", 0, highest_image_number, image_number, valstep=1.0
    )
    delta_slider = Slider(
        axamplitude, "delta", 0, highest_image_number / 2, delta, valstep=1.0
    )

    bgimg = ax.imshow(image + 0.001, norm="log")
    (im,) = ax.plot(
        [],
        [],
        marker="o",
        ls="",
        markerfacecolor="none",
    )

    prev_image = image_number

    def update(val):
        nonlocal prev_image
        image_number = int(i_num_slider.val)
        delta = delta_slider.val
        if image_number != prev_image:
            prev_image = image_number
            try:
                image = tf.imread(
                    str(cur_dir / f"tiff{corrected}/{image_number:05d}.tiff")
                )
            except FileNotFoundError:
                image = np.zeros(image_shape)
            bgimg.set_data(image + 0.001)

        xs = [float(d["x"]) for d in dataa]
        ys = [float(d["y"]) for d in dataa]
        zs = [float(d["z"]) for d in dataa]

        xdata = [x for x, z in zip(xs, zs) if abs(z - image_number) <= delta]
        ydata = [y for y, z in zip(ys, zs) if abs(z - image_number) <= delta]
        im.set_data(xdata, ydata)
        fig.canvas.draw()

    update(None)
    i_num_slider.on_changed(update)
    delta_slider.on_changed(update)

    plt.show()


if __name__ == "__main__":
    main()
