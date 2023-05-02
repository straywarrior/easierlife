#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2023 StrayWarrior <i@straywarrior.com>

"""
A simple tool to convert ifly transcript to SRT format
"""

import json
import sys
from pysubs2 import SSAFile, SSAEvent

SUB_INTERVAL = 500
MAX_WORD_PER_SUB = 15


def process_passage(passage, subs):
    begin_ts = passage['pTime'][0]

    sub_begin_ts = begin_ts
    sub_end_ts = begin_ts
    sub_text = ''

    for word in passage['words']:
        word_begin_ts = word['time'][0]
        word_end_ts = word['time'][1]
        if word_begin_ts > sub_end_ts + SUB_INTERVAL or \
                len(sub_text) > MAX_WORD_PER_SUB:
            if sub_text:
                subs.append(SSAEvent(start=sub_begin_ts, end=sub_end_ts,
                                     text=sub_text))
            sub_text = ''
            sub_begin_ts = word_begin_ts
        sub_text += word['text']
        sub_end_ts = word_end_ts

    # last sentence
    subs.append(SSAEvent(start=sub_begin_ts, end=sub_end_ts,
                         text=sub_text))


def main():
    api_resp = json.loads(sys.stdin.read())

    transcript_json = json.loads(api_resp['biz']['transcriptResult'])
    # print(json.dumps(transcript_json, indent=2, ensure_ascii=False))

    subs = SSAFile()
    for passage in transcript_json['ps']:
        process_passage(passage, subs)

    if len(sys.argv) > 1:
        output_filename = sys.argv[1]
        subs.save(output_filename)
    else:
        print(subs.to_string('srt'))
    

if __name__ == '__main__':
    main()
