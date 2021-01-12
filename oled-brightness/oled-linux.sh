#!/bin/bash
cd "$(dirname ${BASH_SOURCE[0]})"



# where is the backlight directory?
backlight_dir="/sys/class/backlight/intel_backlight/"

# which screen is the oled panel?
# if not set, it will default to `xrandr | grep -m 1 ' connected ' | awk '{print $1}'`
# leaving it empty will "just work" in most cases
#
# do xrandr command for a list of screen names
# e-DP1 is an example of a good screen name
oled_screen=''

# how much to change the brightness on one frame 
# or how smooth should the brightness changes be
# the lower the value the longer it takes to transition to a new brightness
# has to be an integer value, no fractional values are allowed
brightness_step_size=1500

# if true, the program will look for changes in 'day_night.txt' and update the redshift temperature accordingly
# check 'set_day_night.sh' to see how 'day_night.txt' is updated
use_redshift=false

# nightshift temperature during the day
daylight_temperature=6500

# nightshift temperature during the night
night_temperature=3500

# how much to change the temperature of the night light on one frarme
# the lower the value, the longer it takes to transition to a new redshift temperature
# has to be an integer value, no fractional values are allowed
redshift_step_size=50



if ! test -d "$backlight_dir"
then
	echo "ERROR: wrong configuration. Backlight directory does not exist."
	exit 0
fi

if ! command -v inotifywait
then
	echo "ERROR: dependency 'inotifywait' is not installed. Sorry, but this script cannot run without inotifywait"
	exit 0
fi


if [ "$oled_screen" == "" ]
then
	echo "here"
	oled_screen=`xrandr | grep -m 1 ' connected ' | awk '{print $1}'`
fi
max_brightness=$(cat "$backlight_dir/max_brightness")	


target_brightness=$(cat "$backlight_dir/brightness")
current_brightness=$(cat "$backlight_dir/max_brightness")

target_shift=$daylight_temperature
current_shift=$daylight_temperature

while true;
do
	target_brightness=$(cat "$backlight_dir/brightness")

	#day_night=$(cat "./file-pipes/day-night.txt")
	day_night=""
	if $use_redshift && [ "$day_night" = "NIGHT" ]
	then
		target_shift=$night_temperature
	else
		target_shift=$daylight_temperature
	fi

	#if [ $current_brightness -eq $target_brightness ] && [ $current_shift -eq $target_shift ]
	#then
	#	inotifywait -e close_write $backlight_dir/brightness -e close_write './file-pipes/day-night.txt' > /dev/null
	#	continue
	#fi

	step=$((current_brightness - target_brightness))
	if [ $step -lt 0 ]; then step=$((-step)); fi
	if [ $step -gt $brightness_step_size ]; then step=$brightness_step_size; fi

	if [ $current_brightness -gt $target_brightness ]
	then
		current_brightness=$((current_brightness - step))
	else
		current_brightness=$((current_brightness + step))
	fi

	percent=`echo "$current_brightness / $max_brightness * 0.9 + 0.1" | bc -l`

	step=$((current_shift - target_shift))
	if [ $step -lt 0 ]; then step=$((-step)); fi
	if [ $step -gt $redshift_step_size ]; then step=$redshift_step_size; fi

	if [ $current_shift -gt $target_shift ]
	then
		current_shift=$((current_shift - step))
	else
		current_shift=$((current_shift + step))
	fi

	xrandr --output $oled_screen --brightness $percent
done

