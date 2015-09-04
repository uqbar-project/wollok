[![Stories in Ready](https://badge.waffle.io/uqbar-project/wollok.png?label=ready&title=Ready)](https://waffle.io/uqbar-project/wollok)
[![Travis](https://travis-ci.org/uqbar-project/wollok.svg?branch=master)](https://travis-ci.org/uqbar-project/wollok?branch=master)
[![Coverage Status](https://coveralls.io/repos/uqbar-project/wollok/badge.svg?branch=master)](https://coveralls.io/r/uqbar-project/wollok?branch=master)
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/uqbar-project/wollok?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# Wollok #

![wollok64.png](https://bitbucket.org/repo/annz6R/images/1431350970-wollok64.png)


A programming language and environment for teaching OOP.

## Installation ##

You have two options to download an use Wollok.
Download a complete Wollok Product Distribution:
* Linux: [32](http://download.uqbar.org/wollok-linux.gtk.x86.zip) / [64](http://download.uqbar.org/wollok-linux.gtk.x86_64.zip) bits
* Mac [32](http://download.uqbar.org/wollok-macosx.cocoa.x86.zip) / [64](http://download.uqbar.org/wollok-macosx.cocoa.x86_64.zip) bits
* Windows [32](http://download.uqbar.org/wollok-win32.win32.x86.zip) / [64](http://download.uqbar.org/wollok-win32.win32.x86_64.zip) bits

## Installation through Update Sites ##

<a href="http://marketplace.eclipse.org/marketplace-client-intro?mpc_install=2420552" class="drag" title="Drag to your running Eclipse workspace to install Wollok"><img src="https://marketplace.eclipse.org/sites/all/themes/solstice/_themes/solstice_marketplace/public/images/btn-install.png" alt="Drag to your running Eclipse workspace to install Wollok" /></a>

Alternatively if you are already familiar with Eclipse you can install Wollok on top of an existing eclipse product by using one of the following update sites:

* http://update.uqbar.org/wollok/master : for the latest stable release
* http://update.uqbar.org/wollok/dev : for the current dev (work in progress) version

## Wollok SDK standalone ##

Finally if you just want the headless Development Kit (WDK), for example to use a different IDE than Eclipse, you can download it from

* http://download.uqbar.org/wollok/sdk/

This is useful for example if you are going to develop with Sublime or any other lightweight text editor

## Documentation ##

Refer to the [wiki](https://github.com/uqbar-project/wollok/wiki/Home) for documentation like Language Reference and Environment.

## What's the language like ? ##

* Object Oriented
* Non "class-centered". Allows you to create objects as first-class citizens without the need of classes. To start working with objects without introducing complex subjects and mechanisms as hierarchies, overriding methods, etc.
* Tries to maximize compile-time checks while keeping the power of a dynamic language.
* With implicit types: by means of a type system and type inference mechanism.
* A clean syntax avoiding unnecessary symbols (java) while keeping it simple and even familiar for those who already have some experience in programming) 
* Interpreted: means that the code is being evaluated as it's being read.

## How is the Environment ? ##

* Completely integrated with Eclipse.
* Compile-time errors reporting.
* Checks and Quick-Fixes.
* Integrated Console.
* Integrated Outline.
* Integrated with eclipse Launchers (Run As).
* A debugger.

## How to Contribute ##
### Preparing the development environment ###

 * Download [eclipse's XText distribution v2.7.3](http://www.eclipse.org/downloads/download.php?file=/modeling/tmf/xtext/downloads/drops/2.7.3/R201411190455/tmf-xtext-Update-2.7.3.zip)
   * Install it as an archived repository - Help -> Install New Software -> Add (work with) -> Archive
 * Install xsemantics plugin from update site:
```
http://master.dl.sourceforge.net/project/xsemantics/updates/releases/1.7
```
 * Install debugvisualization plugin from update site:
```
http://eclipse.cubussapiens.hu
```
 * Install xpect from update site:
```
http://www.xpect-tests.org/updatesite/nightly/
```
 * In the resulting Eclipse, import all the projects below https://github.com/uqbar-project/wollok
 * Run GenerateWollokDsl.mwe2
 * Install Tycho from  Marketplace
 * Install `buildhelper` from Marketplace

## License ##

Copyright © 2014, [Uqbar Project Foundation](http://www.uqbar-project.org/), All Rights Reserved.

Distributed under the terms of LGPLv3
[https://www.gnu.org/licenses/lgpl-3.0.txt](https://www.gnu.org/licenses/lgpl-3.0.txt)

## Contributors ##

* [Javier Fernandes](http://ar.linkedin.com/pub/javier-fernandes/4/441/14/)
* [Nicolás Passerini](http://ar.linkedin.com/in/nicolaspasserini)
* [Pablo Tesone](http://ar.linkedin.com/in/tesonep)


## Metrics ##
[![Throughput Graph](https://graphs.waffle.io/uqbar-project/wollok/throughput.svg)](https://waffle.io/uqbar-project/wollok/metrics)
