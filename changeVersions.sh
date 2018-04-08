#!/bin/bash

NEW_VERSION=$1

echo "Updating to version $NEW_VERSION:"

echo -e "\t - POM"
for i in `find . -name "pom.xml" -not -path "./.metadata/*" -not -path "*/target/*" -not -path "*/META-INF/maven/*"`; do
    sed -e "s#\(.*\)<version>[0-9][\.0-9]*-SNAPSHOT</version>\(.*\)#\1<version>$NEW_VERSION-SNAPSHOT</version>\2#g" $i > $i.tmp
    rm $i
    mv $i.tmp $i
done

echo -e "\t - MANIFEST VERSIONS"
for i in `find . -name "MANIFEST.MF" | grep -E "uqbar|xinterpreter" | grep -v "/target"`;	do
    sed -e "s#Bundle-Version: \(.*\)#Bundle-Version: $NEW_VERSION#g" $i > $i.tmp
    rm $i
    mv $i.tmp $i
done

echo -e "\t - MANIFESTS DEPENDENCIES"
for i in `find . -name "MANIFEST.MF" | grep -E "uqbar|xinterpreter" | grep -v "/target"`; do
    grep "bundle-version=\"" $i | grep -E "uqbar|xinterpreter" > /dev/null
    if [ $? -eq 0 ] ; then
 	# echo "Modifying $i..."
	sed -e "s#\(.*\)org\.uqbar\(.*\)bundle-version=\"[0-9][\.0-9]*\"\(.*\)#\1org\.uqbar\2bundle-version=\"$NEW_VERSION\"\3#g" $i > $i.tmp
    	rm $i
    	mv $i.tmp $i
    fi
done

echo -e "\t - FEATURES"
for i in `find . -name "feature.xml" | grep -E "uqbar|xinterpreter" | grep -v "/target"`; do
    sed -e "s#\(.*\)version=\"[0-9][\.0-9]*\.qualifier\"\(.*\)#\1version=\"$NEW_VERSION.qualifier\"\2#g" $i > $i.tmp
    rm $i
    mv $i.tmp $i

    sed -e "s#\(.*\)plugin=\"org\.uqbar\.project\.wollok\" version=\"[0-9][\.0-9]*\"\(.*\)#\1plugin=\"org.uqbar.project.wollok\" version=\"$NEW_VERSION\"\2#g" $i > $i.tmp
    rm $i
    mv $i.tmp $i

done

echo -e "\t - PRODUCT"
for i in `find . -name "*.product" -type f | grep -E "uqbar|xinterpreter" | grep -v "/target"`; do
    sed -e "s#[0-9]\.[0-9]\.[0-9]\.qualifier#$NEW_VERSION.qualifier#g" $i > $i.tmp
    rm $i
    mv $i.tmp $i

    sed -e "s#Version\ [0-9]\.[0-9]\.[0-9]#Version\ $NEW_VERSION#g" $i > $i.tmp
    rm $i
    mv $i.tmp $i
done


echo -e "\t - CATEGORY"
for i in `find . -name "category.xml" -type f | grep -E "uqbar|xinterpreter" | grep -v "/target"`; do
    sed -e "s#[0-9]\.[0-9]\.[0-9]\.qualifier#$NEW_VERSION.qualifier#g" $i > $i.tmp
    rm $i
    mv $i.tmp $i
done

echo -e "\t - CODE"
i=`find . -name "Wollok.xtend" -not -path "*/target/*" `
sed -e "s#[0-9]\.[0-9]\.[0-9]#$NEW_VERSION#g" $i > $i.tmp
rm $i
mv $i.tmp $i

echo -e "\t - ABOUT TEXT"
i="org.uqbar.project.wollok.product/plugin.xml"
sed -e "s#Version [0-9]\.[0-9]\.[0-9]#Version $NEW_VERSION#g" $i > $i.tmp
rm $i
mv $i.tmp $i

echo "Done !"
