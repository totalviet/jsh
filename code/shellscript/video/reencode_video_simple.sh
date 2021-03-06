# jsh-ext-depends: mencoder
# mencoder input.avi -o re_encoded.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=5

# MP_CLIP="-ss 1:00 -endpos 0:10"

# MP_MEET_STANDARD="-vf scale=720:480 -ofps 30" ## NTSC
# MP_MEET_STANDARD="-vf scale=720:576 -ofps 25" ## PAL
# MP_MEET_STANDARD="-vf scale=360:286 -ofps 25" ## half (well quarter!) PAL

## Couldn't open codec mp2, br=224
#	1) audio must be 16 bits per sample, so add -channels 2
#	2) Not all sampling rates are good, so try to resample:
#	-srate 48000 or -srate 22050 or -srate 32000.

[ "$SRATE" ] || SRATE=48000
[ "$VQSCALE" ] || VQSCALE=6 ## I tried 10 but the file was too large.  6 is reasonable.  For less loss, try 8.

for VIDEOFILE
do

	# mencoder "$@" -o re_encoded.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=6 || exit

	## -ofps 24 needed for s11redux.wmv which "has 1000fps"!
	## -srate 3200 needed for parliament_palestine_march.avi, which had pcm with bad sample rate
	# nice -n 16 mencoder -srate 32000 -ofps 25 $MP_MEET_STANDARD "$VIDEOFILE" -o "$VIDEOFILE"-simple.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=6:acodec=mp2 $MP_CLIP $MP_EXTRA_OPTS || exit

	## Reasonable quality:
	nice -n 16 mencoder -srate "$SRATE" -ofps 25 $MP_MEET_STANDARD "$VIDEOFILE" -o "$VIDEOFILE"-simple.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=$VQSCALE $MP_CLIP $MP_EXTRA_OPTS || exit

	## High quality (but large file!):
	# nice -n 16 mencoder -srate 32000 -ofps 25 $MP_MEET_STANDARD "$VIDEOFILE" -o "$VIDEOFILE"-simple.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=2 $MP_CLIP $MP_EXTRA_OPTS || exit

done

# SIZE=`filesize re_encoded.avi`
# echo "$SIZE"
# if [ "$SIZE" -gt 671088640 ] && [ "$SIZE" -lt 737148928 ] ## 640-703Mb
# then del brazil.avi
# else del re_encoded.avi
# fi

## Another: 
# E convert�-lo para divx (o arquivo source � o input12.avi, no exemplo):
# 
# mencoder -forceidx input12.avi -lavcopts vcodec=mpeg4:vhq:vbitrate=131 -ovc lavc -vop scale=352:240 -oac mp3lame -lameopts vbr=3:abr=128:q=0:aq=0 -o output12.avi
## TODO: replace mpeg4 with msmpeg4v2

