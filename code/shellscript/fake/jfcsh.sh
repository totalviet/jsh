# Does a simple one-way jfc diff

if test "$1" = ""; then
	echo "jfcsh [-bothways] <file_A> <file_B>"
	echo "  will show lines in file_A which are not in file_B."
	exit 1
fi

BOTHWAYS=
while true; do
	if test "$1" = "-bothways"; then
		BOTHWAYS=true
	else
		break
	fi
	shift
done

A=`jgettmp "$1"`
B=`jgettmp "$2"`

cat "$1" | sort > "$A"
cat "$2" | sort > "$B"

test $BOTHWAYS && echo "vvvvvvvvvvvvvvvv Lines only in $A vvvvvvvvvvvvvvvv"

diff "$A" "$B" |
	grep "^< " | sed "s/^< //"

if test $BOTHWAYS; then

	echo "--------------------------------------------------------------------------------"

	diff "$B" "$A" |
		grep "^< " | sed "s/^< //"

	## Or:
	# diff "$A" "$B" |
		# grep "^> " | sed "s/^> //"

	echo "^^^^^^^^^^^^^^^^ Lines only in $B ^^^^^^^^^^^^^^^^"

fi
