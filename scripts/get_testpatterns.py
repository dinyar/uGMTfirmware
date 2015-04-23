#!/usr/bin/env python

import urllib
import json
import argparse
import os

testTypes = {}
testTypes["algorithm"] = ""
testTypes["integration"] = "integration_"
testTypes["deserializer"] = "deserializer_"
testTypes["serializer"] = "serializer_"

def get_addresses(pattern_type):
    '''
    Gets the download URLs through the github-API.
    '''
    fobj = urllib.urlopen('https://api.github.com/repos/jlingema/uGMTScripts/contents/ugmt_patterns/data/patterns/{tp}'.format(tp=pattern_type))
    return [x['download_url'] for x in json.loads(fobj.read())]


def parse_options():
    '''
    Specify which patterns to download and where to store
    '''
    desc = "Pattern check-out tool"

    parser = argparse.ArgumentParser(description=desc, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('pattern_type', type=str, default='testbench', help='Pattern types you want to checkout.')
    parser.add_argument('--outpath', type=str, dest='outpath', default='patterns', help='Where files should be stored')
    opts = parser.parse_args()

    return opts


def main():
    options = parse_options()

    # check if directory exists, otherwise create.
    if not os.path.exists(options.outpath):
        os.makedirs(options.outpath)

    # get the addresses for download
    addresses = get_addresses(options.pattern_type)
    # check if sub-folder exists:
    folder_name = options.outpath
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)
    # download the pattern files.

    print testTypes["algorithm"]

    for add in addresses:
        fname = add.split('/')[-1]
        urllib.urlretrieve(add, os.path.join(folder_name, fname))


if __name__ == "__main__":
    main()
