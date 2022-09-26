#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#

"""
A simple tool to download yuketang slides.
"""

import sys
import json
import requests
import os
from argparse import ArgumentParser


def main():
    argparser = ArgumentParser()
    argparser.add_argument('--dir', help='download directory',
                           default='/mnt/d/Downloads/ykt_ppt_temp')
    args = argparser.parse_args()

    raw_response = sys.stdin.read()
    json_data = json.loads(raw_response)
    slides_data = json_data['data']['slides']

    download_dir = args.dir
    os.makedirs(download_dir, 0o755, True)
    for slide_entry in slides_data:
        idx = slide_entry['index']
        cover_url = slide_entry['cover']
        filename = '%s/%03d.png' % (download_dir, idx)
        print('download %s to %s' % (cover_url, filename))
        open(filename, 'wb').write(requests.get(cover_url).content)
    os.chdir(download_dir)
    os.system('convert *.png 1.pdf')


if __name__ == '__main__':
    main()
