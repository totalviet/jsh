if test ! "$3" = ""; then
  echo "mvcvs: takes only two arguments (one source, one dest)"
  exit 1
fi

SRC="$1"
DEST="$2"
FNAME=`filename "$SRC"`
if test -d "$DEST"; then
  TOADD="$DEST/$FNAME"
else
  TOADD="$DEST"
fi

# Old method lost revision history but did not mess with developers who had source checked out.
echo "% cp \"$SRC\" \"$DEST\""
# cp "$SRC" "$DEST"
echo "% del \"$SRC\""
# del "$SRC"
echo "% cvs add \"$TOADD\""
# cvs add "$TOADD"

# echo "Warning: if your dest was a file, as opposed to a directory, it may not be added correctly."

echo "New method should move the cvsroot file itself."
echo "But we need to establish cvsroot!"
