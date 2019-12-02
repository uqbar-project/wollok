[![Codacy Badge](https://api.codacy.com/project/badge/Grade/77e46a36db0e475a81d674f2c72aff1a)](https://www.codacy.com/app/javier-fernandes/wollok?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=uqbar-project/wollok&amp;utm_campaign=Badge_Grade)
[![Travis](https://travis-ci.org/uqbar-project/wollok.svg?branch=master)](https://travis-ci.org/uqbar-project/wollok?branch=master)
[![Coverage Status](https://coveralls.io/repos/uqbar-project/wollok/badge.svg?branch=master)](https://coveralls.io/r/uqbar-project/wollok?branch=master)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/uqbar-project/wollok?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

<h1>
<img src="https://github.com/uqbar-project/wollok/blob/master/org.uqbar.project.wollok.ui/icons/wollok-logo.iconset/icon_64x64.png?raw=true"/> Wollok
</h1>

A programming language and environment for teaching OOP.

## Xtext-based implementation notes

This is the main repository for the Wollok Xtext-based implementation, which is part of the [Wollok Language Specification](https://github.com/uqbar-project/wollok-language)

## Installation ##

You have two options to download an use Wollok.
**Download a complete Wollok Product Distribution**:

* Linux: [32](http://download.uqbar.org/wollok/products/stable/wollok-linux.gtk.x86.zip) / [64](http://download.uqbar.org/wollok/products/stable/wollok-linux.gtk.x86_64.zip) bits
* Mac [32](http://download.uqbar.org/wollok/products/stable/wollok-macosx.cocoa.x86.zip) / [64](http://download.uqbar.org/wollok/products/stable/wollok-macosx.cocoa.x86_64.zip) bits
* Windows [32](http://download.uqbar.org/wollok/products/stable/wollok-win32.win32.x86.zip) / [64](http://download.uqbar.org/wollok/products/stable/wollok-win32.win32.x86_64.zip) bits

**Update Site (if you already have a compatible eclipse)**:
* http://update.uqbar.org/wollok/stable : for the latest stable release
* http://update.uqbar.org/wollok/dev : for the current dev (work in progress) version

## Wollok SDK standalone ##

Finally if you just want the headless Development Kit (WDK), for example to use a different IDE than Eclipse, you can download it from

- https://github.com/uqbar-project/wollok-cli

This is useful for example if you are going to develop with [Sublime](https://github.com/uqbar-project/wollok-sublime-linter/blob/master/README.md) or any other lightweight text editor

## Documentation ##

Refer to the [wiki](https://github.com/uqbar-project/wollok/wiki/Home) for documentation like [Language Reference](https://www.wollok.org/en/documentation/wollokdoc/) and Environment.

## What's the language like ? ##

* **Object Oriented**
* Non "class-centered". Allows you to create **objects as first-class citizens without the need of classes**. To start working with objects without introducing complex subjects and mechanisms as hierarchies, overriding methods, etc.
* Tries to **maximize compile-time checks** while keeping the **power of a dynamic language.**
* With **implicit types**: by means of a type system and type inference mechanism.
* A **clean modern syntax** avoiding unnecessary symbols (java) while keeping it simple and even familiar for those who already have some experience in programming)
* **Interpreted**: means that the code is being evaluated as it's being read. Although its **declarative syntax** makes it feel like a compiled language

```wollok
package fliers {

   object superman {
        method fly(to) {
             // ...
        }
   }

   class Plane {
        method fly(to) {
            // ...
        }
   }

}

  val aBird = object {
        method fly(to) {
             // ...
        }
  }

  [ superman, new Plane(), aBird ].forEach { o => o.fly() }
```

Check out our [Language Reference](https://www.wollok.org/en/documentation/concepts/) for a concrete idea of the syntax

## How is the Environment ? ##

You can either use its IDE:
* Completely **integrated with Eclipse**.
* With: many **static code analysis**, **Quick-Fixes**, **Refactors**
* An **interactive Console** (**REPL**)
* **Visual representations**: Outline, Static diagram, Objects Diagrams

Or use the wollok-cli which has command line tools for running and checkin a program.

## How to Contribute ##

If you want to contribute to the Wollok development that would be awesome !
We have set a number of wiki pages to help you start, and also documented conventions and instructions for different tasks.

See [https://github.com/uqbar-project/wollok/wiki/Development](https://github.com/uqbar-project/wollok/wiki/Development)

## License ##

Copyright © 2016, [Uqbar Project Foundation](http://www.uqbar-project.org/), All Rights Reserved.

Distributed under the terms of LGPLv3
[https://www.gnu.org/licenses/lgpl-3.0.txt](https://www.gnu.org/licenses/lgpl-3.0.txt)

## Contributors ##

* [Javier Fernandes](http://ar.linkedin.com/pub/javier-fernandes/4/441/14/)
* [Nicolás Passerini](https://github.com/npasserini)
* [Pablo Tesone](http://github.com/tesonep)
* [Nahuel Palumbo](https://github.com/PalumboN)
* [Juan Contardo](https://github.com/Juancete)
* [Franco Bulgarelli](https://github.com/flbulgarelli)
* [Carlos Raffelini](https://github.com/charlyraffellini)
* [Juan Manuel Fernandes dos Santos](https://github.com/JuanFdS)
* [Juan Martín Ríos](https://github.com/JuanchiRios)
* [Mariana Matos](https://github.com/mmatos)
* [Débora Fortini](https://github.com/dfortini)
* [Matías Freyre](https://github.com/matifreyre)
* [Fernando Dodino](https://github.com/fdodino)
* [Lucas Spigariol](https://www.linkedin.com/in/lucas-spigariol-a764a35)
* [Carlos Lombardi](http://dblp.uni-trier.de/pers/hd/l/Lombardi:Carlos)
* [Alfredo Sanzo](https://www.linkedin.com/in/alfredo-sanzo-13a9785)
* [Nicolás Scarcella](https://www.linkedin.com/in/nscarcella)
* [Leonardo Gassman](https://github.com/orgs/uqbar-project/people/lgassman)
* [Federico Aloi](https://github.com/orgs/uqbar-project/people/faloi)
* [Estefanía Miguel](https://github.com/orgs/uqbar-project/people/estefaniamiguel)

## Metrics ##

[![PRs](https://img.shields.io/github/issues-pr/uqbar-project/wollok.svg?maxAge=2592000)]()
[![closed PRs](https://img.shields.io/github/issues-pr-closed/uqbar-project/wollok.svg?maxAge=2592000)]()

[![issues](https://img.shields.io/github/issues-raw/badges/uqbar-project/wollok.svg?maxAge=2592000)]()
[![issue resolution](http://isitmaintained.com/badge/resolution/uqbar-project/wollok.svg)](http://isitmaintained.com/project/uqbar-project/wollok "Average time to resolve an issue")

[![open issues](http://isitmaintained.com/badge/open/uqbar-project/wollok.svg)](http://isitmaintained.com/project/uqbar-project/wollok "Percentage of issues still open")
