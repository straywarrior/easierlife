#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2023 StrayWarrior <i@straywarrior.com>
#
# Distributed under terms of the MIT license.

"""
A simple tool to detect scene-cut of video, especially video of slides.
"""


import cv2
import numpy as np
import sys

def calc_frame_difference(frame1, frame2):
    diff = cv2.absdiff(frame1, frame2)
    diff_threshold = cv2.threshold(diff, 30, 255, cv2.THRESH_BINARY)[1]
    return diff, diff_threshold


def process_video(input_name, output_name, skip_seconds=0, check_interval=5,
                  crop_x=0, crop_y=0, crop_w=0, crop_h=0):
    next_second = skip_seconds

    cap = cv2.VideoCapture(input_name)
    cap.set(cv2.CAP_PROP_POS_MSEC, next_second * 1000)
    ret, frame1 = cap.read()
    if not ret:
        return
    frame1 = cv2.cvtColor(frame1, cv2.COLOR_BGR2GRAY)
    def crop_frame(frame):
        if crop_w > 0:
            return frame[crop_y:crop_y+crop_h, crop_x:crop_x+crop_w]
        else:
            return frame
    frame1 = crop_frame(frame1)

    save_idx = 0
    while True:
        next_second += check_interval
        cap.set(cv2.CAP_PROP_POS_MSEC, next_second * 1000)
        ret, frame2 = cap.read()
        if not ret:
            break
        frame_ts_h = next_second // 3600
        frame_ts_m = (next_second - frame_ts_h * 3600) // 60
        frame_ts_s = next_second % 60
        frame2 = crop_frame(frame2)
        frame2_gray = cv2.cvtColor(frame2, cv2.COLOR_BGR2GRAY)
        diff, diff_threshold = calc_frame_difference(frame1, frame2_gray)
        mean_diff = np.mean(diff_threshold)
        print('%d:%d:%d %f' % (frame_ts_h, frame_ts_m, frame_ts_s, mean_diff))
        if mean_diff > 10:
            cv2.imwrite('%s_%03d.png' % (output_name, save_idx), frame2)
            save_idx += 1
        frame1 = frame2_gray

if __name__ == '__main__':
    input_name = sys.argv[1]
    output_name = sys.argv[2]
    skip_seconds = 0
    crop_params = ''
    if len(sys.argv) > 3:
        skip_seconds = int(sys.argv[3])
    if len(sys.argv) > 4:
        crop_params = sys.argv[4]

    crop_params = [int(x) for x in crop_params.split(":")]
    print('begin process ...')
    process_video(input_name, output_name, skip_seconds, 5,
                  crop_params[0], crop_params[1], crop_params[2], crop_params[3])

