#!/usr/bin/env bash
# Created by xaprier | 08/21/2026

# ─────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────

bspwm_dir="$HOME/.config/bspwm"
rasi_file="$bspwm_dir/config/rofi-themes/Media.rasi"
cache_file="/tmp/mediagui-meta"

# ─────────────────────────────────────────────
# Control Icons
# ─────────────────────────────────────────────

icon_previous=$'\U000F04AE'
icon_play=$'\U000F040A'
icon_pause=$'\U000F03E4'
icon_next=$'\U000F04AD'

# ─────────────────────────────────────────────
# Player State
# ─────────────────────────────────────────────

# Pin a single player: separate playerctl invocations may otherwise
# resolve to different players when more than one is running.
player="$(playerctl -l 2>/dev/null | head -n1)"

# Read every field in one D-Bus round trip so the values are guaranteed
# to describe the same track. Fields are separated by 0x1f (unit separator),
# which never appears in metadata strings.
read_meta() {
    playerctl -p "$player" metadata --format \
        $'{{status}}\x1f{{xesam:title}}\x1f{{xesam:artist}}\x1f{{mpris:length}}\x1f{{position}}\x1f{{mpris:artUrl}}' \
        2>/dev/null
}

if [[ -z "$player" ]]; then

    player_status=""
    title="No media player is currently available"
    artist="No Media"
    length=""
    position=""
    art_url=""

else

    IFS=$'\x1f' read -r player_status title artist length position art_url \
        <<< "$(read_meta)"

    # Firefox omits mpris:length from most PropertiesChanged payloads and
    # only emits a complete dict on seek or state change. Retry a few times
    # to catch a full one before falling back to the cache.
    for _ in 1 2 3; do
        [[ -n "${length//[^0-9]/}" ]] && break
        sleep 0.15
        IFS=$'\x1f' read -r player_status title artist length position art_url \
            <<< "$(read_meta)"
    done

fi

[[ -z "$title" ]] && title="Unknown Title"
[[ -z "$artist" ]] && artist="Unknown Artist"

# ─────────────────────────────────────────────
# Metadata Cache
# ─────────────────────────────────────────────

# Keyed by title: length and artUrl are stable for the duration of a track,
# so a single complete read is enough to serve every later popup. The title
# check prevents a stale duration from leaking into the next track.

cached_title=""
cached_length=""
cached_art=""

if [[ -f "$cache_file" ]]; then
    IFS=$'\x1f' read -r cached_title cached_length cached_art < "$cache_file"
fi

length="${length//[^0-9]/}"

if [[ -n "$length" ]] && (( length > 0 )); then
    printf '%s\x1f%s\x1f%s' "$title" "$length" "$art_url" > "$cache_file"
else
    [[ "$cached_title" == "$title" ]] && length="$cached_length"
fi

# artUrl disappears from partial dicts as well, so restore it independently.
if [[ -z "$art_url" && "$cached_title" == "$title" ]]; then
    art_url="$cached_art"
fi

# ─────────────────────────────────────────────
# Text Truncation
# ─────────────────────────────────────────────

