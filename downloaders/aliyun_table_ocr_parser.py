#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2023 StrayWarrior <i@straywarrior.com>

"""
A simple tool to parse result of aliyun table OCR API.
"""


import sys
import json


def main():
    ret = json.loads(sys.stdin.read())
    data = ret['data']['prism_tablesInfo'][0]
    x_size = data['xCellSize']
    y_size = data['yCellSize']
    last_y = -1
    current_row = ''
    for cell_info in data['cellInfos']:
        if last_y != cell_info['yec']:
            print(current_row)
            current_row = ''
            last_y = cell_info['yec']
        if cell_info['xec'] != 0:
            current_row += '\t'
        current_row += cell_info['word']
    print(current_row)


if __name__ == '__main__':
    main()
