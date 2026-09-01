# This file launch the bar/s
primary_mon=$(polybar --list-monitors | grep primary | cut -d":" -f1)
MONITOR=$primary_mon polybar -q primary-bar -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &

for mon in $(polybar --list-monitors | grep -v primary | cut -d":" -f1); do
		MONITOR=$mon polybar -q secondary-bar -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
done
