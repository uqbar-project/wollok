#!/bin/bash
git submodule update --init --recursive
cd org.uqbar.project.wollok.lib/src/wollok
cp ../../../wollok-language/src/wollok/*.wlk ./
