## For when you do and apt-get install but get dependency problems which need resolving.
## Doesn't deal with or options

grep " Depends: " |
afterfirst " Depends: " |
takecols 1 |

## Formatted for easy insertion
## The current context is for downgrading to stable:
sed 's+$+/stable+' |
tr '\n' ' '

echo
