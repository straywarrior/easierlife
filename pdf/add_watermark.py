#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2024 StrayWarrior <i@straywarrior.com>
#
# Distributed under terms of the MIT license.

"""

"""

from PyPDF2 import PdfReader, PdfWriter
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.colors import Color
from io import BytesIO
import sys


pdfmetrics.registerFont(TTFont('Microsoft YaHei', '/usr/local/share/fonts/msyh.ttc'))

def create_watermark(text, font_size=24, font_color=(0, 0, 0)):
    packet = BytesIO()
    can = canvas.Canvas(packet, pagesize=letter)
    text_lines = text.split('\n')
    text_lines.reverse()

    can.setFont("Microsoft YaHei", font_size)
    can.setFillColor(Color(*font_color, alpha=0.5))
    can.saveState()
    can.translate(400, 400)
    can.rotate(45)
    y_offset = 0
    for text_line in text_lines:
        can.drawCentredString(0, y_offset, text_line)
        y_offset += 40
    can.restoreState()
    can.save()

    packet.seek(0)
    return PdfReader(packet)

def add_watermark_to_pdf(text, input_pdf_path, output_pdf_path):
    reader = PdfReader(input_pdf_path)
    writer = PdfWriter()

	# Create a new page with the watermark
    wm_pdf = create_watermark(text, font_size=32, font_color=(255, 0, 0))

    for page_num in range(len(reader.pages)):
        page = reader.pages[page_num]
        
        # Merge the watermark page with the current page
        page.merge_page(wm_pdf.pages[0])
        
        writer.add_page(page)

    with open(output_pdf_path, "wb") as output_pdf:
        writer.write(output_pdf)


def main():
    text = sys.argv[1]
    input_path = sys.argv[2]
    output_path = sys.argv[3]
    add_watermark_to_pdf(text, input_path, output_path)
    print(f"Watermarked document saved as {output_path}")


if __name__ == '__main__':
    main()
