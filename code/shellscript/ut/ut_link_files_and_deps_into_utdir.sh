# SUPPORTING_FILE_DIRS=/mnt/space/stuff/software/games/unreal/server/
SUPPORTING_FILE_DIRS=/stuff/ut/files/

[ "$SKIP_DEPENDENCIES" ] || CHECK_SUB_DEPENDENCIES=true

DEFAULT_PACKAGES="Botmca9.umx\|Botpck10.umx\|Cannon.umx\|Colossus.umx\|Course.umx\|Credits.umx\|Ending.umx\|Enigma.umx\|firebr.umx\|Foregone.umx\|Godown.umx\|Lock.umx\|Mech8.umx\|Mission.umx\|Nether.umx\|Organic.umx\|Phantom.umx\|Razor-ub.umx\|Run.umx\|SaveMe.umx\|Savemeg.umx\|Seeker.umx\|Seeker2.umx\|Skyward.umx\|Strider.umx\|Suprfist.umx\|UnWorld2.umx\|utmenu23.umx\|Uttitle.umx\|Wheels.umx\|Activates.uax\|Addon1.uax\|AmbAncient.uax\|AmbCity.uax\|AmbModern.uax\|AmbOutside.uax\|Announcer.uax\|BossVoice.uax\|DDay.uax\|DMatch.uax\|DoorsAnc.uax\|DoorsMod.uax\|Extro.uax\|Female1Voice.uax\|Female2Voice.uax\|FemaleSounds.uax\|LadderSounds.uax\|Male1Voice.uax\|Male2Voice.uax\|MaleSounds.uax\|noxxsnd.uax\|openingwave.uax\|Pan1.uax\|rain.uax\|ResurrectAux.uax\|TutVoiceAS.uax\|TutVoiceCTF.uax\|TutVoiceDM.uax\|TutVoiceDOM.uax\|VRikers.uax\|BotPack.u\|Core.u\|Editor.u\|Engine.u\|Fire.u\|IpDrv.u\|IpServer.u\|UBrowser.u\|UMenu.u\|UnrealI.u\|UnrealShare.u\|UTBrowser.u\|UTMenu.u\|UTServerAdmin.u\|UWeb.u\|UWindow.u\|relics.u\|multimesh.u\|de.u"
IGNORE_PKGS="\($DEFAULT_PACKAGES\|MyLevel\|Color\|BotPack\|GenFX\|GenFluid\|LavaFX\)" ## anything in ut_win_pure
## See ut_finddeps for a better version

[ "$DO_LINK" ] || DO_LINK="verbosely ln -s"
# DO_LINK="verbosely cp"

export MEMO_IGNORE_DIR=true

dirfor () {
	FILETYPE=`echo "$1" | afterlast "\." | tolowercase`
	case "$FILETYPE" in
		unr) TARGET="Maps" ;;
		uax) TARGET="Sounds" ;;
		umx) TARGET="Music" ;;
		unr) TARGET="Maps" ;;
		utx) TARGET="Textures" ;;
		u|int|ini|so) TARGET="System" ;;
		*) jshwarn "No target for $FILETYPE ($1)"
	esac
	echo "$TARGET"
}

link_ut_file () {
	UTFILE="$1"
	FILENAME=`basename "$UTFILE"`
	TARGET_SUBDIR="`dirfor "$FILENAME"`"
	if [ ! "$TARGET_SUBDIR" ]
	then
		error "Cannot link $FILENAME"
	else
		TARGET_DIR="$TARGET_UT_HOMEDIR"/"$TARGET_SUBDIR"
		if [ -e "$TARGET_DIR/$FILENAME" ]
		then : # jshinfo "Already exists: $TARGET_DIR/$FILENAME"
		else $DO_LINK "$UTFILE" "$TARGET_DIR/"
		fi
	fi
}

if [ "$1" = --help ]
then
	echo
	echo "  ut_link_files_and_deps_into_utdir <ut_dir> <ut_files>..."
	echo
	echo "  cat ut_files.list | ut_link_files_and_deps_into_utdir <ut_dir>"
	echo
	echo "  You can: export DO_LINK=\"verbosely cp\""
	echo
	exit 1
fi

if [ "$1" ]
then TARGET_UT_HOMEDIR="$1"; shift
fi

export NL="
"

DEPSDONE=""

