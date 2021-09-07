#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2020 StrayWarrior <i@straywarrior.com>
#
# Distributed under terms of the MIT license.

"""
A simple tool to replace background color for PDF files.
"""

from PyPDF2 import PdfFileReader, PdfFileWriter
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', required=True)
    parser.add_argument('-o', '--output')
    parser.add_argument('-t', '--template', default='color.template.pdf')

    args = parser.parse_args()

    tpl_reader = PdfFileReader(open(args.template, "rb"))
    tpl_page = tpl_reader.getPage(0)

    input_reader = PdfFileReader(open(args.input, "rb"))
    output_writer = PdfFileWriter()
    for i in range(input_reader.getNumPages()):
        input_page = input_reader.getPage(i)
        media_box = input_page.mediaBox
        w, h = float(media_box.getWidth()), float(media_box.getHeight())
        page = output_writer.addBlankPage(w, h)
        tpl_page.scaleTo(w, h)
        page.mergePage(tpl_page)
        page.mergePage(input_page)

    output_name = args.output
    if not output_name:
        s = args.input.rsplit('.', 1)
        s = (s[0], 'coloradjusted', s[1])
        output_name = '.'.join(s)
    output_writer.write(open(output_name, "wb"))

if __name__ == '__main__':
    main()
