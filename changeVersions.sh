#!/bin/bash

NEW_VERSION=$1

echo "Updating to version $NEW_VERSION:"

echo -e "\t - POM"
for i in `find . -name "pom.xml" -not -path "./.metadata/*" -not -path "*/target/*" -not -path "*/META-INF/maven/*"`; do
  echo "  " $i
  sed -e "s#\(.*\)<version>[0-9][\.0-9]*-SNAPSHOT</version>\(.*\)#\1<version>$NEW_VERSION-SNAPSHOT</version>\2#g" $i > $i.tmp
  rm $i
  mv $i.tmp $i
done

echo -e "\t - MANIFEST VERSIONS"
for i in `find . -name "MANIFEST.MF" | grep -E "uqbar|xinterpreter" | grep -v "/target"`; do
  echo "  " $i
  sed -e "s#Bundle-Version: \(.*\)#Bundle-Version: $NEW_VERSION#g" $i > $i.tmp
  rm $i
  mv $i.tmp $i
done

echo -e "\t - FEATURES"
for i in `find . -name "feature.xml" | grep -E "uqbar|xinterpreter" | grep -v "/target"`; do
  echo "  " $i
  cat $i | tr '\n' '\f' | sed -e "s#label=\"Wollok Language Feature\"\f      version=\"[0-9][\.0-9]*\"#label=\"Wollok Language Feature\"\f      version=\"$NEW_VERSION\"#g" | tr '\f' '\n' > $i.tmp
  rm $i
  mv $i.tmp $i
done

echo -e "\t - PRODUCT"
for i in `find . -name "*.product" -type f`; do
  echo "  " $i
  sed -e "s#version=\"[0-9]\.[0-9]\.[0-9]\"#version=\"$NEW_VERSION\"#g" $i > $i.tmp
  rm $i
  mv $i.tmp $i

  sed -e "s#Version\ [0-9]\.[0-9]\.[0-9]#Version\ $NEW_VERSION#g" $i > $i.tmp
  rm $i
  mv $i.tmp $i
done


echo -e "\t - CATEGORY"
for i in `find . -name "category.xml" -type f | grep -E "uqbar|xinterpreter" | grep -v "/target"`; do
  echo "  " $i
  sed -e "s#[0-9]\.[0-9]\.[0-9]#$NEW_VERSION#g" $i > $i.tmp
  rm $i
  mv $i.tmp $i
done

echo -e "\t - CODE"
i=`find . -name "Wollok.xtend" -not -path "*/target/*"`
sed -e "s#[0-9]\.[0-9]\.[0-9]#$NEW_VERSION#g" $i > $i.tmp
echo "  " $i
rm $i
mv $i.tmp $i

echo -e "\t - ABOUT TEXT"
i="org.uqbar.project.wollok.product/plugin.xml"
sed -e "s#Version [0-9]\.[0-9]\.[0-9]#Version $NEW_VERSION#g" $i > $i.tmp
echo "  " $i
rm $i
mv $i.tmp $i

CURRENT_YEAR=`date +'%Y'`
sed -e "s#Copyright 2014-[0-9]*#Copyright 2014-$CURRENT_YEAR#g" $i > $i.tmp
rm $i
mv $i.tmp $i

echo "Done !"
