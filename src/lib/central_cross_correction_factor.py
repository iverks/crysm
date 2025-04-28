from pathlib import Path

import numpy as np
import tifffile as tf

from lib.mib import load_mib


def find_center_cross_correction(flatfield_image: Path):
    """Loads a flatfield image (.mib or .tiff) and calculate the intensity difference between the central cross and the rest of the image"""
    if flatfield_image.suffix == ".mib":
        img = load_mib(flatfield_image.read_bytes())[0]
    else:
        img = tf.imread(flatfield_image)
    assert img.shape == (512, 512)
    cross_mask = np.zeros_like(img)
    cross_mask[255:257, :] = 1  # Cross
    cross_mask[:, 255:257] = 1  # Cross
    # # Central 4 pixels are even more intense so we ignore them
    # cross_mask[255:257, 255:257] = 2

    cross = img[cross_mask == 1]
    rest = img[cross_mask == 0]
    cross_mean = np.mean(cross)
    rest_mean = np.mean(rest)
    factor = cross_mean / rest_mean
    num_extra_pixels = 2 if factor < 1.8 else 4
    print(f"Mean value of cross: {cross_mean:.2f}")
    print(f"Mean value of rest of image: {rest_mean:.2f}")
    print("Number of additional pixels should be verified with detector manufacturer")
    print(f"--correction-factor {factor:.3f} --additional-pixels {num_extra_pixels}")