if [ "$*" ]
then echolines "$@"
else cat
fi |

## Now recursively adds sub-dependencies, without reaching an infloop (by using a todo list)

while read UTFILE
do

	export IKNOWIDONTHAVEATTY=true

	link_ut_file "$UTFILE"

	PACKAGE_NAME="`echo "$UTFILE" | afterlast / | beforelast '\.'`"

	# DEPSTODO=`verbosely memo -t "1 week" ut_finddeps "$UTFILE"`
	# DEPSTODO=`memo -t "1 week" ut_finddeps "$UTFILE"`
	DEPSTODO=`utdep.pl "$UTFILE" | grep -iv "^$IGNORE_PKGS$"`
	# DEPSTODO="$PACKAGE_NAME"

	while [ "$DEPSTODO" ]
	do

		DEP=`echo "$DEPSTODO" | head -n 1`
		DEPSTODO=`echo "$DEPSTODO" | drop 1`

		if echo "$DEPSDONE" | grep "^$DEP\$" >/dev/null
		then continue
		fi ## one got in that had already been done :p

		DEPSDONE="$DEPSDONE$NL$DEP"

		# echo "`cursered`Doing >$DEP< with "`echo "$DEPSTODO" | wc -l`" remaining ("`echo "$DEPSTODO" | tr '\n' ','`")`cursenorm`" >&2
		# echo "`cursegreen`btw done are: "`echo "$DEPSDONE" | wc -l`" ["`echo "$DEPSDONE" | tr '\n' ','`"]`cursenorm`" >&2

		## No a pipe won't do!
		# verbosely memo find $SUPPORTING_FILE_DIRS -iname "$DEP.u*" |
		# while read FILE

		# jshinfo "Seeking dependency $DEP for $PACKAGE_NAME"

		FOUND=0

		# for FILE in ` verbosely memo find $SUPPORTING_FILE_DIRS -iname "$DEP.u*" `
		for FILE in ` memo find $SUPPORTING_FILE_DIRS -iname "$DEP" `
		do
			FOUND=$((FOUND+1))
			link_ut_file "$FILE"
			if [ "$CHECK_SUB_DEPENDENCIES" ]
			then
				## No a pipe won't do!
				# verbosely memo -t "1 week" ut_finddeps "$FILE" |
				# while read NEWDEP
				if endswith "$FILE" ".uax" || endswith "$FILE" ".umx" || endswith "$FILE" ".utx"
				then
					: # jshinfo "Skipping scan of audio/texture file $FILE"
				else
					# for NEWDEP in ` verbosely memo -t "1 week" ut_finddeps "$FILE" ` # | pipeboth 
					# for NEWDEP in ` memo -t "1 week" ut_finddeps "$FILE" ` # | pipeboth 
					for NEWDEP in ` utdep.pl "$FILE" | grep -iv "^$IGNORE_PKGS$"` # | pipeboth 
					do
						# jshinfo "Considering: $NEWDEP (required by $DEP)"
						# echo "$DEPSDONE$NL$DEPSTODO" | grep "^$NEWDEP\$" >/dev/null || DEPSTODO="$DEPSTODO""$NL""$NEWDEP"
						echo "$DEPSDONE$NL$DEPSTODO" | grep "^$NEWDEP\$" >/dev/null || DEPSTODO="$DEPSTODO
	$NEWDEP"
					done
				fi
			fi
		done

		if [ "$FOUND" = 0 ]
		then jshwarn "Failed to find dependency $DEP for $PACKAGE_NAME"
		fi

	done

	# echo "$DEPSDONE"

done

	# grep -v -i "^$IGNORE_PKGS\$" |
	# grep -v "^$PACKAGE_NAME\$" |
	# while read DEP
	# do
		# jshinfo "Considering $DEP"
		# # if [ "$CHECK_SUB_DEPENDENCIES" ] ## current implementation is dangerous (recurses on one file if it appears to depend on itself)
		# # then
			# # verbosely memo eval " find $SUPPORTING_FILE_DIRS -iname '$DEP.u*' | ut_link_files_and_deps_into_utdir '$TARGET_UT_HOMEDIR' "
		# # else
			# verbosely memo find $SUPPORTING_FILE_DIRS -iname "$DEP.u*" |
			# # foreachdo link_ut_file
			# while read F; do link_ut_file "$F"; done
		# # fi
	# done
# 
# done

