#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8

from icalendar import Calendar, Event, Alarm
import pandas as pd
from datetime import timedelta, datetime
import sys


def main():
    begin_date_str = sys.argv[1]
    output_path = sys.argv[2]
    begin_date = datetime.strptime(begin_date_str, "%Y-%m-%d").date()
    if begin_date.weekday() != 0:
        raise Exception("Begin date is not Monday")
    year = begin_date.year
    season = "春"
    if begin_date.month >= 8:
        season = "秋"

    c = Calendar()

    for week_idx in range(1, 19):
        week_monday = begin_date + timedelta(days=(week_idx - 1) * 7)
        event = Event()
        event.add('summary', f"{season}学期校历第{week_idx}周")
        event.add('dtstart', week_monday)

        c.add_component(event)

    with open(output_path, 'wb') as f:
        f.write(c.to_ical())


if __name__ == '__main__':
    main()
