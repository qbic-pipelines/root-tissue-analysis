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
@click.option('-u', '--uncert', required=True, type=str, help='Path to uncertainty map files')
@click.option('-o', '--output', default="./", type=str, help='Output path')
def main(imgs: str, uncert: str, output: str):
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
        
        uncert_map = np.load(os.path.join(uncert, img_name_base + "_uncert_.npy"))

        full_image = np.zeros((512, 512, 2))
        full_image[:, :, 0] = brightfield_img
        full_image[:, :, 1] = uncert_map
        full_image = np.transpose(full_image, (2, 0, 1))

        with tiff.TiffWriter(os.path.join(output, img_name_base + "_uncert.ome.tif")) as tif_file:
            tif_file.write(full_image, photometric='minisblack', metadata={'axes': 'CYX', 'Channel': {'Name': ["image", "uncert_map"]}})

if __name__ == "__main__":
    traceback.install()
    sys.exit(main())  # pragma: no cover
