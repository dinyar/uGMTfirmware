#!/usr/bin/env python
import os
import sys


def encode_error(testbench_name):
    if testbench_name == "GMT":
        return 1
    if testbench_name == "serializer":
        return 2
    if testbench_name == "deserializer":
        return 4
    if testbench_name == "SortAndCancel":
        return 8
    if testbench_name == "ugmt_serdes":
        return 16
    if testbench_name == "isolation":
        return 32


def main():
    error = 0
    for root, folders, fnames in os.walk('results'):
        for fname in fnames:
            if fname.endswith(".results"):
                with open(os.path.join(root, fname), 'r') as fobj:
                    lines = fobj.readlines()
                    res = lines[-1]
                    n_err = int(res.split(":")[1].strip())
                    if n_err != 0:
                        tbname = fname.split("_tb")[0]
                        error += encode_error(tbname)
    return error


if __name__ == "__main__":
    err = main()
    print err
    sys.exit(err)