# Rofi textboxes neither wrap nor ellipsize, so anything wider than the
# info column is silently cut off. Trim it here instead.
truncate_text() {
    local value="$1"
    local limit="$2"

    if (( ${#value} > limit )); then
        printf '%s…' "${value:0:limit-1}"
    else
        printf '%s' "$value"
    fi
}

title="$(truncate_text "$title" 40)"
artist="$(truncate_text "$artist" 40)"

# ─────────────────────────────────────────────
# Playback Icon
# ─────────────────────────────────────────────

if [[ "$player_status" == "Playing" ]]; then
    play_icon="$icon_pause"
else
    play_icon="$icon_play"
fi

# ─────────────────────────────────────────────
# Album Art
# ─────────────────────────────────────────────

# Firefox writes cover art to a local PNG and hands over a file:// URI,
# so nothing needs downloading — strip the scheme and percent-decode.
# Remote URIs are ignored rather than fetched.

art_path=""

if [[ "$art_url" == file://* ]]; then
    art_path="${art_url#file://}"
    art_path="$(printf '%b' "${art_path//%/\\x}")"
    [[ -f "$art_path" ]] || art_path=""
fi

# ─────────────────────────────────────────────
# Position / Duration
# ─────────────────────────────────────────────

position="${position//[^0-9]/}"

position_seconds=$(( ${position:-0} / 1000000 ))
length_seconds=$(( ${length:-0} / 1000000 ))

if (( length_seconds > 0 )); then

    position_percent=$((position_seconds * 100 / length_seconds))

    (( position_percent > 100 )) && position_percent=100
    (( position_percent < 0 )) && position_percent=0

    filled=$((position_percent / 5))
    empty=$((20 - filled))

    progress=""

    for ((i = 0; i < filled; i++)); do
        progress+="━"
    done

    for ((i = 0; i < empty; i++)); do
        progress+="─"
    done

    current_minutes=$((position_seconds / 60))
    current_seconds=$((position_seconds % 60))

    total_minutes=$((length_seconds / 60))
    total_seconds=$((length_seconds % 60))

    current_time=$(printf "%02d:%02d" \
        "$current_minutes" \
        "$current_seconds")

    total_time=$(printf "%02d:%02d" \
        "$total_minutes" \
        "$total_seconds")

    progress_message="$current_time  $progress  $total_time"
    has_progress=1

else

    # No usable duration: hide the widget rather than drawing an empty bar.
    progress_message=""
    has_progress=0

fi

# ─────────────────────────────────────────────
# Escape values for Rasi theme-str
# ─────────────────────────────────────────────

escape_rasi() {
    local value="$1"

    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\n'/ }"

    printf '%s' "$value"
}

artist_rasi="$(escape_rasi "$artist")"
title_rasi="$(escape_rasi "$title")"

if (( has_progress )); then
    progress_rasi="$(escape_rasi "$progress_message")"
    progress_theme_str="textbox-progress { enabled: true; str: \"$progress_rasi\"; }"
else
    progress_theme_str="textbox-progress { enabled: false; }"
fi

# The art widget is collapsed entirely when no usable image exists,
# so the layout stays correct instead of leaving an empty box.
if [[ -n "$art_path" ]]; then
    art_rasi="$(escape_rasi "$art_path")"
    art_theme_str="imagebox { enabled: true; background-image: url(\"$art_rasi\", both); }"
else
    art_theme_str="imagebox { enabled: false; }"
fi


# ─────────────────────────────────────────────
# Rofi
# ─────────────────────────────────────────────

rofi_cmd() {
    rofi \
        -dmenu \
        -format i \
        -selected-row 1 \
        -theme "$rasi_file" \
        -theme-str "textbox-title { str: \"$title_rasi\"; }" \
        -theme-str "textbox-artist { str: \"$artist_rasi\"; }" \
        -theme-str "$progress_theme_str" \
        -theme-str "$art_theme_str"
}

run_rofi() {
    printf '%s\n' \
        "$icon_previous" \
        "$play_icon" \
        "$icon_next" |
        rofi_cmd
}

# ─────────────────────────────────────────────
# Actions
# ─────────────────────────────────────────────

run_cmd() {
    [[ -z "$player" ]] && return

    case "$1" in

        play-pause)
            playerctl -p "$player" play-pause
            ;;

        previous)
            playerctl -p "$player" previous
            ;;

        next)
            playerctl -p "$player" next
            ;;

    esac
}

# ─────────────────────────────────────────────
# Run
# ─────────────────────────────────────────────

chosen="$(run_rofi)"

case "$chosen" in
    0) run_cmd previous ;;
    1) run_cmd play-pause ;;
    2) run_cmd next ;;
esac