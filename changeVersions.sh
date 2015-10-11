#!/bin/bash

NEW_VERSION=$1

echo "Updating pom files..."
for i in `find . -name "pom.xml" -not -path "./.metadata/*" -not -path "*/target/*" -not -path "*/META-INF/maven/*"`; do
    sed -e "s#\(.*\)<version>[0-9][\.0-9]*-SNAPSHOT</version>\(.*\)#\1<version>$NEW_VERSION-SNAPSHOT</version>\2#g" $i > $i.tmp
    rm $i
    mv $i.tmp $i
done

echo "Updating bundle versions in MANIFEST.MF..."
for i in `find . -name "MANIFEST.MF" | grep uqbar | grep -v "/target"`;	do
    sed -e "s#Bundle-Version: \(.*\)#Bundle-Version: $NEW_VERSION.qualifier#g" $i > $i.tmp
    rm $i
    mv $i.tmp $i
done

echo "Updating dependencies in MANIFEST.MF ..."
for i in `find . -name "MANIFEST.MF" | grep uqbar | grep -v "/target"`; do 
    grep "bundle-version=\"" $i | grep uqbar > /dev/null
    if [ $? -eq 0 ] ; then
 	echo "Modifying $i..."
	sed -e "s#\(.*\)org\.uqbar\(.*\)bundle-version=\"[0-9][\.0-9]*\"\(.*\)#\1org\.uqbar\2bundle-version=\"$NEW_VERSION\"\3#g" $i > $i.tmp
    	rm $i
    	mv $i.tmp $i
    fi
done
