#!/bin/bash
#
# Wollok Server start script
#
#

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo $DIR

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

DIR=`dirname "$PRG"`

kill -15 $(cat $DIR/wollok.pid)

~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
~                                                                                                                    
"wserver-stop.sh" [readonly] 27L, 412C                                                             26,1          All

