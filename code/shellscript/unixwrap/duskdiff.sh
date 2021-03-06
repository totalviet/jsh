#!/bin/sh
# Compares the sizes of all immediate subfolders to their sizes the last time duskdiff was run.

# The current strategy is to sort the folders by name so they stay in position.
# If we sort them by size then pairs of removed and added lines will be disconnected.

unique=/tmp/duskdiff.$$
oldDusk=$unique.old
newDusk=$unique.new

memo -t '100 years' dusk | striptermchars | sort -k 2 > "$oldDusk"

## We can use rememo to refresh the record, or we can leave it alone.
# rememo
## In which case the user can force it to refresh with: rememo dusk
dusk | striptermchars | sort -k 2 > "$newDusk"

# diff "$oldDusk" "$newDusk" | diffhighlight
jdiffsimple "$oldDusk" "$newDusk"

rm -f "$oldDusk" "$newDusk"
# del "$oldDusk" "$newDusk"
