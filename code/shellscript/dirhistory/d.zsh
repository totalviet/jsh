#!/bin/bash
# d: change directory and record for b and f shell tools

# Shouldn't we remember moved-into, not moved-out-of?

# Sometimes NEWDIR="$@" breaks under ssh!

NEWDIR="$@"

# Record where we are for b and f sh tools
echo "$PWD" >> $HOME/.dirhistory

if [ "$NEWDIR" = "" ]; then
	if test `filename "$HOME"` = "$USER"; then
		"cd" "$HOME"
	 else
		# I prefer the directory above my home!
		"cd" "$HOME/.."
	fi
	# "cd"
elif test -d "$NEWDIR"; then
	'cd' "$NEWDIR"
else
	# If incomplete dir given, check if there is a
	# unique directory which the user probably meant.
	# Useful substitue when tab-completion unavailable,
	# or with tab-completion which does not contextually exclude files.
	# NEWLIST=`echo "$NEWDIR"* 2>/dev/null |
	LOOKIN=`dirname "$NEWDIR"`
	LOOKFOR=`filename "$NEWDIR"`
	NEWLIST=`
		find "$LOOKIN" -maxdepth 1 -name "$LOOKFOR*" |
		while read X; do
			if test -d "$X"; then
				echo "$X"
			fi
		 done`
	# No way, this is really naff if you have up-history:
	# # Nothing: assume user chose a file with tab-completion, and go
	# # to directory above.  (What if it doesn't exist?!)
	# if test "$NEWLIST" = ""; then
		# DIRABOVE=`dirname "$NEWDIR"`
		# echo "< $DIRABOVE"
		# 'cd' "$DIRABOVE"
	# One unique dir =)
	if test `echo "$NEWLIST" | countlines` = "1"; then
		echo "> $NEWLIST"
		'cd' "$NEWLIST"
	# A few possibilities, suggest them to the user.
	else
		# echo "? $NEWLIST" | tr "\n" " "
		echo "$NEWLIST" | sed "s+^+\? +"
		# echo -n "$NEWLIST" | tr "\n" " "
		# echo " ?"
	fi
fi

# pwd >> $HOME/.dirhistory
