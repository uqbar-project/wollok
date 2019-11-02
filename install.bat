git submodule update --init --recursive
for %%f in (./wollok-language/src/wollok/*.wlk) do mklink %%f "./org.uqbar.project.wollok.lib/src/wollok/%%f"
