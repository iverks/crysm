#!/usr/bin/env python3

import matplotlib.pyplot as plt
import numpy as np
import tifffile
import trackpy as tp

import find_cred_project


def main():
    image_id = 632
    cur_dir = find_cred_project.find_cred_project()
    image_folder = cur_dir / "tiff_corrected"

    # imgs = np.stack([tifffile.imread(f) for f in image_folder.glob("*.tiff")], axis=-1)
    # avg = np.median(imgs, axis=-1)

    img = tifffile.imread(image_folder / f"{image_id:05d}.tiff")

    diameter = 11
    minmass = 150
    img_f = tp.locate(img, diameter, minmass)

    fig, ax1 = plt.subplots(1, 1)
    tp.annotate(img_f, img, ax=ax1, imshow_style={"norm": "log"})
    plt.show()


if __name__ == "__main__":
    main()
