killall xscreensaver && XSCREENSAVER_WAS_RUNNING=true

# -stop_xscreensaver"
# OPTS="-vo xv" ## my preference: allows me to adjust contrast!
OPTS="-vo x11" ## for Morphix
# OPTS="-vo sdl" ## good if the machine is slow (but not so pretty)
# OPTS="-vo xv"
if test "$1" = "-turbo"
then
	shift
	OPTS="-vo sdl"
fi
OPTS="$OPTS -ao sdl -zoom -idx"

if [ "$1" = -louder ]
then OPTS="$OPTS -af volume=+10dB"; shift
fi

unj mplayer $OPTS "$@"

[ "$XSCREENSAVER_WAS_RUNNING" ] && xscreensaver -no-splash &
