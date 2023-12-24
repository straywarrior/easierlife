#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2023 StrayWarrior <i@straywarrior.com>

from icalendar import Calendar, Event, Alarm
import pandas as pd
from datetime import timedelta, datetime
import sys


def main():
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    data = pd.read_csv(input_path)
    c = Calendar()

    for index, row in data.iterrows():
        name = row['name']
        birthday = datetime.strptime(row['birthday'], "%m/%d/%Y").date()
        event = Event()
        event.add('summary', f"{name}的生日")
        event.add('dtstart', birthday)
        event.add('rrule', {'freq': 'yearly'})
        event.add('valarm', {'freq': 'yearly'})

        alarm = Alarm()
        alarm.add("action", "DISPLAY")
        alarm.add('description', "Reminder: " + event.get('summary'))
        alarm.add("trigger", timedelta(minutes=-5))
        # event.add_component(alarm)

        c.add_component(event)

    with open(output_path, 'wb') as f:
        f.write(c.to_ical())


if __name__ == '__main__':
    main()
