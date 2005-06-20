# jsh-ext-depends-ignore: apt-cache dpkg find dirname last sort from file time realpath
# jsh-ext-depends: sed md5sum newer
# jsh-depends: cursebold cursecyan cursemagenta cursenorm rememo datediff jdeltmp jgettmpdir jgettmp newer realpath debug
# jsh-depends-ignore: arguments filename arguments todo mytest md5sum

## Note: if you see a script which does "cd /" and claims to do it for memoing, this is because it wants all its memo's to be "working-directory independent"
##       this might be solved in future by TODO: an option (or envvar) to specify that the working-directory is irrelevant to memo's output, and should be ignored in the hash

## DONE: added efficiency here if . jgettmpdir -top is run before using memo
[ -w "$TOPTMP" ] || . jgettmpdir -top
MEMODIR=$TOPTMP/memo

## TODO:
#  - Allow user to specify their own hash (essentially making memo a hashtable)

## TODO: there are two main things slowing it down:
##       the realpath     : well, move jsh realpath out of the way for a start!
##                        : also, add the -ignoredir or -nd option, because there's no point doing realpath if cd / has already been done to prevent cwd hashing
##                        : if realpath slows it down, then just use $PWD, it's not that much of a feature loss (memo's from different $PWD's will fail even if `realpath $PWD` is identical)
##                          don't do realpath on /!   OK it doesn't do realpath on /, which helped a lot for scripts which call memo after cd /
##       the checksumming : is there a quicker hash we can use in the shell?
## Afterthought: another factor may be the damn size of this script!
##               but DONE :) as far as checksumming is concerned, I think we should only try to include the command in the memofile name if we are in debug mode, because that may be slowing it down.

## HOW-TO-SPEED-IT-UP-EXTERNALLY: Yes the re-parsing of this script does slow it down considerably; this can be improved by using ". importshfn rememo" and ". importshfn memo" before repeatedly using memo.  :)

## DONE: refactor the destination nonsense out of memo/rememo to somewhere common!  (Well actually we could pass it to rememo :)

## DONE:
#  - Leaves an empty or partial memo file if interrupted
#    We should memo to a temp file and move to memo file when complete
#  - Allow user to specify timeout after which rememo occurs
#  - Allow user to specify quick command which returns non-0 if rememo needed (or a test-rememo command?)
#  -                       a file (or indeed a directory full of files) which, if it is (they are) newer than the memo-cache-file, will force rememoing

## DONE: added efficiency by referring to md5sum binary directly to avoid jsh's md5sum from being called.
## but TODO NOTE BUG: this is NOT good if there is no md5sum binary!  :/
## so TODO: What is the efficient way to select which md5sum command to use?

## DONE: allow the default memo-ing condition and/or command to be provided as an env-var :) .  Oh yeah, it's REMEMOWHEN!

if [ "$1" = "-info" ]
then
	MEMO_SHOW_INFO=true
	shift
fi

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo "Usage:"
  echo
	echo "  memo [options] <command>..."
  echo
	echo "  rememo <command>..."
  echo
  echo "    memo will cache the ouput of the given command, and redisplay it on future"
  echo "    calls made with the same arguments and from the same working directory."
  echo "    Hence memo is useful for caching the output of slow operations."
	echo "    You may use rememo to force a refresh of the cache for that command (in wd)."
  echo
	# echo "    will cache the output of the command (useful if it takes a long time to run),"
	# # echo "Memo will remember the output of <command> run in current working directory,
	# echo "    and redisplay this output on subsequent calls with the same arguments and working directory."
  echo "Options:"
  echo
  echo "  -t <time_period>  : force refresh of cache if given time period has expired"
  echo "  -f <filename>     : force refresh if file has changed since last caching"
  echo "  -d <dirname>      : force refresh if any file in given directory has changed"
  echo "  -c <test_command> : force refresh if command returns true"
  echo "                      (the command is evaluated with the memo file in \$MEMOFILE)"
  echo
  echo "Examples:"
  echo
  echo "  memo -f /var/lib/dpkg/status dpkg -l"
  echo "  memo -d /var/lib/apt apt-cache dump"
  echo "  memo -t '1 day' \"du -sk / | sort -n -k 1\""
  echo "  memo -c <check_com> (todo)"
  echo
  echo "Todo:"
  echo
  echo "  Possibly rememodiff which looks for changes since last memoed."
  echo
  echo "Bugs:"
  echo
  echo "  -d <dirname> and -f <filename> compare the modified time against the modified time of the memo."
  echo "    If the memo takes a long time to generate, it may be that the files changed since it started,"
  echo "    but before it ended, and so it should be rememo-ed, but isn't.  Could solve by changing memofile date to time that it was started."
  echo
  exit 1
