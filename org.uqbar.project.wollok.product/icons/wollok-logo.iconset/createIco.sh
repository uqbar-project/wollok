#!/bin/bash

find . -name "*.png" | grep -v 512 | grep -v 256 | xargs png2ico wollok-logo.ico
