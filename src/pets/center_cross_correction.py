from pathlib import Path

import numpy as np
import tifffile as tf
from tqdm import tqdm


def jitted_image_correct(
    img: np.ndarray, additional_pixels: int, correction_factor: float
) -> np.ndarray:
    out_img = np.zeros((512 + additional_pixels, 512 + additional_pixels))
    post_gap = 257 + additional_pixels
    # Copying image and adding gap
    out_img[:255, :255] = img[:255, :255]
    out_img[post_gap:, :255] = img[257:, :255]
    out_img[:255, post_gap:] = img[:255, 257:]
    out_img[post_gap:, post_gap:] = img[257:, 257:]
    # Adding in the smeared central cross
    smear = additional_pixels // 2 + 1
    # Vertical left
    out_img[255 : 255 + smear, :255] = img[255, :255] / correction_factor
    out_img[255 : 255 + smear, post_gap:] = img[255, 257:] / correction_factor
    # Vertical right
    out_img[post_gap - smear : post_gap, :255] = img[256, :255] / correction_factor
    out_img[post_gap - smear : post_gap, post_gap:] = img[256, 257:] / correction_factor
    # Horizontal top
    out_img[:255, 255 : 255 + smear] = img[:255, 255:256] / correction_factor
    out_img[post_gap:, 255 : 255 + smear] = img[257:, 255:256] / correction_factor
    # Horizontal bottom
    out_img[:255, post_gap - smear : post_gap] = img[:255, 256:257] / correction_factor
    out_img[post_gap:, post_gap - smear : post_gap] = (
        img[257:, 256:257] / correction_factor
    )

    # Central square
    out_img[255 : 255 + smear, 255 : 255 + smear] = img[255, 255] / correction_factor
    out_img[post_gap - smear : post_gap, 255 : 255 + smear] = (
        img[256, 255] / correction_factor
    )
    out_img[255 : 255 + smear, post_gap - smear : post_gap] = (
        img[255, 256] / correction_factor
    )
    out_img[post_gap - smear : post_gap, post_gap - smear : post_gap] = (
        img[256, 256] / correction_factor
    )
    return out_img


def correct_center_cross_image(
    image: Path, out_file: Path, correction_factor: float, additional_pixels: int
):
    """
    Creates a copy of an image corrected for the central cross defect of the detector.
    Metadata is not preserved

    Args:
        image (Path):     Path to input image,  e.g. tiff/00001.tiff
        out_image (Path): Path to output image, e.g. tiff/00001.wide.tiff
        correction_factor (float): Factor of intensity of a pixel on the center cross compared to the
            bulk pixels. Should be calculated from one or more flatfield images.
        additional_pixels (int): Number of pixels to add in the gap. Should be provided by manufacturer.
            Common valueas are either 2 or 4. If correction_factor is greater than 2.0,
            the number of additional pixels should be greater than 2.
            2 pixels means 1 pixel is smeared to 2 (which adds one pixel on each side).
            4 pixels means 1 pixel is smeared to 3 (which adds two pixels on each side).
    """
    with image.open("rb") as handle:
        img = tf.imread(handle)
    assert img.shape == (512, 512), "Only images of 512 by 512 are supported for now"
    assert additional_pixels % 2 == 0, "Only even numbered gap sizes are supported"
    out_img = jitted_image_correct(img, additional_pixels, correction_factor)

    with out_file.open("wb") as handle:
        tf.imwrite(handle, out_img)


def correct_center_cross(
    dataset: Path, correction_factor: float, additional_pixels: int
):
    corr_folder = dataset / "tiff_corr"
    corr_folder.mkdir(exist_ok=True)
    in_folder = dataset / "tiff"
    infiles = list(in_folder.glob("*.tiff"))

    for in_file in tqdm(infiles):
        out_file = corr_folder / in_file.relative_to(in_folder)

        correct_center_cross_image(
            in_file,
            out_file,
            correction_factor,
            additional_pixels,
        )

    print(f"Wrote {len(infiles)} corrected images to {corr_folder}")
