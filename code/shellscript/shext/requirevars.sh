## Source me from a bash-shebanged script (will not work from an sh-shebanged script)

for VAR in "$@"
do

	VALUE=`eval echo '$'"$VAR"`
	# echo "$VAR=$VALUE"
	if [ ! "$VALUE" ]
	then

		error "Required environment variable $VAR is empty."
		jshinfo "In fact all of these are needed: $*"
		exit 1

	fi

done
