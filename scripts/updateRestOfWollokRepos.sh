eval `ssh-agent -s`

echo "Cloning wollok-cli repo..."
git clone git@wollok_cli:uqbar-project/wollok-cli.git
echo "Updating jars to wollok-cli"
cd ./wollok-cli
./generateCI.sh ../..
cd ..

echo "Copying Wollok library files into libs folder"
mkdir -p ./libs
cp ../org.uqbar.project.wollok.lib/src/wollok/*.wlk ./libs

echo "****************************************************************************"
echo "Cloning Wollok Site repo"
git clone git@wollok_site:uqbar-project/wollok-site.git
rm  ./wollok-site/documentacion/wollokdoc/*.html
rm  ./wollok-site/documentacion/wollokDoc.md
mkdir -p ./wollok-site/documentacion/wollokdoc

echo "Updating spanish WollokDoc files"
java -cp "./wollok-cli/jars/*" org.uqbar.project.wollok.wollokDoc.WollokDocParser "./libs" -folder "./wollok-site/documentacion/wollokdoc" -locale "es"

echo
echo "List of files generated"
ls   ./wollok-site/documentacion/wollokdoc

# generamos la documentación en inglés
# no copiamos el wollokDoc.md, si hay nuevos archivos o se elimina alguno hay que 
# ajustarlo manualmente
echo "Updating english WollokDoc files"
java -cp "./wollok-cli/jars/*" org.uqbar.project.wollok.wollokDoc.WollokDocParser "./libs" -folder "./wollok-site/en/documentation/wollokdoc" -locale "en"

echo
echo "List of files generated"
ls   ./wollok-site/en/documentation/wollokdoc
echo "****************************************************************************"

echo "List of wollok-cli files updated"
cd wollok-cli
echo $GITHUB_JOB > wollok-cli.lastUpdated
git status
echo ""
echo "============================================================================"
echo "Pushing wollok-cli files"
BRANCH_ID=next-version-$GITHUB_JOB
git checkout -b $BRANCH_ID
git add .
git commit -m "Updating Wollok JARs library from Github Action => $GITHUB_JOB"
git push --set-upstream -v origin $BRANCH_ID
echo "****************************************************************************"

alias ssh='ssh -F <(cat .ssh/config ~/.ssh/wolloksite_key)'
cd ../wollok-site
echo $GITHUB_JOB > wollok-site.lastUpdated
echo "List of wollok-site files updated"
git status
echo ""
echo "============================================================================"
echo "Pushing wollok-site files"
git checkout -b $BRANCH_ID
git add .
git commit -m "Updating Wollokdoc files from Github Action $GITHUB_JOB"
git push --set-upstream -v origin $BRANCH_ID
echo "****************************************************************************"

echo "...done"
exit 0