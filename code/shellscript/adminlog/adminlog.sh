#!/bin/sh

LOGFILE="/var/logadmin.log"
TMPFILE="/tmp/logentry.tmp"
while test -e "$TMPFILE"; do
	TMPFILE=$TMPFILE"-"
done
touch $TMPFILE

if test "$1" = "add"; then

	# New entry
	echo "Please enter your message then press Ctrl+D:"
	echo "If you don't want to make a log entry, press Ctrl+C."
	cat >> $TMPFILE || exit 0
	(
		echo
		cat $TMPFILE
		echo "  -- $USER ("`date`")"
	) >> $LOGFILE
	echo "Ok entered =)  The new logfile follows:"
	rm $TMPFILE

fi

printf "\033[00;32m" # green
printf "Welcome to neuralyte.  "
printf "\033[00;36m" # cyan
printf "Here follows the adminlog:"
echo

printf "\033[00m" # normal
tail -15 $LOGFILE

printf "\033[00;36m" # cyan
echo "To add to the admin log, run adminlog."

printf "\033[00m" # normal