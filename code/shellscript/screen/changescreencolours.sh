# BORDER="BW"
# WINDOWBAR="bw"
# WINDOWHIGHLIGHT="gk"

chooserandomarg () {
	for X
	do echo "$X"
	done | chooserandomline
}

# BORDER=`chooserandomarg RW GW BW CK MW YK`
# WINDOWBAR=bw
# WINDOWHIGHLIGHT=`chooserandomarg rW gK CK MW YK`

# WINDOWBAR=`chooserandomarg rk gk bk ck mk yk`
# WINDOWHIGHLIGHT=`chooserandomarg RW GK BW CK MW yW`
# BORDER=$WINDOWHIGHLIGHT

# WINDOWBAR=`chooserandomarg rk bk mk yk`
# WINDOWHIGHLIGHT=`chooserandomarg RW BW MW`
# BORDER=$WINDOWHIGHLIGHT

WINDOWHIGHLIGHT=`chooserandomarg RW GK MW CK yK`
BORDER=$WINDOWHIGHLIGHT
WINDOWBAR=bk

# SCREEN_CAPTION="%{$BORDER} [%{BC}%H%{$BORDER}:%{BC}$SCREENNAME%{$BORDER}] %{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} [%n] %t %{kw} %{$WINDOWBAR}%+w %=%{$BORDER} %M %d %c"
# SCREEN_CAPTION="%{$BORDER} [%H:$SCREENNAME] %{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} [%n] %t %{kw} %{$WINDOWBAR}%+w %=%{$BORDER} %M %d %c"
# SCREEN_CAPTION="%{$BORDER} [%H:$SCREENNAME] %{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} %t %{kw} %{$WINDOWBAR}%+w %=%{$BORDER} %M %d %c"
# SCREEN_CAPTION="%{$BORDER}%H:$SCREENNAME(%{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} %t %{kw} %{$WINDOWBAR}%+w %=%{$BORDER})%d/%M"
SCREEN_CAPTION="%{$BORDER}%H:$SCREENNAME%{$WINDOWHIGHLIGHT}(%{$WINDOWBAR} %-w%{kw} %{$WINDOWHIGHLIGHT} %t %{kw} %{$WINDOWBAR}%+w %=%{$WINDOWHIGHLIGHT})%{$BORDER}%d/%M"

screen -X caption always "$SCREEN_CAPTION"
