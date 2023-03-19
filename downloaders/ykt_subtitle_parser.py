#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8

import sys
import json


def main():
    raw_resp = sys.stdin.read()
    json_obj = json.loads(raw_resp)
    print('，'.join(json_obj['text']))


if __name__ == '__main__':
    main()
