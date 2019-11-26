#!/bin/bash
function replace() {
  OLD_TEXT=$1
  NEW_TEXT=$2
  FILE=$3
  echo -e "\t" $FILE
  sed -e "s#$OLD_TEXT#$NEW_TEXT#g" $FILE > $FILE.tmp
  rm $FILE
  mv $FILE.tmp $FILE
}

function replaceMultiline() {
  OLD_TEXT=$1
  NEW_TEXT=$2
  FILE=$3
  cat $i | tr '\n' '\f' | replace $OLD_TEXT $NEW_TEXT $FILE
}

NEW_VERSION=$1

echo "Updating to version $NEW_VERSION:"

echo -e "- POM"
# TODO: usar maven?
cd org.uqbar.project.wollok.releng
mvn dependency:go-offline org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=$NEW_VERSION
cd ..

echo -e "- MANIFEST VERSIONS"
for i in `find . -name "MANIFEST.MF" | grep -E "uqbar|xinterpreter" | grep -v "/target"`; do
  replace "Bundle-Version: \(.*\)" "Bundle-Version: $NEW_VERSION" $i
done

echo -e "- FEATURES"
for i in `find . -name "feature.xml" | grep -E "uqbar|xinterpreter" | grep -v "/target"`; do
  replaceMultiline "label=\"Wollok Language Feature\"\f      version=\"[0-9][\.0-9]*\"" "label=\"Wollok Language Feature\"\f      version=\"$NEW_VERSION\"" $i
done

echo -e "- PRODUCT"
for i in `find . -name "*.product" -type f`; do
  replace "version=\"[0-9]\.[0-9]\.[0-9]\"" "version=\"$NEW_VERSION\"" $i
  replace "Version\ [0-9]\.[0-9]\.[0-9]" "Version\ $NEW_VERSION" $i
done

echo -e "- CATEGORY"
for i in `find . -name "category.xml" -type f | grep -E "uqbar|xinterpreter" | grep -v "/target"`; do
  replace "[0-9]\.[0-9]\.[0-9]" "$NEW_VERSION" $i
done

echo -e "- CODE"
i=`find . -name "Wollok.xtend" -not -path "*/target/*"`
replace "[0-9]\.[0-9]\.[0-9]" "$NEW_VERSION" $i

echo -e "- ABOUT TEXT"
i="org.uqbar.project.wollok.product/plugin.xml"
replace "Version [0-9]\.[0-9]\.[0-9]" "Version $NEW_VERSION" $i

CURRENT_YEAR=`date +'%Y'`
replace "Copyright 2014-[0-9]*" "Copyright 2014-$CURRENT_YEAR" $i

echo "Done !"
