## Example recovery:
## mkdir /tmp/recover; cd /tmp/recover
## tar xfz /mnt/stig/makebaks/etc-0.tar.gz
## cd etc; contractsymlinks; cd ..
## for PATCH in /mnt/stig/makebaks/etc-*.diff.gz; do gunzip -c "$PATCH" | patch -E -p0; done
## cd etc; expandsymlinks; cd ..

## Now has external dependencies: contractsymlinks, filesize, j(get|del)tmp(dir|)

# Paranoid; sensible.
set -e

if test "$1" = "" || test "$1" = --help; then
cat << !

makebackup [-efficient] <dir/file_to_backup> <storage_dir> [<storage_prefix>]

  will create a numbered backup (tar.gz) of the given file or directory
    in <storage_dir> each time it is run.

  It also automatically generates a patch for each new version, which is
    a space-efficient way to store history (-efficient will remove all but the
    first and last full backups, as well as skip backup in absence of changes.)

  The patches can be used to roll back or forwards from any full backup.
    (They are generated using diff -r -u -N -a which supports new/removed files
    and binary files.)

  Note: Although the backup files are pure, the diffs cannot contain symlinks,
    so for recovery you must run contractsymlinks before you patch -p0, and
    expandsymlinks afterwards.

  Bugs: empty directories and empty files are left floating unless U patch -E,
    and GNU diff/patch does not appear to support filenames with spaces!
    (The data is not lost, but the filename in the patch is interpreted badly.)

!
exit 1
fi

EFFICIENT=
if test "$1" = -efficient
then EFFICIENT=true; shift
fi

TOBACKUP="$1"
BACKUPDIR="$2"

DIRNAME=`dirname "$TOBACKUP" | sed "s+^\([^/]\)+$PWD/\1+"`
BASENAME=`basename "$TOBACKUP"`
test "$3" &&
BACKUPNAME="$3" ||
BACKUPNAME="$BASENAME"

mkdir -p "$BACKUPDIR" || exit 1

## Establish (from destination files) which version backup we are creating:
VER=0
while test -f "$BACKUPDIR/$BACKUPNAME-$VER.diff.gz" || test -f "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz"
do VER=`expr $VER + 1`
done

DOPUREBACKUP=true

if test ! "$VER" = 0
then

	OURTMPDIR=`jgettmpdir makebak`
	if test "$OURTMPDIR" = "" || test ! -w "$OURTMPDIR"; then echo "Problem with OURTMPDIR = >$OURTMPDIR<"; exit 1; fi

	THISVERSION="$OURTMPDIR/ver$VER"
	## Note: confidence in contractsymlinks now allows us to do this to the dir directly (provided we expandsymlinks again afterwards).
	## But if we're backing up a file then there's really little point in this!  Well of course that's what test $BASENAME is for!
	echo "Copying $TOBACKUP to temp dir so I can prepare it for diffing"
	mkdir -p "$THISVERSION"
	cd "$DIRNAME"
	cp -a "$BASENAME" "$THISVERSION"

	# Fix symlink problems by removing them!
	# but list them to a file so their changes may be seen.
	cd "$THISVERSION"
	if test -d "$BASENAME"
	then
		echo "Contracting symlinks into .symlinks.list"
		cd "$BASENAME"
		contractsymlinks
	fi

	## We can no longer be paranoid, because expr and diff will often return 0!
	set +e
	PREVER=`expr $VER - 1` ## Exits with 0 if VER=1
	set -e

	LASTVERSION="$OURTMPDIR/ver$PREVER"
	mkdir -p "$LASTVERSION"

	echo "Extracting previous version into tempdir for comparison"
	cd "$LASTVERSION"
	tar xfz "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"
	if test -d "$BASENAME"
	then
		echo "Contracting symlinks into .symlinks.list"
		cd "$BASENAME"
		contractsymlinks
	fi

	DIFF_FILE="$BACKUPDIR/$BACKUPNAME-$VER.diff"
	echo "Comparing versions, saving patch in $DIFF_FILE"
	cd "$LASTVERSION"
	set +e
	diff -r -u -N -a "$BASENAME" "../ver$VER/$BASENAME" > "$DIFF_FILE"
	if test "$?" = 0 && test "$EFFICIENT" && test `filesize "$DIFF_FILE"` = 0
	then
		set -e
		echo "No different from previous version!"
		echo "Removing empty diff $DIFF_FILE and skipping full backup."
		rm -f "$DIFF_FILE"
		DOPUREBACKUP=
	else
		set -e
		gzip "$DIFF_FILE"
		test $PREVER -gt 0 && rm -f "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"
	fi

	cd /tmp # anywhere should do
	jdeltmp "$OURTMPDIR"

fi

if test $DOPUREBACKUP
then
	echo "Backing up $TOBACKUP into $BACKUPDIR/$BACKUPNAME-$VER.tar.gz"
	cd "$DIRNAME"
	tar cfz "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz" "$BASENAME"
fi
