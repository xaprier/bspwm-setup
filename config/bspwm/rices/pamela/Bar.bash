# This file launch the bar/s
for mon in $(polybar --list-monitors | cut -d":" -f1); do
	(
    MONITOR=$mon polybar -q pam1 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
	MONITOR=$mon polybar -q pam2 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
	MONITOR=$mon polybar -q pam3 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
	MONITOR=$mon polybar -q pam4 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
	MONITOR=$mon polybar -q pam5 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
	MONITOR=$mon polybar -q pam6 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
    )
done

# This file launch the bar/s
primary_mon=$(polybar --list-monitors | grep primary | cut -d":" -f1)
MONITOR=$primary_mon polybar -q pam1 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
MONITOR=$primary_mon polybar -q pam2 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
MONITOR=$primary_mon polybar -q primary-pam3 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
MONITOR=$primary_mon polybar -q pam4 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
MONITOR=$primary_mon polybar -q pam5 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
MONITOR=$primary_mon polybar -q pam6 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &

for mon in $(polybar --list-monitors | grep -v primary | cut -d":" -f1); do
    MONITOR=$mon polybar -q pam1 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
		MONITOR=$mon polybar -q pam2 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
		MONITOR=$mon polybar -q secondary-pam3 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
		MONITOR=$mon polybar -q pam4 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
		MONITOR=$mon polybar -q pam5 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
		MONITOR=$mon polybar -q pam6 -c "${HOME}"/.config/bspwm/rices/"${RICE}"/config.ini &
done
