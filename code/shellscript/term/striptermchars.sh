## Removes all special terminal characters from stream
## See also: strings, mimencode
## Problem with strings, is it also strips adjacent newlines.

## Didn't work on ^@ ( ):
sed 's+[^m]*m++g' |

## Doesn't work on curses chars ():
sed 's+[^[:print:][:space:]]++g'

