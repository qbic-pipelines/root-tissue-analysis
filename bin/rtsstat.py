#!/usr/bin/env python

import itertools
import os
import sys

import click
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import tifffile as tiff
from rich import print, traceback
from statannotations.Annotator import Annotator


@click.command()
@click.option('-m', '--meta', required=True, type=str, help='Path to metadata file')
@click.option('-r', '--ratios', required=True, type=str, help='Path to metadata file')
@click.option('-s', '--segs', required=True, type=str, help='Path to metadata file')
@click.option('-o', '--output', default="./", type=str, help='Path to write the output to')
def main(meta: str, ratios: str, segs: str, output: str):
    """Command-line interface for rtsstat"""

    print(r"""[bold blue]
        rtsstat
        """)

    print('[bold blue]Run [green]rtsstat --help [blue]for an overview of all commands\n')
    df = pd.read_csv(meta, header=0)
    sns.set(style="darkgrid", font_scale=1.5, palette="colorblind",
            rc={"lines.linewidth": 2, 'grid.linestyle': '--'})
    plt.rcParams["figure.figsize"] = (10 * 1.62, 10)  # (w, h)
    df["Ratio"], df["Zone"] = zip(*[(calc_ratio(ratios, segs, x)) for x in df['Filename']])
    df.to_csv("ratios.csv", index=False)
    font_options = {
        "axes.labelsize": 23,
        "font.size": 23,
        "legend.fontsize": 21,
        'legend.title_fontsize': 23,
        "xtick.labelsize": 21,
        "ytick.labelsize": 21,
    }
    plt.rcParams.update(font_options)
    df = df.dropna()
    product = set(itertools.product(df['Breeding Line'], df['Treatment']))
    box_pairs = ([(a, b) for a, b in itertools.combinations(product, 2) if a[0] == b[0]])
    output = output.replace(" ", "_")
    os.makedirs(output, exist_ok=True)
    for zone in df["Zone"].unique():
        ax = sns.boxplot(x="Breeding Line", y="Ratio", hue="Treatment",
                         data=df[df["Zone"] == zone], showmeans=True, meanprops={"marker": "+",
                                                                                 "markeredgecolor": "black",
                                                                                 "markersize": "10"})
        annotator = Annotator(ax, box_pairs, data=df, x="Breeding Line", y="Ratio", hue="Treatment")
        annotator.configure(test='t-test_welch', show_test_name=False, text_format='simple', loc='inside')
        annotator.apply_and_annotate()
        plt.tight_layout()
        plt.savefig(f'{output}/boxplot_ratio_{zone}.pdf', bbox_inches='tight')
        plt.close()


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
