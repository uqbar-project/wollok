#!/bin/bash
#
# Wollok interpreter script
#
#

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


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
LIB="../../lib"
SRC="$DIR/../../target"

WCLASS_PATH="echo $(for i in `find $SRC -name "*.jar"`; do echo $i; done) $(for i in `find $DIR/$LIB -name "*.jar"`; do echo $i; done)"

echo $WCLASS_PATH
echo

#echo java -cp "$(echo $WCLASS_PATH | sed 's# #:#g')" org.uqbar.project.wollok.launch.WollokLauncher $@
java -cp "$(echo $WCLASS_PATH | sed 's# #:#g')" org.uqbar.project.wollok.launch.WollokLauncher -r $@
