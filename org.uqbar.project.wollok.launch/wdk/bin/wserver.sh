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

WCLASS_PATH="echo $(for i in `find $DIR/../lib -name "*.jar"`; do echo $i; done)"

cd $DIR

java -cp "$(echo $WCLASS_PATH | sed 's# #:#g')" org.uqbar.project.wollok.server.WollokServer $@ >> $DIR/wollok.log 2>> $DIR/wollok-err.log &
echo $! > $DIR/wollok.pid
