import math
from pathlib import Path

import matplotlib.pyplot as plt
import tifffile as tf
from matplotlib.axes import Axes
from matplotlib.backend_bases import MouseButton, MouseEvent
from matplotlib.patches import Rectangle


def parse_dead_pixels(dead_pixels: Path) -> list[tuple[int, int]]:
    out = []
    for line in dead_pixels.read_text().strip().splitlines():
        a, b = [int(part) for part in line.strip().split()]
        out.append((a, b))
    return out


def mark_dead_pixels(image: Path, dead_pixels_path: Path | None = None):
    dead_pixels = (
        parse_dead_pixels(dead_pixels_path) if dead_pixels_path is not None else []
    )
    img = tf.imread(image)
    fig, _ax = plt.subplots()
    ax: Axes = _ax
    ax.imshow(img, norm="log")
    rects: dict[tuple[int, int], Rectangle] = {}
    for px, py in dead_pixels:
        # subtract 1 to correct for 1-indexing, and 0.5 because we draw from the center
        rect = Rectangle(
            xy=(px - 1.5, py - 1.5),
            width=1,
            height=1,
            edgecolor="r",
            facecolor="none",
            alpha=1,
        )
        rects[px, py] = ax.add_patch(rect)

    def on_click(event: MouseEvent):
        if event.button is MouseButton.LEFT and event.dblclick:
            px = int(round(event.xdata)) + 1
            py = int(round(event.ydata)) + 1
            if (px, py) not in rects:
                rect = Rectangle(
                    xy=(px - 1.5, py - 1.5),
                    width=1,
                    height=1,
                    edgecolor="r",
                    facecolor="none",
                    alpha=1,
                )
                rects[(px, py)] = ax.add_patch(rect)
            else:
                rect = rects.pop((px, py))
                rect.remove()
            ax.redraw_in_frame()

    plt.connect("button_press_event", on_click)
    plt.title("Double click to toggle dead pixels")
    plt.show()

    dead_pixels = list(rects.keys())

    with dead_pixels_path.open("w") as dp:
        for px, py in dead_pixels:
            dp.write(f"{px} {py}")
