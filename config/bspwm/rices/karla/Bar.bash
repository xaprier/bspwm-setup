# This file launch the bar/s
primary_mon=$(polybar --list-monitors | grep primary | cut -d":" -f1)
MONITOR=$primary_mon polybar -q karla-bar -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
MONITOR=$primary_mon polybar -q primary-karla-bar2 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
MONITOR=$primary_mon polybar -q karla-bar3 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &

for mon in $(polybar --list-monitors | grep -v primary | cut -d":" -f1); do
		MONITOR=$mon polybar -q karla-bar -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
		MONITOR=$mon polybar -q secondary-karla-bar2 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
		MONITOR=$mon polybar -q karla-bar3 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
done
