#!/bin/zsh

# DOADD=
DOADD=on # doesn't actually do - displays for copy-paste
CHKOUT=$1
if test "$CHKOUT" = "-add"; then
  DOADD=on
  CHKOUT=$2
fi

if test "$CHKOUT" = ""; then
  echo "cvsdiff <repository>"
  exit 1
fi

COUNT=0
COUNTDIRS=0
MISSING=0

if test -d "$CHKOUT"; then
  cd "$CHKOUT"
fi

find . | grep -v "/CVS" |
  while read SOMETHING; do
    if test -d "$SOMETHING"; then
      DIR="$SOMETHING"
      # if test ! -d "$CVSROOT/$CHKOUT/$DIR/CVS/"; then
      if test ! -d "$CVSROOT/$CHKOUT/$DIR"; then
        echo 'cvs add "'$DIR'"'
      fi
      COUNTDIRS=`expr $COUNTDIRS + 1`
    else
      FILE="$SOMETHING"
      COUNT=`expr $COUNT + 1`
      CVSFILE="$CVSROOT/$CHKOUT/$FILE,v"
      if test ! -f "$CVSFILE"; then
        MISSING=`expr $MISSING + 1`
        if test $DOADD; then
          echo 'cvs add "'$FILE'"'
        else
          echo "$FILE"
        fi
      fi
    fi
  done

# find . -type d | grep -v "/CVS" |
  # while read DIR; do
    # if test ! -d "$CVSROOT/$CHKOUT/$DIR/CVS/"; then
      # echo 'cvs add "'$DIR'"'
    # fi
  # done
# 
# find . -type f | grep -v "/CVS/" |
  # while read FILE; do
    # COUNT=`expr $COUNT + 1`
    # CVSFILE="$CVSROOT/$CHKOUT/$FILE,v"
    # if test ! -f "$CVSFILE"; then
      # MISSING=`expr $MISSING + 1`
      # if test $DOADD; then
        # echo 'cvs add "'$FILE'"'
      # else
        # echo "$FILE"
      # fi
    # fi
  # done

echo "$MISSING / $COUNT files missing." >&2
echo "  ( $COUNTDIRS directories. )" >&2
