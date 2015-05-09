[![Stories in Ready](https://badge.waffle.io/uqbar-project/wollok.png?label=ready&title=Ready)](https://waffle.io/uqbar-project/wollok)
[![Releng](https://travis-ci.org/uqbar-project/wollok.svg?branch=releng)](https://travis-ci.org/uqbar-project/wollok?branch=releng)
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/uqbar-project/wollok?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
# Wollok #
![wollok64.png](https://bitbucket.org/repo/annz6R/images/1431350970-wollok64.png)

A programming language and environment for teaching OOP.

## Installation ##
Download full Wollok distribution from http://download.uqbar.org/

Wollok update site:
```
http://update.uqbar.org/wollok/
```

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

 * Download [eclipse's XText distribution v2.7.3](http://www.eclipse.org/Xtext/download.html) (Full Eclipse)
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
