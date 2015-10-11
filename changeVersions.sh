#!/bin/bash

NEW_VERSION=$1

# update all plugins versions on manifests
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
