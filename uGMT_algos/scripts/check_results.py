#!/usr/bin/env python
import os
import sys


def encode_error(testbench_name, names):
    try:
        error_code = 1 << names.index(testbench_name)
    except ValueError:
        print "WARNING: Ignoring unexpected results file: " + testbench_name
        error_code = 0
    return error_code


def main():
    error = 0
    testbench_names = ["serializer", "ugmt_serdes"]
    file_counter = 0
    for root, folders, fnames in os.walk('results'):
        for fname in fnames:
            if fname.endswith(".results"):
                with open(os.path.join(root, fname), 'r') as fobj:
                    file_counter += 1
                    lines = fobj.readlines()
                    res = lines[-1]
                    n_err = int(res.split(":")[1].strip())
                    if n_err != 0:
                        tbname = fname.split("_tb")[0]
                        error += encode_error(tbname, testbench_names)
    if file_counter < len(testbench_names):
        return 999999
    return error


if __name__ == "__main__":
    err = main()
    print err
    sys.exit(err)
