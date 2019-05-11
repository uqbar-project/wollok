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

JARS=(
 "com.google.inject"
 "com.google.guava"
 "javax.inject"
 "org.apache.commons"
 "org.apache.log4j"
 "org.antlr.runtime"
 "org.eclipse.jface"
 "org.eclipse.ui-"
 "org.eclipse.xtext"
 "org.eclipse.equinox"
 "org.eclipse.emf"
 "org.eclipse.core"
 "org.eclipse.debug.core"
 "org.eclipse.debug.ui"
 "org.eclipse.jdt.debug"
 "org.eclipse.jdt.core"
 "org.eclipse.jdt.launching"
 "org.eclipse.osgi"
 "org.eclipse.ui.workbench.texteditor"
 "org.eclipse.ui.ide"
 "org.eclipse.xtend.lib"
 "org.eclipse.xtext.ui"
 "org.eclipse.xtext.ui.shared"
 "org.uqbar.project.xinterpreter"
 "org.uqbar.project.wollok-"
 "org.uqbar.project.wollok.lib"
 "org.uqbar.project.wollok.launch"
)

#WCLASS_PATH="echo $(for i in `find $SRC -name "*.jar"`; do echo $i; done) $(for i in `find $DIR/$LIB -name "*.jar"`; do echo $i; done)"
for i in "${JARS[@]}"
do
  echo "Copying $i*.jar from $SRC" 
  find $SRC -name "$i*.jar" | xargs cp -t jars/
done

for i in `find $DIR/$LIB -name "*.jar"`
do
  echo "Copying $i"
  cp $i jars/
done

#echo java -cp "$(echo $WCLASS_PATH | sed 's# #:#g')" org.uqbar.project.wollok.launch.WollokLauncher $@
#java -cp "$(echo $WCLASS_PATH | sed 's# #:#g')" org.uqbar.project.wollok.launch.WollokLauncher $@
echo "Running..."
echo `find jars/ -name "*.jar"`
java -cp "$(echo `find jars/ -name "*.jar"` | sed 's# #:#g')" org.uqbar.project.wollok.launch.WollokLauncher $@
