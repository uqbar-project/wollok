git submodule update --init --recursive
cd wollok-language/src/wollok
for %%f in (./*.wlk) do mklink /h "../../../org.uqbar.project.wollok.lib/src/wollok/%%f" %%f
cd ../../..
