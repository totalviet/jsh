## Removes all special terminal characters from stream
## See also: strings, mimencode
## Problem with strings, is it also strips adjacent newlines.

## So far the combination of these two provides pretty good coverage:

## Didn't work on ^@ ( ):
sed 's+[^m]*m++g' |

## Doesn't work on curses codes (...m):
sed 's+[^[:print:][:space:]]++g'