fi

[ "$REMEMOWHEN" ] || REMEMOWHEN='false' ## or whatever we think the default should be: 1min, 5mins or 1hour; guess from files in arguments?!
while true
do
  case "$1" in
    -t)
      export TIME="$2"
      shift; shift
      AGEFILE=`jgettmp check_age`
      REMEMOWHEN="$REMEMOWHEN"' || (
        touch -d "$TIME ago" $AGEFILE
        newer $AGEFILE "$MEMOFILE"
      )'
    ;;
    -f)
      export CHECKFILE="$2"
      shift; shift
      REMEMOWHEN="$REMEMOWHEN"' || newer "$CHECKFILE" "$MEMOFILE"'
    ;;
    -d)
      export CHECKDIR="$2"
      shift; shift
      REMEMOWHEN="$REMEMOWHEN"' || ( find "$CHECKDIR" -newer "$MEMOFILE" | grep "^" > /dev/null ) '
    ;;
    -c)
      REMEMOWHEN="$REMEMOWHEN || ( $2 )"
      shift; shift
    ;;
    *)
      break
    ;;
  esac
done

if [ "$MEMO_IGNORE_DIR" ] || [ "$PWD" = / ] ## for speed
then REALPWD=/
else REALPWD=`realpath "$PWD"`
fi
# CKSUM=`echo "$REALPWD/$*" | /usr/bin/md5sum`
CKSUM=`echo "$REALPWD/$*" | /usr/bin/cksum -` ## seems minutely faster to me
if [ "$DEBUG_MEMO" ]
then NICECOM=`echo "$CKSUM..$*..$REALPWD" | tr " \n/" "__+" | sed 's+\(................................................................................\).*+\1+'`
else NICECOM="$CKSUM"
fi
MEMOFILE="$MEMODIR/$NICECOM.memo"
export CHECKDIR CHECKFILE REMEMOWHEN MEMOFILE AGEFILE

# [ "$DEBUG" ] && debug "memo:     `cursemagenta`checking: $REMEMOWHEN (MEMOFILE=$MEMOFILE)`cursenorm`"

# echo "Doing check: $REMEMOWHEN" >&2
if [ "$REMEMO" ] || [ ! -f "$MEMOFILE" ] || eval "$REMEMOWHEN"
then
	# [ "$DEBUG" ] && ( debug "REmemoing: com=\"$NICECOM\" REMEMO=$REMEMO filecached=`mytest test -f \"$MEMOFILE\"` REMEMOWHEN=$REMEMOWHEN" | tr '\n' ';' ; echo>&2 )
	[ "$DEBUG" ] && debug "memo: re-running com=\"$NICECOM\" REMEMO=$REMEMO filecached=`mytest test -f \"$MEMOFILE\"` REMEMOWHEN=$REMEMOWHEN"
	# eval "$REMEMOWHEN" && [ "$DEBUG" ] && debug "memo:     `cursemagenta`Refresh needed with com: $REMEMOWHEN`cursenorm`"
	rememo "$@"
else
	# [ "$DEBUG" ] && debug "memo: re-using com=\"$NICECOM\""
	[ "$DEBUG" ] && debug "memo: re-using memofile=\"$MEMOFILE\""
	cat "$MEMOFILE"
fi
EXITWITH="$?"

[ "$AGEFILE" ] && jdeltmp $AGEFILE

if [ "$MEMO_SHOW_INFO" ]
then

	TMPF=`jgettmp`
	touch "$TMPF"
	(
		cursecyan
		# echo "as of "`date -r "$MEMOFILE"`
		echo "$@"
		TIMEAGO=`datediff -files "$MEMOFILE" "$TMPF"`
		echo "cached $TIMEAGO ago."
		cursenorm
	) >&2
	jdeltmp "$TMPF"

fi

[ "$EXITWITH" = 0 ]
