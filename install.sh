#!/bin/bash
git submodule update --init --recursive
cd org.uqbar.project.wollok.lib/src/wollok
ln ../../../wollok-language/src/wollok/*.wlk ./
