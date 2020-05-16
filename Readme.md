# OBS Studio Date Time Script

Based on [DateTime.lua by Albin Kauffmann](https://gitlab.com/albinou/obs-scripts/)

Modified to accept a second source to allow splitting the date and time.

This script transforms up to 2 text sources into a digital clock. The datetime format is independently configurable and uses the same syntax as the Lua os.date() call.

```
    %a	abbreviated weekday name (e.g., Wed)
    %A	full weekday name (e.g., Wednesday)
    %b	abbreviated month name (e.g., Sep)
    %B	full month name (e.g., September)
    %c	date and time (e.g., 09/16/98 23:48:10)
    %d	day of the month (16) [01-31]
    %H	hour, using a 24-hour clock (23) [00-23]
    %I	hour, using a 12-hour clock (11) [01-12]
    %M	minute (48) [00-59]
    %m	month (09) [01-12]\
    %p	either "am" or "pm" (pm)
    %S	second (10) [00-61]
    %w	weekday (3) [0-6 = Sunday-Saturday]
    %x	date (e.g., 09/16/98)
    %X	time (e.g., 23:48:10)
    %Y	full year (1998)
    %y	two-digit year (98) [00-99]
    %z	Timezone Abbrev (e.g. EDT)
    %Z	Timezone full (e.g. Eastern Daylight Time)
    %%	the character `%´
    %n	new line"
```

## Howto install script in OBS Studio

- Download the script anywhere on your hard drive
- Go to Tools -> Scripts and add the downloaded script
- Configure the sources you wish to display

![options screenshot](https://github.com/Kershoc/obs-script-datetime/raw/master/readme-imgs/options.png)
