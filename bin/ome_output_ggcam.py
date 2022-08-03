#!/usr/bin/env python

import itertools
import os
import sys
from glob import glob

import click
import numpy as np
import tifffile as tiff
from rich import print, traceback

@click.command()
@click.option('-i', '--imgs', required=True, type=str, help='Path to image files')
@click.option('-g', '--ggcam', required=True, type=str, help='Path to guided grad-CAM feature files')
@click.option('-o', '--output', default="./", type=str, help='Output path')
def main(imgs: str, ggcam: str, output: str):
    """Command-line interface for ome_output"""

    print(r"""[bold blue]
        ome-tiff output tool
        """)

    print('[bold blue]Run [green]ome_output --help [blue]for an overview of all commands\n')

    os.makedirs(output, exist_ok=True)

    img_list = glob(os.path.join(imgs, "*"))
    for img_path in img_list:
        
        print(img_path)
        img_name_base = os.path.splitext(os.path.basename(img_path))[0]

        brightfield_img = tiff.imread(img_path)
        brightfield_img = brightfield_img[0, :, :] # we need only the first channel

        full_image = np.zeros((512, 512, 6))
        full_image[:, :, 0] = brightfield_img

        # iterate over five classes (bg, root tissue, MZ, EEZ, LEZ)
        for class_i in range(5):
            ggcam_i = np.load(os.path.join(ggcam, img_name_base + "_ggcam_t_" + str(class_i) + ".npy"))

            full_image[:, :, class_i +1] = ggcam_i

        full_image = np.transpose(full_image, (2, 0, 1))

        with tiff.TiffWriter(os.path.join(output, img_name_base + "_ggcam.ome.tif")) as tif_file:
            tif_file.write(full_image, photometric='minisblack', metadata={'axes': 'CYX', 'Channel': {'Name': ["image", "ggcam-bg", "ggcam-tissue", "ggcam-eez", "ggcam-lez", "ggcam-mz"]}})

if __name__ == "__main__":
    traceback.install()
    sys.exit(main())  # pragma: no cover
