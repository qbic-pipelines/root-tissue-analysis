#!/usr/bin/env python


import sys

import click
import numpy as np
import pandas as pd
import tifffile as tiff
from rich import print, traceback


@click.command()
@click.option('-m', '--meta', required=True, type=str, help='Path to metadata file')
@click.option('-r', '--ratios', required=True, type=str, help='Path to ratios')
@click.option('-s', '--segs', required=True, type=str, help='Path to segmentations')
@click.option('-o', '--output', default="./", type=str, help='Output path')
def main(meta: str, ratios: str, segs: str, output: str):
    """Command-line interface for rtsstat"""

    print(r"""[bold blue]
        rtsstat
        """)

    print('[bold blue]Run [green]rtsstat --help [blue]for an overview of all commands\n')
    df = pd.read_csv(meta, header=0)
    df["Ratio"], df["Zone"] = zip(*[(calc_ratio(ratios, segs, x)) for x in df['Filename']])
    df.to_csv("ratios.tsv", sep = '\t', index=False)



def calc_ratio(ratios, segs, x):
    ratio_img = tiff.imread(ratios + x + "_ratio.tif")
    ratio_img = np.nan_to_num(ratio_img)
    tif_img = np.load(segs + x + ".npy")
    ratio_ee = extract_ph(ratio_img, tif_img, 2)
    ratio_m = extract_ph(ratio_img, tif_img, 4)
    # Early elongation zone is generally a bit smaller in size.
    if ratio_m > 1.25*ratio_ee:
        ratio = ratio_m
        zone = "Meristematic Zone"
    else:
        ratio = ratio_ee
        zone = "Early Elongation Zone"
    if ratio == 0:
        return np.nan, "None"
    else:
        return ratio, zone


def extract_ph(ratio_img, tif_img, class_index):
    late_array = ratio_img[tif_img == class_index]
    # Exclude extremely small predictions, as they are likely to be FP.
    if late_array.shape[0] < 1000:
        return 0
    return np.true_divide(late_array.sum(0), (late_array != 0).sum(0))


if __name__ == "__main__":
    traceback.install()
    sys.exit(main())  # pragma: no cover
