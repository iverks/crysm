# To be run from root of collected data. Specifically made for zeolite data collected
from pathlib import Path

import hyperspy.io as hs_io
import numpy as np
import tifffile as tf
from tqdm import tqdm

cur_dir = Path(__file__).parent


# Copied from instamatic
def get_deadpixels(img: np.ndarray) -> np.ndarray:
    """Get coordinates of dead pixels in the image."""
    return np.argwhere(img == 0)


# Copied from instamatic
def remove_deadpixels(img: np.ndarray, deadpixels: np.ndarray, delta=1) -> np.ndarray:
    """Remove dead pixels from the images by replacing them with the average of
    neighbouring pixels from up to delta pixels away"""
    d = delta

    for i, j in deadpixels:
        row_start = max(0, i - d)
        row_end = min(img.shape[0], i + d + 1)
        col_start = max(0, j - d)
        col_end = min(img.shape[1], j + d + 1)

        neighbours = img[row_start:row_end, col_start:col_end]
        mask = np.ones_like(neighbours, dtype=bool)
        self_i, self_j = i - row_start, j - col_start
        mask[self_i, self_j] = False

        img[i, j] = np.mean(neighbours[mask])
    return img


# Copied from instamatic
def get_center_pixel_correction(img: np.ndarray) -> float:
    """Get the correction factor for the center pixels."""
    center = np.sum(img[255:261, 255:261])
    edge = np.sum(img[254:262, 254:262]) - center

    avg1 = center / 36.0
    avg2 = edge / 28.0
    k = avg2 / avg1

    print("timepix central pixel correction factor:", k)
    return k


# Copied from instamatic
def apply_flatfield_correction(
    img: np.ndarray, flatfield: np.ndarray, darkfield: np.ndarray | None = None
):
    """Apply flatfield correction to image.

    https://en.wikipedia.org/wiki/Flat-field_correction
    """
    if flatfield.shape != img.shape:
        msg = f"Flatfield not applied: image {img.shape} and flatfield {flatfield.shape} do not match shapes."
        print(msg)
        return img

    if darkfield is None:
        ret = img * np.mean(flatfield) / flatfield
    else:
        gain = np.mean(flatfield - darkfield) / (flatfield - darkfield)
        ret = (img - darkfield) * gain

    return ret


# Copied from instamatic
def apply_center_pixel_correction(img: np.ndarray, k=1.19870594245):
    """Correct the intensity of the center pixels."""
    img[255:261, 255:261] = img[255:261, 255:261] * k
    return img


# Copied from instamatic
def apply_corrections(img: np.ndarray, deadpixels: np.ndarray | None = None):
    """Apply image corrections."""
    if deadpixels is None:
        deadpixels = get_deadpixels(img)
    img = remove_deadpixels(img, deadpixels)
    img = apply_center_pixel_correction(img)
    return img


# Adapted from instamatic
def get_flatfield():
    for img_file in cur_dir.glob("**/flatfield_200kV_24bit.mib"):
        flatfield_img: np.ndarray = hs_io.load(
            str(img_file), navigation_shape=(1,)
        ).data
        flatfield_img = flatfield_img.astype(np.uint16)
        dead_pixels = get_deadpixels(flatfield_img)
        flatfield_img = remove_deadpixels(flatfield_img, dead_pixels, delta=10)
        # wish i found a better way, but tune these numbers until it looks good
        n_dark_spots = 50
        for _ in range(n_dark_spots):
            outliers = np.argwhere(flatfield_img == np.min(flatfield_img))
            flatfield_img = remove_deadpixels(flatfield_img, outliers, delta=10)
    return flatfield_img


def remove_defective_bright_pixel(image: np.ndarray):
    outliers = np.argwhere(image == np.max(image))
    image = remove_deadpixels(image, outliers, delta=10)
    return image


def main():
    flatfield_img = get_flatfield()
    flatfield_img = remove_defective_bright_pixel(flatfield_img)

    for particle in tqdm(list(cur_dir.glob("Particle*")), desc="Particles"):

        for collection in tqdm(
            sorted(list(particle.iterdir())), desc="Collections", leave=False
        ):
            corrected_folder = collection / "tiff_corrected"
            corrected_folder.mkdir(exist_ok=True)
            print(f"{particle.name} {collection.name}")

            for img_f in tqdm(
                list((collection / "tiff").iterdir()), desc="Images", leave=False
            ):
                img = tf.imread(str(img_f))
                corrected = apply_flatfield_correction(img, flatfield_img)
                corrected = corrected.astype(np.uint16)

                corrected = remove_defective_bright_pixel(corrected)
                outfile = corrected_folder / img_f.name

                tf.imwrite(str(outfile), corrected)


if __name__ == "__main__":
    main()
