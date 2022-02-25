#!/usr/bin/env python

# This script is based on the example at: https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/samplesheet/samplesheet_test_illumina_amplicon.csv

import argparse
import csv
import errno
import os
import shutil
import sys
import tarfile
import urllib.request
from glob import glob


def parse_args(args=None):
    Description = "Reformat nf-core/rts samplesheet file and check its contents."
    Epilog = "Example usage: python check_samplesheet.py <FILE_IN> <FILE_OUT>"

    parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
    parser.add_argument("FILE_IN", help="Input samplesheet file.")
    parser.add_argument("FILE_OUT", help="Output file.")
    return parser.parse_args(args)


def make_dir(path):
    if len(path) > 0:
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise exception


def print_error(error, context="Line", context_str=""):
    error_str = "ERROR: Please check metadata.csv -> {}".format(error)
    if context != "" and context_str != "":
        error_str = "ERROR: Please check metadata.csv -> {}\n{}: '{}'".format(
            error, context.strip(), context_str.strip()
        )
    print(error_str)
    sys.exit(1)


def check_samplesheet(file_in: str, file_out):
    """
    This function checks that the samplesheet follows the following structure:


    """
    if ".tar.gz" in file_in:
        file = tarfile.open(name=file_in, mode="r|gz")
        file.extractall('./data/')
        file.close()
        file_in = glob("./data/*")[0]
    with open(os.path.join(f'{file_in}', 'metadata.csv'), mode='r') as metadata:
        csv_reader = csv.DictReader(metadata)
        for row in csv_reader:
            if not ("Filename" in row.keys() and "Treatment" in row.keys() and "Breeding Line" in row.keys()):
                print_error("Wrong column names")
            if not (row["Filename"] and row["Treatment"] and row["Breeding Line"]):
                print_error("Empty column")
    out_dir = os.path.dirname(file_out)
    # make_dir(out_dir)
    shutil.copytree(file_in, out_dir)


def main(args=None):
    args = parse_args(args)
    check_samplesheet(args.FILE_IN, args.FILE_OUT)


if __name__ == "__main__":
    sys.exit(main())
